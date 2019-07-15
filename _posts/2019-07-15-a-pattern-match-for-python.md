---
layout: post
title: "A Pattern Match for Python"
date: 2019-07-15 00:01:43 -0600
categories: python
---

A few months ago, I began work on a parser generator for fun. This work is being
done in Python (my daily language for many reasons), but occasionally I find
myself at odds with the lack of certain functionality in the language. In this
particular instance, I desperately wanted a pattern-match syntax with
"compile-time" exhaustiveness guarantees. Instead of even looking to find an
existing solution, I launched right into developing it. I recently re-opened the
project and found myself re-reading the code to implement this, and figured I'd
write down my solution here in detail.

## Pattern Matching

In many (most? all?) functional programming languages, there exists a capability
called *pattern matching*. The basic notion is that you can take an input value
which may have one of a number of forms, and you can essentially build a switch
over the possibilities.

But more than that, pattern matching allows you to *destructure* those values,
giving names to the internal parts and then using them in the corresponding
block of code.

For example, consider the following algebraic datatype in Haskell:

{% highlight haskell linenos %}
data BTree =
    | Branch Int BTree BTree
    | Leaf Int
    | Empty
{% endhighlight %}

This type represents binary trees containing integers, where each branch or leaf
holds a value.

We could write a function to sum all the integers in such a tree using recursion
and pattern matching:

{% highlight haskell linenos %}
sumTree :: BTree -> Int
sumTree t = case t of
    | Branch val left right -> val + (sumTree left) + (sumTree right)
    | Leaf val              -> val
    | Empty                 -> 0
{% endhighlight %}

This is an example of a pattern match using destructuring. The match syntax (the
`case ___ of` bit followed by the `| ___ -> ___` clauses) allows for easily
handling the cases of an algebraic data type, and you instantly gain the ability
to name the fields for use in the case clause.

Better still is that Haskell (and other languages that support pattern matching)
can perform exhaustiveness checks at compile-time. What this means is that if I
had mistakenly left out the `Empty` case in the above function definition, the
compiler would have complained about it because an `Empty` value could be passed
in and the not handled! This guarantee is incredibly useful, because if you ever
alter the original datatype definition (as happens during development), you are
instantly given the ability to find out where you need to make adjustments in
the rest of your code for free.

## Python's Problem

The problem for Python is that it simply doesn't support this. There is no
functionality in the language for pattern matching.

But I *wanted* it. See, I was transcribing some code which had been written in
Racket using pattern matches, and in this case I think the pattern-match syntax
really is easier to read than using object-oriented programming. So I set out to
devise my own pattern-match syntax for Python.

I had some criteria, though:

- It must be shorter than writing out manual checks.
- It must be (relatively) easy to read.
- It must perform exhaustiveness checking at "compile-time" (more on this
  later).
- It must support destructuring, or something very like it.

## The Solution

