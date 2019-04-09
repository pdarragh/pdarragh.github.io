---
layout: post
title: "Solidifying Viper's Type System (Somewhat)"
date: 2019-04-09 13:20:00 -0600
categories: viper programming-languages type-systems
---

Over the past few posts, I've been talking a bit about the type system I want to implement for Viper. I've finally
decided that I need to just pick a decent subset of features to start with and actually begin working on it, or else
I'll never get anywhere! So this post serves to record the major features of the type system I plan to implement as of
right now.

## Table of Contents

This post is a bit lengthy, so I'm providing a table of contents to allow a quick overview and ability to jump straight
to the most interesting bits.

- [Static](#static)
- [Structural and Nominal Typing](#structural-and-nominal-typing)
  - [Object-Oriented Programming](#object-oriented-programming)
- [Recursive Types](#recursive-types)
  - [Mutually-Recursive Types](#mutually-recursive-types)
- [Algebraic Data Types](#algebraic-data-types)
- [Pattern Matching](#pattern-matching)
- [No Implicitly Nullable Types](#no-implicitly-nullable-types)
- [Higher-Kinded Types](#higher-kinded-types)
- [Parametric Polymorphism](#parametric-polymorphism)
  - [Universal and Existential Types](#universal-and-existential-types)
- [Row Polymorphism](#row-polymorphism)
- [Conclusion](#conclusion)

## Static

A *static type system* is one in which all the type information is known at compile-time (and, as a consequence, is
usually found in languages whose implementations are compilers instead of interpreters). The advantages of a static type
system are numerous, but most important to me is the ability to get errors directly from compiling the program instead
of needing to run it over an exhaustive set of tests. This produces a *fail-fast* development environment. Static type
systems can be found in languages like Java, Haskell, Swift, and plenty more.

Python features a *dynamic type system* --- a type system which does not provide any compile-time guarantees (which
makes sense, since the default Python implementation is more interpreted than compiled anyway). To ensure your data is
type-correct in Python, you simply have to write a lot of tests and run the program over them with enough inputs to
satisfy yourself that you won't have any errors in the future. (Note that there are alternate implementations of Python
which provide the ability to run static type checking, but these are not the default way of doing things.)

I should point out that many of the below additional features are irrelevant in a type system like Python's --- that is,
in a language feature *duck typing*. Duck typing is a particular form of dynamic typing where types are not even checked
at runtime like they can be in some dynamic type systems. Instead, the interpreter merely tries to determine whether it
can make the proper calls with the values it has. You can read more about duck typing at [the relevant Wikipedia page](https://en.wikipedia.org/wiki/Duck_typing).

## Structural and Nominal Typing

There are two main categorizations of how type systems approach the representation of types: *structural typing* and
*nominal typing*.

Nominal typing is the style that most people are taught in school. In a nominally typed language, a type is really just
a name for a specific shape of data. Classes in most object-oriented languages are also names of types, and defining a
new class introduces a new type that can be produced. Instances of a class are given the type of their class, and a
value's type can only be changed through a process called *casting*. In most languages there is also a notion of
*subtyping*, where one type is said to be a subtype of (i.e., is more specified than) another type. The subtype relation
in nominally typed languages is determined entirely by types' names and their definitions in the code. That is to say
that you must explicitly declare one type to be a subtype of another by name. (This is usually done by defining a class
which is a subclass of another, such as through Java's `extends` keyword, e.g., `class Foo extends Bar` would be 
defining the class `Foo`, which is a subclass of `Bar`, and thus produces types `Foo` and `Bar` where the former is a
subtype of the latter.)

On the other hand, we have structural typing. A structural type system is one which cares only about the *shape* of the
data. If two different values have exactly the same fields and methods, then they are members of the same type. If one
has more fields than the other, then the former is a subtype of the latter (because it is *more specific*). Structural
typing is usually seen in functional programming languages and research papers.

Python is duck-typed, meaning that a function `def foo(x): ...` will accept for `x` a value of any type, so long as that
value can be used in whatever ways the function expects. This is most similar to a structural type system, because
Python doesn't care about the name of the type of the object.

Therefore, Viper will have a structural type system.

However, while a structural type system guarantees appropriate *functionality* of a type, a nominal type system
guarantees appropriate *meaning*. Sometimes it really is useful to say "This function will only accept values of type X"
where X is a *name* and not a *structure*. Because of this, I want Viper to provide an optional nominal typing
convention. If a programmer wants, they can specify that a particular value must be of a type of the appropriate name.

### Object-Oriented Programming

Since Python supports OOP, Viper will as well.

I think by default the OOP constructs will be structural. That is, a type `T` is considered a subtype of another type
`S` if `T` implements all the fields that `S` does (and, optionally, more, but certainly no fewer).

However, sometimes the programmer may desire to restrict subtyping to *nominal* subtyping, so I think Viper will also
support that avenue.

## Recursive Types

A feature that I don't view as optional is that of *recursive types*, or types which are defined in terms of themselves.

Recursive types are incredibly powerful, and are also a natural thing to come across. Consider a binary tree: each node
in the tree contains a value (perhaps an integer) and 0, 1, or 2 pointers to other nodes further down the tree (the
"children").

This can be expressed simply as a recursive type:

{% highlight python linenos %}
class Tree:
    value: int
    left: Tree
    right: Tree
{% endhighlight %}

(Note that this is not legal Python because Python's type annotation system requires all types to be forward-declared.
This can be fixed by using strings for the recursive type references, e.g., `left: 'Tree'`.)

Viper will have support for recursive types.

### Mutually-Recursive Types

Further extending the idea of the recursive type is the *mutually-recursive types*. This is when two types each refer to
one another in their definitions.

There are quite a few languages that don't properly support mutually-recursive types, but there are plenty that do. I
think there's no good reason not to support this functionality, so Viper will allow it.

## Algebraic Data Types

*Algebraic data types* (or ADTs for short) are types that can be built exclusively from other types. I wrote about ADTs
more fully [in a previous post](% post_url /viper/2019-03-02-algebraic-data-types-in-viper %), so I won't expand on them
too much here except for a brief highlight.

ADTs are a way of building types as compositions of other types. Each ADT specifies a name, which is used as the
constructor for values of that type. For example, if you have a type `type Foo = Foo Int`, then you can create an
instance of `Foo` by doing `Foo 3`. (This is Haskell syntax. The `Foo` on the left of the `=` is the name of the type
being defined, where the `Foo` on the *right* is the name of the type constructor that you use to instantiate values of
this type.)

ADTs come in two flavors: sum types (which represent having an option among multiple types) and product types (which
represent a type composed of all of the component types). So an example of a sum type might be
`type Foo = Bar Int | Baz Float` (where `|` represents the "or" choice), and an example of a product type could be
`type Quux = Quux Int Float String` (so a `Quux` consists of an `Int`, a `Float`, *and* a `String`).

Sum types and product types can be composed as you see fit. For example, we can rewrite the binary tree example from
[the previous section on recursive types](#recursive-types) in Haskell as:

{% highlight haskell linenos %}
type Tree = Empty
          | Leaf Int
          | Branch Int Tree Tree
{% endhighlight %}

The `Empty` constructor takes no arguments and represents a lack of a node. (This is used so we aren't required to use
only *full* binary trees.) The `Leaf` constructor takes an `Int` as a value, but contains no children. The `Branch`
constructor takes an `Int` as a value, but also takes two `Tree` values.

This type allows us to express any possible binary tree (whose values are integers).

I think ADTs are hugely useful, and I especially love how concise they are. They will definitely be a feature of Viper.

## Pattern Matching

I also wrote about pattern matching in [that previous post on ADTs](% post_url /viper/2019-03-02-algebraic-data-types-in-viper %).
*Pattern matching* is the ability to take an ADT type as argument and continue execution based on which constructor it
is. So an example might be summing the values of the integers in the binary tree given in [the previous section](#algebraic-data-types):

{% highlight haskell linenos %}
sum :: Tree -> Int
sum t = case t of
            Empty        -> 0
            Leaf v       -> v
            Branch v l r -> v + (sum l) + (sum r)
{% endhighlight %}

This function takes a `Tree` as argument and returns the sum of all the values inside that tree.

Pattern matching couples naturally with ADTs, and I think any implementation of ADTs should include pattern matching to
be worth much to the programmer. The ability to deconstruct the constructors and immediately assign variables to the
values inside that constructor makes a lot of code much easier to read and reason about, so Viper will definitely have
pattern matching.

Usually when matching an ADT, a language's compiler will give an error if the programmer did not write a case for *all*
of the type's constructors. This is possible because ADTs are generally immutable and not "subtypeable" --- meaning that
all of the constructors are known to be in one place (the ADT's definition). So you could not write a function like:

{% highlight haskell linenos %}
product :: Tree -> Int
product t = case t of
                | Empty -> 0
                | Branch v l r -> v * (product l) * (product r)
{% endhighlight %}

The pattern match does not include a case for the `Leaf` constructor, so the compiler will give the programmer an error
about how the pattern match is not "exhaustive".

I think this capability is incredibly useful. It ensures that every point in the code accounts for every possible case,
so you can't accidentally forget to account for something. Now, sometimes you really do just want to handle one or two
of the constructors, in which case these languages usually provide a `_` wildcard syntax to say "match anything".

But some languages, such as Scala, allow the programmer to perform pattern matches over non-ADT data. This can be very
useful to the programmer because it provides a concise syntax for handling subclasses, but the compiler simply cannot
make any exhaustiveness guarantees in these cases. This is because non-ADT types can be subtyped, and their definitions
are not considered static (in that you can define new subtypes in entirely separate files, or even in a separate
project that imports the base type from a package).

Providing exhaustive pattern match checking over ADTs is simple enough, and providing non-exhaustive pattern match over
non-ADTs is also simple enough. The problem for me is that I want Viper's ADTs to exist within the object hierarchy of
non-ADT types... which is what [the previous post about ADTs in Viper](% post_url /viper/2019-03-02-algebraic-data-types-in-viper %)
addresses.

The short conclusion of this section is: Viper will have pattern matching, and it will (hopefully) support
exhaustiveness checking over ADTs but also general pattern matching over non-ADT types.

## No Implicitly Nullable Types

In languages like Java or C, there are types, and then there is `null` --- a value which inhabits all available types.
You can plug `null` in as a value for a variable of literally any type whatsoever. This means that every type in this
language is *implicitly nullable*. This capability is used often, such as when allocating a variable of a particular
type for which you don't have a value just yet.

But it leads to a lot of headaches. Every Java programmer is familiar with the dreaded `NullPointerException` --- an
exception which translates to "I encountered a `null` value somewhere where I shouldn't have." This can be very
frustrating, but the truth is that we have developed better solutions!

A common feature among modern languages is the *optional type*, usually spelled `Option`, `Optional`, or `Maybe`. This
is a special kind of type because it is actually parameterized by *another* type. That is, you can never have a value
of type `Option`; you instead have a value of type `Option<X>` (or whatever the spelling is in your language).

The `Option<X>` type tells us "This value is either an X or it's nothing" (where "nothing" means `null` in most
languages). What's neat about this is that it introduces a requirement to *unwrap* the internal value before using it,
which means it is impossible to get anything like a `NullPointerException`.

To make this more concrete, consider the following OCaml code:

{% highlight ocaml linenos %}
let foo (optionalVal : int option) : int =
    match optionalVal with
    | Some v -> v
    | None   -> 0
{% endhighlight %}

This is the definition of a function which takes an `int option` (the OCaml spelling for `Option<Int>` --- a value which
is either an `int` value or nothing) and pattern-matches that value against the possible cases. If the instance passed
in is a `Some v`, then the `v` (an int) can be extracted and returned. Otherwise, if the instance is `None` (nothing),
then the function will return 0.

The wrapped value `v` can never be `null`, because the compiler would never accept it (trying to put a `null` inside the
`Some` constructor would cause a compile-time error). `v` *must* be an `int`, so we remove the potential for any
`NullPointerException`-like problems.

Even though Python will happily accept a `None` in absolutely any place, I don't want to allow this. Viper will not have
implicitly nullable types.

### Swift's Take on Optional Types

Swift has some interesting contributions to make on this topic in that the optional types are syntactically ingrained in
the language. By this I mean there are a few special features that make using optional types much more convenient:

1. Types can be made optional by appending `?` to their name, e.g., `Int?` is an optional integer.
2. There is a "null coalescing" operator, `??`, which provides either the value of the optional if it's not empty or
   else an alternate value, e.g., `return optionalVal ?? value`.
3. The optional values can be unwrapped *unconditionally*. This is essentially the programmer asserting "I know you
   can't quite figure this out, type system, but I assure you there will be a value in this variable by the time you get
   to it." This is spelled with the `!` postfix operator, e.g., `optionalVal!` produces the non-empty value. This will
   throw a runtime exception if a null value is encountered at this point.
4. Optional values can be chained together, which allows for saying something like "If X, Y, and Z all have real values
   (are not empty), then do this thing" in a very concise manner. This is accomplished via the `?` postfix operator,
   e.g., `if x?.y?.z? { doThing() }`.
5. Optional values can also be bound to a limited scope through a specialized `if let` syntax. This is given as
   `if let value = optionalVal { doThingWith(value) }`. The interior of the if will be evaluated only if `optionalVal`
   is not empty. Furthermore, within the scope of the if the variable `value` will be bound to the value that was
   contained in `optionalVal`.

There might be some others that I'm forgetting, but I think these are the main ones.

I think these are some very powerful extensions to the concept of the optional type which can make using them much
easier for the programmer, and the easier something is to use in a language the more often it will be used. However, I'm
not sure how I feel about incorporating the syntax for a single (albeit powerful) concept like optional types into the
language at such a level. I'll have to think more about this.

## Higher-Kinded Types

The optional type of the previous section is an example of a *higher-kinded type*. To explain, let's start with the
word "kind".

[Wikipedia gives the following definition](https://en.wikipedia.org/wiki/Kind_(type_theory)):

> a **kind** is the type of a type constructor

So it's a meta-type --- a type which is used to describe other types.

Kinds are spelled using just `*` and `->`.

Most types you're likely familiar with are of kind `*` and are often called *proper types*. These are types which
contain values. `Int`, `Char`, and `String` are all of kind `*`.

The next kind up is `* -> *`, which represents "types which require one other type as argument before a value can be
produced". The optional type is of kind `* -> *`. `Option` by itself doesn't mean anything as a type; instead, it must
be given another type as argument in the form `Option<X>`, where `X` is whatever type you're working with (e.g., it
could be `Option<Int>`). Note that while `Option` has kind `* -> *`, `Option<Int>` merely has kind `*`. That's because
there are *values* inhabiting the type `Option<Int>` such as `Some(3)`, `Some(42)`, and `None`.

So kinds are just categories for special types that need other types to be passed as parameters before they can be
useful.

Higher-kinded types are useful because you can define types that are parameterized over other types. This allows for
greater freedom of abstraction.

Haskell is a language with lots of support for higher-kinded types, and it's not uncommon to find Haskell code making
use of this feature. Another example of a higher-kinded type that Haskell provides is `Either<A, B>`: a type whose
values are either values of A or values of B. The constructors for this type are `Left<A>` and `Right<B>`, and can be
used in pattern matching:

{% highlight haskell linenos %}
foo :: Either A B -> A
foo e = case e of
            Left a  -> a
            Right _ -> error "Not an A"
{% endhighlight %}

I think giving the programmer the ability to generate new higher-kinded types could be incredibly useful, but I'm also
not exactly sure what all the use cases are.

For now, it's a feature I'll mark as "I would like to implement this, but we'll see if it happens." At the very least,
higher-kinded types likely won't be in the first implementation of Viper's type checker.

## Parametric Polymorphism

The idea of *parametric polymorphism* is that sometimes the specific shape of a piece of data doesn't matter to a
function or data definition --- that function or data definition is said to be polymorphic in its parameter(s).

Let's imagine for a moment that we have a `List<X>` type (which is higher-kinded, because it takes a type as parameter).
This means we can have a type for lists of integers (`List<Int>`) or lists of strings (`List<String>`) or even lists of
lists of other things (`List<List<X>>`).

Without parametric polymorphism, the type `X` *must* be instantiated when used in function definitions. But *with*
parametric polymorphism, the type can be left uninstantiated so as to be more general. Specifically:

{% highlight haskell linenos %}
zip :: [a] -> [a] -> [(a, a)]
zip xs ys = case (xs, ys) of
                | ([],    [])    -> []
                | (x:xs,  [])    -> []
                | ([],    y:ys)  -> []
                | (x:xs', y:ys') -> (x, y) : (zip xs' ys')
{% endhighlight %}

(Note that Haskell spells `List<X>` as `[X]`.)

The function `zip` takes two lists of some unknown type (but the same type in both lists) and produces a new list of
pairs of elements. The function doesn't care what the type `a` corresponds to, because it doesn't matter to the
implementation whatsoever. This is an example of parametric polymorphism: this function can accept lists of any type.

I think parametric polymorphism is hugely useful, so it will definitely make an appearance in Viper. However, there is a
question of how strong to make it.

There are two forms of parametric polymorphism: *predicative* and *impredicative*.

Predicative parametric polymorphism imposes the restriction that the type parameters (the `a`s in the Haskell example)
cannot themselves be parametrically polymorphic. That is, the parametricity can only go one level deep.

Impredicative parametric polymorphism makes no such restriction. However, this comes at a cost: type inference becomes
much more challenging to implement.

I'm undecided on which variant I'll be implementing. Fortunately, the implementation of parametric polymorphism can
likely wait for a while, so I don't need to choose just yet. I'm sure I'll end up writing a post or two about the
decision process along the way, though.

### Universal and Existential Types

Parametric polymorphism can be made even more expressive by allowing the programmer to use *universal* and *existential
types* in their type declarations.

I think [this Stack Overflow post explains the concepts well](https://stackoverflow.com/a/9473088/3377150) (although
some of the other answers are good for gaining a deeper understanding). The key takeaway is that these special types
allow for specifying a certain level of knowledge about a type parameter.

A universal type `∀X` allows us to define functions which will accept absolutely any type for `X`. The consequence of
this is that the function cannot interact with the values of this type, because it has no way of knowing what that type
actually is.

Conversely, the existential type `∃X` essentially says "There is something in here, but you can't know what it is."

The SO answer I linked to phrases the distinction in terms of *producers* and *consumers* of types containing universal
or existential types, which I think makes things more clear.

Consider the type `T = ∀X ...`. The *producer* (`T`) is saying that it can take absolutely any type for `X`,
which consequently means that `T` itself knows absolutely nothing about the internals of that type. The type is opaque
to the producer. But a *consumer* (something that's creating an instance of `T`) gets to know what `X` is, because the
consumer is the one dictating `X`'s identity. Which means that the consumer can use any value of type `X` that can be
extracted from `T`.

Now consider the type `T = ∃X ...`. This time, the producer is the one that gets to know the specifics of `X`, whereas
the consumer knows nothing. `T` merely promises that "there is *some type* that will be used here --- but you don't get
to know what it is."

I think universal and existential types seem useful to have direct interaction with, so I will consider adding them to
Viper's type system. But it's not a sure thing at this point. We shall see.

## Row Polymorphism

Structural type systems usually work in terms of *record types*. These are essentially nameless bundles of fields with
associated types and values. The record type `{ x: Int, y: Int }` would represent the type of two-dimensional
coordinate pairs, for example. In some literature, the fields are referred to as *rows*.

So *row polymorphism* is the concept of allowing records to be polymorphic. Imagine we have a function such as:

{% highlight python linenos %}
def foo(v: { x: int, y: int }):
    ...
{% endhighlight %}

This function takes as parameter the type of two-dimensional coordinate pairs.

The question that row polymorphism seeks to answer is: should this function only accept those records whose shape
exactly matches the expected one?

Consider the type of three-dimensional coordinate pairs: `{ x: Int, y: Int, z: Int }`. This is a record type which
defines both an `x` and `y` row... so couldn't we use it in `foo`?

Under row polymorphism, the answer is "yes".

This functionality aligns with Python most closely, so Viper will support it.

## Conclusion

I think this post successfully records at least the majority of my desired features in Viper's type system. And now that
I've written it all down, I can finally start to work on actually implementing it!
