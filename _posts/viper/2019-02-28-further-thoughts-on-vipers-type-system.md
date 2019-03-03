---
layout: post
title: "Further Thoughts on Viper's Type System"
date: 2019-02-28 12:25:00 -0600
categories: viper programming-languages type-systems
---

As I've resumed working my way through Pierce's *Types and Programming Languages* (which I am very much enjoying), I've
continued to think about how Viper's type system will end up working. There are many aspects of different systems that
I want to incorporate together to see my vision to fruition, and I think at least some of it will be novel. (Note,
however, that just because an idea is novel does not mean it is necessarily *good*.)

## The basics

First, there are some basic attributes I intend for Viper's type system to have.

Viper will be *statically typed*, because I believe in the power of compile-time type checking. I also intend to
eventually have inference, but early implementations of the type checker may require more hand-holding.

Viper is also intended to be very much like Python, which means a traditional static type system will not work. Viper
must allow a great degree of freedom in manipulating values at run-time, including objects, classes, and types.

Another aspect of type systems is how they determine equivalences and relationships among various types. The most common
type system in mainstream languages is *nominal typing*. In a nominal type system, only the *names* of types and their
relations are considered. An object has the same type as another object only if their types have the same name, and an
object is a subtype of another object's type only if the former object's name is declared as a subtype of the latter's.

But another way of handling type equivalence and relations is *structural typing*, where only the shape of the data is
evaluated to determine equivalence/relation. In a structural type system, one type is equal to another type if they both
implement the same attributes, and a type is a subtype of another if it defines at least as many fields as that type.

Structural typing is essentially the static way of implementing what is often called "duck typing". The philosophy
behind duck typing is: "If it walks like a duck and it quacks like a duck, then it must be a duck." Python is a
duck-typed language because it practically never cares what the *actual* type of an object is, so long as that object
implements the fields and methods needed to accomplish its current task. In a structural type system, any two objects
that satisfy the necessary attributes within a context are considered interchangeable --- just like how duck typing
works.

So the basics of Viper's type system are: it will be *static*, and because of that it will also be *structural*. But
what else is there?

## Allowing nominal typing anyway

Although I think Viper will feature a structural type system, there are times when a true nominal type system can be
useful. Sometimes just because two things function similarly doesn't mean you actually want to allow them to be used
interchangeably in all cases. This is why I propose adding a nominal operator, which prevents a type name from being
used as an alias and instead uses it in a traditional manner. My first thought for this operator is `!` prepended to the
type name, so:

{% highlight python linenos %}
class Foo:
    def __init__(self):
        self.bar = 42


class Quux:
    def __init__(self):
        self.bar = 17


def structural(x: Foo):
    print(x.bar)


def nominal(x: !Foo):
    print(x.bar)


a = Foo()
b = Quux()
structural(a)   # (1)
structural(b)   # (2)
nominal(a)      # (3)
nominal(b)      # (4)
{% endhighlight %}

We defined two classes, `Foo` and `Quux`, which are structurally identical. This means that, in a structural type
system, they can be used interchangeably. Since `Foo` is an alias for the type `{ bar: Int }`, then both (1) and (2)
should execute successfully in the above code.

But the nominal operator `!` indicates that the `nominal` function will only take an object whose type is *named* `Foo`
(or, perhaps, is a nominally-related subtype of the `Foo` type, though this is undecided as yet). This allows a
programmer to choose to specify a nominal typing relation in places where it really matters. However, I believe that in
the vast majority of cases this will not matter, which is why structural type checking remains the default (requiring
less syntax).

## Type extensibility

In [the previous post](% post_url /viper/2019-01-16-musings-on-vipers-future-type-system %}), I began to address the
problem of how Python allows objects and classes to be modified at run-time. This poses a problem for traditional static
type systems, because either the type of an object changes at runtime (which is not usually something that is modeled)
or the definition of a type changes at runtime (which is also not usually allowed).

The reason this is a problem is because in a nominal type system, type relationships are computed based only on the
*names* of types. Consider again the example from the previous post:

{% highlight python linenos %}
class Foo:
    def __init__(self):
        self.bar = 42

x = Foo()     # (1)
x.baz = 16    # (2)
print(x.baz)  # (3)
{% endhighlight %}

I can create an object that is of type `Foo` (1), and at instantiation the object has the same shape as the definition
of the `Foo` type declares. But I can subsequently modify that specific object to give it a new attribute (2), and
now... what is the type of the object? A nominal type system will *think* that `x` is still a `Foo`, because that's the
type that is written down for that variable. But is it really a `Foo`? It functions differently now, so I think it is
really a different type after being modified.