It took me a while, but I think I've arrived at a solution that checks all the
boxes (though I don't claim it's the most beautiful thing to use). The code may
update over time (I hope), so be sure to check out the current version on GitHub
[here](https://github.com/pdarragh/derpgen/blob/master/derpgen/utility/match.py).

Use is relatively straightforward! Here's an example:

{% highlight python linenos %}
from .match import match

from dataclasses import dataclass

# First, define the classes we'll match over.
@dataclass
class BTree:
  pass

@dataclass
class Branch(BTree):
  val: int
  left: BTree
  right: BTree

@dataclass
class Leaf(BTree):
  val: int

@dataclass
class Empty(BTree):
  pass

# Then build a match function.
sum_tree = match({
  Branch: lambda _, val, left, right: val + sum_tree(left) + sum_tree(right),
  Leaf:   lambda _, val:              val,
  Empty:  lambda _:                   0,
}, BTree)

# Lastly, a test!
assert sum_tree(Branch(2, (Branch (1, Leaf(4), Empty())), Leaf(7))) == 14
{% endhighlight %}

Here's the current version, with comments and docstring removed and a few areas
marked with numbers so we can talk about them more easily:

{% highlight python linenos %}
# (1)
def match(table: Dict[Type, Callable[..., Val]],
          base: Optional[Type] = None,
          params: Optional[Tuple[str, ...]] = None,
          pos: int = 0,
          exhaustive: bool = True,
          omit: Optional[Set[Type]] = None,
          omit_recursive: bool = False,
          same_module_only: bool = True,
          destructure: bool = True
         ) -> Callable[..., Val]:
  # (2)
  _caller: Traceback = getframeinfo(stack()[1][0])
  _mdfn = _caller.filename  # MDFN = Match Definition File Name.
  _mdln = _caller.lineno  # MDLN = Match Definition Line Number.

  if params is None:
    params = ('_match_obj',)
  if omit is None:
    omit = set()
  if base is None and exhaustive:
    raise MatchDefinitionError(_mdfn, _mdln, "Cannot perform exhaustive match without a given base class.")

  funcs: Dict[Type,
              Tuple[Callable[..., Val],
                    Dict[str,
                         Callable[[List[Any], Any], Any]]]] = {}
  subclasses: Dict[Type, bool] = {}

  # (3)
  def get_all_subclasses(cls: Type):
    for subclass in cls.__subclasses__():
      if subclass not in omit:
        subclasses[subclass] = False
      if not omit_recursive:
        get_all_subclasses(subclass)

  if base is not None:
    get_all_subclasses(base)

  #(4)
  for t, f in table.items():
    if base is not None:
      if t not in subclasses:
        raise InvalidClausePatternError(_mdfn, _mdln, base, t)
      subclasses[t] = True
    func_params = list(params)
    if destructure:
      annotations: Dict[str, Any] = t.__dict__.get('__annotations__', {})
      func_params.extend(annotations.keys())
    else:
      annotations = {}
    duped_names = {name for name in params if name in annotations}
    if duped_names:
      raise DuplicatedNamesError(_mdfn, _mdln, list(duped_names))
    sig_params = signature(f).parameters.keys()
    if len(sig_params) != len(func_params):
      extra_params   = [param for param in sig_params
                        if param not in func_params]
      missing_params = [param for param in func_params
                        if param not in sig_params]
      min_len = min(len(extra_params), len(missing_params))
      extra_params = extra_params[min_len:]
      missing_params = missing_params[min_len:]
      _, src_ln = findsource(f)
      src_ln += 1  # Line numbers from `findsource` are 0-indexed.
      raise ClauseSignatureError(_mdfn, _mdln, t, src_ln, extra_params, missing_params)
    getters: Dict[str, Callable[[List[Any], Any], Any]] = {}
    for i, name in enumerate(sig_params):
      if i < len(params):
        getters[name] = ParamGetFunc(i)
      else:
        getters[name] = AttrGetFunc(name)
    funcs[t] = (f, getters)

  # (5)
  if exhaustive:
    missing_subclasses: Set[Type] = {cls for cls in subclasses
                                     if not subclasses[cls]}
    if same_module_only:
      missing_subclasses = {cls for cls in missing_subclasses
                            if cls.__module__ == base.__module__}
    if missing_subclasses:
      raise NonExhaustiveMatchError(_mdfn, _mdln, missing_subclasses)

  # (6)
  def do_match(*args: Any) -> Val:
    x = args[pos]
    cls = x.__class__
    fgs = funcs.get(cls)
    if fgs is None:
      raise NoMatchError(_mdfn, _mdln, cls)
    func, gs = fgs
    call_params: Dict[str, Any] = {}
    for name in gs:
      try:
        val = gs[name](args, x)
      except Exception:
        raise MatchError(_mdfn, _mdln, f"Could not obtain value via getter for param {name}.")
      call_params[name] = val
    return func(**call_params)

  # (7)
  return do_match
{% endhighlight %}

Let's step through it one piece at a time! I'll try to keep it relatively brief,
though.

### 1. Function signature

The function is intended to be used in a very particular way. In most cases, you
should only pass in two arguments (`table` and `base`). Occasionally, `params`
will be useful. Most of the other options should probably be left alone most of
the time.

The `match` function is used at the top-level to define another function. That
is, you assign a value to the result of calling `match(...)`, and the value
produced is a function which will perform the pattern matching. For an example,
just look up a bit!

### 2. Setup

The function starts by performing some setup.

First, the current frame is obtained. This allows for determining the filename
and line number where the match is declared, which helps with error messages.

Then, some of the parameters are checked for `None` values. `params` represents
the list of parameters to the base function; these will be passed along to each
clause's lambda in order. `omit` determines whether there are any specific
classes that should be omitted from exhaustiveness checking, which can be useful
if there are abstract classes in the middle of the class hierarchy. And `base`
is the base class that you're performing the match over, which is needed if the
`match` function is performing exhaustiveness checks (which it does by default).

Lastly, the `funcs` and `subclasses` dictionaries are initialized. `funcs` will
contain the functions used by the returned function at the end, and `subclasses`
is used for checking exhaustiveness.

### 3. get_all_subclasses

The `get_all_subclasses` method is then defined and called (if the `base` value
is not `None`). This function looks through the subclasses of the `base` class
and builds the list of classes we expect to see in the table. By default, *all*
subclasses are included, which means this will recursively inspect the classes
until their hierarchy is fully walked.

### 4. Pre-processing

Next, `match` iterates over the passed-in table, performing a number of checks
and preparing the final dispatch table along the way. Let's take a look at each
important piece. (In the iteration, `t` is short for `type` and `f` for
`function`.)

The first check is simple: if a `base` value was supplied, we validate that each
class in the table is a recognized subclass of that `base` class. The
`subclasses` dictionary is updated to reflect that we saw this subclass in the
table.

Next, the annotations of the current class are read. The function corresponding
to each clause *must* provide sufficient arguments to handle both the `params`
as well as all the fields of the subclass. The annotations are used for that
second part. (Note that this requires that the subclasses are all implemented
using `@dataclass`. Perhaps I'll relax that requirement at some point.)

Then we check to ensure that there's no overlap between the parameter names
given in `params` and the fields of the subclass. This is because the object
fields will be retrieved by name based on the signature of the function, and the
function must include fields for all the parameters in `params`. So we can't
have any overlap in the names.

The signature of the clause function is then inspected. This gives us a list of
expected parameter names. The length of this list is then compared to the length
of the list of expected parameters. If there's a mismatch (indicating that
either the function has too few or too many fields), an error is raised that
labels which clause is to blame (with line number) and which fields are extra or
missing.

Lastly, getter functions are built. These functions are used to map the `match`
function parameters and passed-in object fields to the parameters of the clause
function efficiently. The getter functions work either over parameters to the
whole `match` function (`ParamGetFunc`) or else the fields of the passed-in
matching object (`AttrGetFunc`).

### 5. Checking for exhaustiveness

At this point, the exhaustiveness check is pretty straightforward: the
`subclasses` dictionary will have `False` entries for subclasses which do not
have clauses in the `table`.

By default, `match` only checks for exhaustiveness within a single module. This
means that if you declare a base class in one file and all the implementations
in separate files, you'll need to set `same_module_only` to `False`. Otherwise,
this portion of the code will not trigger an exception.

### 6. Building the real match function

Of course, we want (some) performance! Instead of performing these
exhaustiveness checks at run-time, they are checked at "compile-time" (i.e.,
when the defining module is first loaded). Once we've checked exhaustiveness
statically in this manner, we can skip them in the future.

To that end, the `match` function produces a new function to perform matching
and execute the clauses at run-time. Section (6) builds that function.

First, the matching object (`x`) is identified by position. (By default, it is
assumed to be the first argument.) The class is extracted and used to look up
the function-getters we created back in the end of (4). Of course, if there's no
match then an error is raised.

The object is then destructured using the getters that were defined.
`ParamGetFunc` parameters are obtained via indexing into the `args`, and
`AttrGetFunc` parameters by using `getattr` on the matching object. If any
parameter can't be found, an error is raised. These parameters are all stored in
a dictionary with their name from the clause function.

Finally, the clause function is called with all of the necessary parameters.

### 7. Returning the function

The last thing done by `match` is returning the real match function we just
created in (6).

The result is a comparatively quick pattern match function!

## In Action

Although I wrote it above, let's look again at the way this is used:

{% highlight python linenos %}
sum_tree = match({
  Branch: lambda _, val, left, right: val + sum_tree(left) + sum_tree(right),
  Leaf:   lambda _, val:              val,
  Empty:  lambda _:                   0,
}, BTree)
{% endhighlight %}

`match` is given a table which maps the subclasses to functions. These functions
must take (a) the parameters of the function (usually just the matching object)
and (b) the fields of the object being matched. Since this example has no need
of looking at the passed-in object in any case, the first field of each lambda
in this example is `_` (to indicate that it can be thrown away).

The function defined in each lambda computes a result. I have found that if this
gets too complex, it can be worth factoring out another function and then simply
calling that inside the lambda. It's not perfect, but it works!

Note that the parameters of the lambda *must* align with the attributes of the
matched object. I'm considering changing this so it's done by position instead
of by name, but I first have to determine whether the order of defined
attributes in a `dataclass` instance can be relied-upon, and then I have to
decide if it's worth requiring all subclasses that are matched-on to be
instances of `dataclass`.

At the end, `match` is passed in `BTree`. This is the base class that the
exhaustiveness checks will be performed relative to. This can be left out, but
then there can't be any exhaustiveness guarantees. I may also change this;
all of the subclasses in the tree can be used to walk a class hierarchy and find
a least common ancestor in that hierarchy. But this will be left to the future
for now.

## Room for Improvement

Of course, my solution isn't perfect.

There are a lot of assumptions in this code about how Python works, from
inspecting the call stack to hoping no subclasses are co-dependent somehow. I
think there's plenty of ways I can improve this function over time, but for the
moment I'm happy with it.

I also have a *predicated* match function (defined in the same module as
`match_pred`). This function uses a more complicated table, but allows for the
construction of guarded clauses --- similar to the use of `where` in Haskell.
However, this is currently implemented very simply and is not too robust, unlike
the more fully-featured `match` I just explained. I intend to update
`pred_match` to work more like `match` in the future!
