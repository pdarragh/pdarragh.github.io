---
layout: post
title: "Alternatives to Immutability in Viper"
date: 2019-03-11 12:25:00 -0600
categories: viper programming-languages type-systems
---

In my [last post]({% post_url /viper/2019-03-02-algebraic-data-types-in-viper %}), I decided that implementing algebraic
data types in Viper would require three modifications to the fundamental Python-like nature of the language: optional
strict nominal type checking, immutability, and sealed (non-subclassable) classes. However, some recent discussions have
made me reconsider whether immutability is really necessary or if there might be some alternative path forward.

## Opacity

I'm in a reading group with some faculty and grad students, where each week we read a paper from the programming
languages literature (preferably recent, but not always) and discuss. Sometimes our discussions are short, so we move on
to talking about other things. That was the case this past week, so I brought up my ideas about bringing ADTs to Viper.
Specifically, I wanted input on the three big changes I felt I had to make so that ADTs could work properly.

The most in-depth discussion had to do with the factor of immutability. I had suggested immutability on the basis that
the ADT classes must not be modifiable at run-time, or else any compile-time guarantees (such as the exhaustiveness of
a particular pattern match) would be thrown out the window.

Matthew Flatt suggested an alternative solution which he called *opacity*. Essentially, the idea is to allow certain
fields of data structures to be declared opaque so that they are not visible externally. He said that this is the
method employed in Racket's `struct`s. The Racket community, apparently, doesn't feel that opacity was necessarily the
right choice in that context, but he suggested that it could be another avenue to explore instead of immutability.

Of course, both immutability and opacity are fundamentally opposed to the Python philosophy, so I will be making a
compromise regardless of which path I choose.

## Weighing the pros and cons

Although both courses of actions lead to a less-Python-like Viper, they each have different benefits and caveats.

First, let's look at **immutability** as an optional feature:

- Pros
  - Showing up regularly in more modern languages (Swift, Scala)
  - Can reduce occurrence of side-effect assumptions (because things become easier to reason about)
  - Could be implemented to be used at any level of development (class definitions, local variables, etc.)
    - Integrating a feature at all development layers allows that feature to become representative of the language's
      philosophy
- Cons
  - Would require extra keyword for initialization compared to mutable variables, making mutable things more favored
    - Although maybe that's a good thing, considering a Python-based philosophy?
  - Immutability runs counter to the philosophy that all data should be user-editable
  
And now **opacity**:

- Pros
  - Less far-reaching implications (localized to class-like definitions)
    - Restricting an antithetical feature to specific development layers prevents it from becoming representative of the
      language's philosophy, serving as more of an "exceptional" development strategy
  - Opaque values could still be accessible through indirect means (like mangled names in Python already), but by using
    an indirection any caveats of user interference can be seen as allowable
    - This means that compile-time guarantees may not be *true* guarantees, but at some level the user has to take
      responsibility for their own actions
  - Hiding things indirectly is not as unPythonic as immutability
- Cons
  - Not a common language feature
    - This isn't inherently bad, but it does mean it may not be used regularly or as intended
    - But maybe that's actually a positive aspect in disguise? Hmm...

Based on these considerations, opacity seems to be the more favorable choice here.

## User interference

Python cultivates a culture driven by the philosophy of ["We're all consenting adults."](https://mail.python.org/pipermail/tutor/2003-October/025932.html)
In essence, this means that a dedicated developer can choose to interfere in whatever internal goings-on they so wish.
Python does implement a feature called [name mangling](https://docs.python.org/3.7/tutorial/classes.html#private-variables)
where class attributes prefixed by two underscores have their names adjusted at "compile-time" to avoid accidental
superclass attribute overloading. What this comes out to is: sometimes the Python language obfuscates code a little bit.
It's never irrecoverable, though --- you can always choose to get around mangled names if you so wish. It's not "easy",
but it is possible.

I think opacity could be considered in the same vein. Perhaps objects can have attributes which are not exposed at the
top level, but which are still accessible to somebody if they really want to go get them. The use of opacity would be
generally discouraged, excepting specific circumstances.

So I think opacity comes out ahead of immutability here. Both can be used to solve the same part of the ADT issue, but
opacity seems to be less against Python's philosophy.

## On the syntax of opacity

The syntax for immutability is simple: you add a new keyword (like `let`), and variables declared with that keyword are
immutable. Done.

I'm really not sure what to use for opacity, though.

Opacity is likely to only be useful in class definitions. Since ADT definitions are probably just going to be syntactic
sugar for fancy classes, this is fine. But the question is how to write it.

One option would be to use a decorator-like syntax:

{% highlight python linenos %}
class Foo:
    def do_thing(self):
        ...
    
    @opaque
    def do_other_thing(self, arg):
        ...
{% endhighlight %}

This is similar to other Python tactics for modifying the representation of class data (such as `@classmethod`). But it
also is not terribly ingrained into the syntax.

Another option would be to just add a new keyword that has to precede the function or variable declaration:

{% highlight python linenos %}
class Foo:
    def do_thing(self):
        ...
    
    opaque def do_other_thing(self, arg):
        ...
{% endhighlight %}

Opacity could potentially be applied to any attribute which has at least one underscore prepended to its name:

{% highlight python linenos %}
class Foo:
    def do_thing(self):
        ....
    
    def _do_other_thing(self, arg):
        ...
{% endhighlight %}

There's some precedent for this, as single-underscore attributes are considered "private" (in the sense that they are
not intended to be used externally, and are generally not exported in modules by default).

But then this raises the question: if opacity is just a convention of what's visible externally, and if Python already
has a philosophy regarding single-underscore attributes, then why not just *use* single-underscore attributes instead?

And the answer is: I'm not sure. It really comes down to how badly I want these compile-time pattern match
exhaustiveness guarantees, and I just haven't come to a decision on that. To truly guarantee exhaustiveness will require
incorporating some functionality that is completely unPythonic. To maintain any Pythonicity requires that the guarantees
are relaxed to some degree. Somewhere along this spectrum lies Viper's future, but I'm not sure exactly where that will
be just yet.