(The problem compounds further if you consider attribute *deletion*, but I'm ignoring that for now.)

Previously, I had suggested adding support for "extensions" in the type system, such that modified types are also types.
But now I think there is a better way.

Under a structural type system, the type of the `x` object that exists after execution of (2) is a *subtype* of `Foo`.
As I mentioned previously, in a structural type system two types are related based on their fields. If type `A` has all
the same attributes as type `B`, but also has a few extra, then `A` is a subtype of `B` because an `A` can be used in
any place that a `B` is used. Since a subtype of a type can be used anywhere that the type can be used (as far as a
structural type system is concerned), then allowing types to be specified by structures works very well in this case.
The `x` object after (2) can still do anything any other `Foo` could do, and therefore it is still a `Foo` when viewed
structurally.

Clearly, a structural typing system is a much more natural fit for Viper (a statically-typed Python derivative) than a
strange nominal system supporting unusual extension abilities (as I proposed in the previous post). And don't worry
about having to write out lists of attributes to specify types; many structural type systems support a form of aliasing
where a name can be assigned to a structure, such as `type Foo = { bar: Int }`, so you can just use the name (`Foo`)
wherever you would normally be specifying a type.

Unfortunately, this is not the end of the problem.

## Modifying class definitions

In Python, a class's definition can be modified at run-time. This poses a problem for a static type system. Consider:

{% highlight python linenos %}
class Foo:
    def __init__(self):
        self.bar = 42

x = Foo()
print(x.baz)    # (1)
Foo.baz = 16    # (2)
print(x.baz)    # (3)
{% endhighlight %}

At (1), `x` has no `baz` attribute defined, so a run-time error would be thrown. If we skip execution of this line and
move to (2), the `Foo` class is extended. Now at (3), `x` *does* have a `baz` attribute and `16` would be printed.

The problem is: `x` was just a `Foo` at both (1) and (3), but we observed different behaviors in the execution of those
lines because the definition of `Foo` changed. How can we make any compile-time guarantees about the functionality of
objects if their types can change form?

To be honest: I'm not sure what the best answer is just yet. But I have started to consider one particular solution...

## Introducing immutability

This is controversial for me, but I'm considering allowing immutability into Viper. In general, immutability is a
language feature that I'm a fan of. It makes reasoning about code significantly easier, because you never have to worry
about what things can change. However, it is completely opposed to Python's natural idioms, and Viper is first and
foremost a Python-like language.

However, immutability can solve a number of challenges that I've been thinking about. Let's start with run-time type
modification.

Suppose Viper allows certain objects to be declared immutable. (I say "objects" because I intend Viper to follow in
Python's footsteps, where everything is an object.) When an object is immutable, none of its fields or methods can be
modified.

So if classes are represented as objects, then each class can be made immutable --- meaning that no attributes can be
added to it.

I think that, by default, all classes would be immutable. But perhaps it could be possible to explicitly declare a
class as mutable if that is functionality that a programmer wants. This would likely require an elaborate run-time type
checking system to be implemented, and I'm not sure how it would interact with the static type system that's used at
compile-time, but it's something I'll continue to think about.

It would also be useful for programmers to be able to define variables as being immutable, which is a functionality that
is catching on lately. This is usually implemented as a keyword used when declaring a variable. For example,
Swift has:

{% highlight swift linenos %}
let x = 3
x = 1       // (1) Compile-time error.
var y = 3
y += 1      // (2) No problem.
{% endhighlight %}

At (1), there is a compile-time error because the `let` keyword declares that the variable `x` cannot be changed. (2)
proceeds just fine, however, because a variable declared with `var` is mutable. The preference within the community is
to always use a `let` definition wherever possible, and the Xcode IDE will issue warnings to this effect. Scala supports
a similar distinction, except using the keywords `val` and `var` (which I like far less for a few reasons).

In this way, a class definition in Viper could be seen as syntactic sugar for the construction of an immutable object
which represents a class, and this would prevent programmers from modifying types at run-time. The downside is the less
Python-like nature of this functionality, but the upside is a type system that works and is consistent.

## Summary

So at the moment, it seems that Viper will have a type system that:

- is static
- is structural
- can be used nominally on demand
- supports immutability
  - definitely in class definitions (though it may not always be required)
  - possibly in variables

I have further thoughts on Viper's type system that I'm still working to write out, and those will probably be posted
shortly. However, I think what I've presented in this post will remain the guiding logic moving forward and is unlikely
to change drastically (I hope).
