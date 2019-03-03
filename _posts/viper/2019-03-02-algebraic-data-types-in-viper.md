---
layout: post
title: "Algebraic Data Types in Viper"
date: 2019-03-02 17:17:00 -0700
categories: viper programming-languages type-systems
---

One of the features I most want to implement in Viper is algebraic data types, or ADTs. ADTs are extremely powerful and
expressive, and they are also very easy to use, in my opinion. But for ADTs to work the way I want, I will have to be
sure there is a type system that adequately supports them.

## Algebraic data types

[Algebraic data types](https://en.wikipedia.org/wiki/Algebraic_data_type), or ADTs, are a way of creating new types from
existing types in a simple, straightforward manner. ADTs can be categorized into two main varieties: the *sum type* and
the *product type*.

### Sum types

A sum type is a type that is defined as an option among various other types, called *variants*. Variants allow us to
express a disjoint union over the possible values. Here's a contrived example:

{% highlight haskell linenos %}
data Foo = Bar Int
         | Baz Bool
{% endhighlight %}

So our type, `Foo`, consists of two variants: `Bar` and `Baz`. Any given instance of `Foo` can be *either* a `Bar` or a
`Baz`, which means that the total number of values that can be specified by the `Foo` type is equal to the total number
of possible `Int` values plus the total number of possible `Bool` values.

Note that `Bar` and `Baz` are also the names of *constructors*, which are like functions but they produce values of an
ADT. You use a constructor similar to using a function: by passing in arguments. A `Bar` can be created by simply
writing `Bar 3`, and a `Baz` by writing `Baz True`. Both of these can be passed into a function expecting a `Foo`.

### Product types

The other kind of ADT is a product type, which is a conjunction of multiple other types. Another contrived example:

{% highlight haskell linenos %}
data Foo = Bar Int Bool
{% endhighlight %}

Now we have a type, `Foo`, with a single constructor, `Bar`. The `Bar` constructor expects *two* arguments, making it
a product type. The total number of values that can be represented by the `Bar` type is equal to the total number of
possible `Int` values *times* the total number of possible `Bool` values --- a cartesian product of the sets of values
of the member types.

### Recursive types

In most languages that support ADTs, the ADTs can be defined recursively. This means we can use a type in its own
definition:

{% highlight haskell linenos %}
data Foo = Bar Int Foo
{% endhighlight %}

### Putting them together

Where ADTs really shine is when combining sum types and product types into a single, very expressive type. For example,
a list can be recursively specified as:

{% highlight haskell linenos %}
data List = Nil
          | Cons Int List

let xs = (Cons 3 (Cons 2 (Cons 1 Nil)))
{% endhighlight %}

So a `List` is either `Nil` (the empty list) or a value joined to another `List`.

Another example might be a binary tree:

{% highlight haskell linenos %}
data Tree = Leaf Int
          | Branch Int Tree Tree

let t = (Branch 1 (Branch 2 (Leaf 3) (Leaf 4)) (Leaf 5))
{% endhighlight %}

The `t` variable corresponds to a tree that looks like this:

{% highlight text %}
    1
   / \
  2   5
 / \
3   4
{% endhighlight %}

### Pattern matching

How does one actually use an ADT?

Once an ADT has been defined, you can use the language's *pattern matching* capabilities to create functions that
operate over the data. For example, let's say we want to sum all the number in a list that's defined as I showed above:

{% highlight haskell linenos %}
data List = Nil
          | Cons Int List

listSum :: List -> Int
listSum l = case l of
              Nil         -> 0
              (Cons x xs) -> x + (listSum xs)
{% endhighlight %}

So you can create a list, say `xs = (Cons 3 (Cons 2 (Cons 1)))`, and sum up the items by calling `listSum xs` to get the
result `6`.

The `case _ of` syntax is the pattern matching syntax in Haskell. It takes in a value of a particular type, and attempts
to match that value's shape against one of the possible variants for that type, allowing us to easily extract the values
out of fields or otherwise write code that is conditional on the shape of the data. This capability is very powerful
when used in the right hands.

Some languages require *exhaustive* pattern matches, meaning that any given usage of the `case _ of` construct *must*
have a case for each possible variant of the input type. In these languages, if you leave out a variant, you will be
given a compile-time error. Haskell does not require exhaustive pattern matching by default, but it can be toggled on
if you want it.

In these languages where it is required, you can also have an "else" case. Consider a complex (contrived) ADT and
associated function using a pattern-match:

{% highlight haskell linenos %}
data Foo = Bar
         | Baz Int
         | Quux Bool Foo
         | Quum String
         | Qulux Char Bool

func :: Foo -> Int
func f = case f of
           Bar         -> 1
           (Baz x)     -> 1 + x
           (Quux _ f') -> 1 + (func f')
           _           -> 0
{% endhighlight %}

The function `func` is considered to be exhaustive even though it only specifies branches for three variants of the
`Foo` type. This is because the `_` pattern will match *anything* that is passed along, so it can help "throw away" any
values that are not important.

I really think pattern matching is an incredibly powerful tool, especially when used exhaustively. An exhaustive pattern
match provides excellent compile-time feedback so you never have to worry whether you missed handling a particular
variant. This becomes more useful the more fluid or complex your data definition is, such as if you're doing some rapid
prototyping.

### Relationship to object-oriented programming

In some sense, ADTs are completely juxtaposed with object-oriented systems. Why is that?

[Philip Wadler](https://en.wikipedia.org/wiki/Philip_Wadler) (a well-known researcher in programming language design,
specifically in functional programming) termed this juxtaposition the
[Expression Problem](https://en.wikipedia.org/wiki/Expression_problem). I won't go into all the details Wadler brings
up, but near the beginning of [the original mail](https://homepages.inf.ed.ac.uk/wadler/papers/expression/expression.txt)
he explains:

> One can think of cases as rows and functions as columns in a table.  In a functional language, the rows are fixed
  (cases in a datatype declaration) but it is easy to add new columns (functions).  In an object-oriented language, the
  columns are fixed (methods in a class declaration) but it is easy to add new rows (subclasses).

The context here is that we are trying to see how to add additional capabilities to an existing system while making
minimal (or no) changes to that system itself. (When he mentions "cases", he's referring to data type definitions.) This
can be summed up as:

- In an object-oriented system, you cannot change the defined methods of existing classes, so you instead create new
  subclasses which can either define new methods or override the existing ones.
- In a functional system, you cannot change the existing data types whatsoever (subclassing doesn't exist), but you can
  easily create new functions to handle the existing data types.

ADTs are the implementation in functional programming languages that Wadler is referring to. You cannot extend or
subclass an existing data type definition --- it just isn't possible. Instead, you add functionality by writing new
functions, since functions are the primary tangible "thing" in functional languages.

This contrasts with object-oriented languages, where (of course) objects are the primary tangible "thing" you work with.
If someone else has already defined a class for you and implemented its methods, then you cannot easily change those
methods. You can, however, create new subclasses of the original class which provide their own implementations of those
methods, and instances of your subclasses can be used anywhere the original class is expected.

Sometimes, I think the object-oriented approach makes more sense, and sometimes I think it's the functional approach. It
really depends on a number of factors, but I would like to support both approaches in Viper.

## ADTs in Viper

Because of this orthogonal relationship between ADTs and object-oriented principles, Viper has a problem.

Viper is meant to be as similar to Python as possible, which means that *everything* in the language should be an object
under the hood. Further, these objects should be programmer-interactable. You can modify the internal bits and bobs of
just about anything in Python if you really want to, and so it seems arguable that Viper should support similar levels
of expression.

This interacts poorly with the design of ADTs and exhaustive pattern matching.

Imagine that I have implemented ADTs in Viper. The data type is created as an object, and its various constructors are
also objects (since all functions in Python are objects).

If the ADT is essentially implemented as a class, then a programmer could potentially write a *subclass* of that class.
This subverts the requirement that ADTs are immutable. If anybody can subclass an ADT, then pattern matches simply
cannot be exhaustive --- someone could always extend an ADT with additional constructors.

Even if ADTs are treated such that they cannot be subclassed, a programmer could manually manipulate the objects in play
to implement subclasses anyway.

Therefore, an ADT definition must be both immutable and unable to be subclassed if exhaustive pattern matching is going
to be supported.

I mentioned in [the previous post]({% post_url /viper/2019-02-28-further-thoughts-on-vipers-type-system.md %}) that I am
already considering allowing immutability in Viper. Similarly, it might be worth adding some ability to prevent classes
from being used as superclasses, similar to Scala's [sealed classes](https://www.scala-lang.org/old/node/123).

So if Viper supports both immutability and sealed classes, does that solve the problem of implementing ADTs?

Not quite. Under a structural type system, any type `Foo` which is structurally equivalent to an ADT `Bar` would be able
to be used as an argument to any pattern match meant to take a `Bar`. This is problematic, because while `Bar` might be
immutable and sealed, `Foo` may not be, and so we still have all the same problems as before.

Therefore, the strict nominal type checking enforcement I suggested in the last post is also necessary. Pattern matching
should be done over only the named type --- not every type which is structurally equivalent to it.

Since I feel strongly about including ADTs in Viper, it seems necessary to implement these three additional features:
optional strict nominal type checking, immutability, and sealed classes (at least for ADTs). Although the latter two are
not terribly Python-like, I think there are ways to incorporate them that will make sense. That'll require some more
thinking, though! 
