---
layout: post
title: "Musings on Viper's Future Type System"
date: 2019-01-16 16:25:00 -0600
categories: viper programming-languages type-systems
---

Although work on Viper has been put on hiatus in the past couple of months as I focus on other things, I've still
been thinking about where it's going to go. I've been working through *Types and Programming Languages* to gain a
greater theoretical understanding of what goes into a type system, and I've continued thinking in my free time about
what Viper's type system is going to look like.

## Modifying a type

Viper's type system is going to be a little unusual, I think. This is because I want it to be both static but also
have the full expressive capabilities of Python.

You may ask "Why is that so hard?", and honestly at first glance it isn't. Plenty of people have written about how to
provide a static type system for a dynamically-typed language (like Python). Where it gets tricky is that I want to match
Python's capabilities as exactly as possible --- even if it maybe isn't the "best design" for a new language.

Specifically, consider the following example in Python:

{% highlight viper linenos %}
class Foo:
    def __init__(self):
        self.bar = 42

x = Foo()     # (1)
x.baz = 16    # (2)
print(x.baz)  # (3)
{% endhighlight %}

At (1), a new `Foo` is initialized. This `Foo` will only have a `.bar` attribute defined (with a value of `42`). Then,
at (2), that `Foo` is object is modified by adding a new attribute (`.baz`). In a sense, the *type* of the object has been
modified --- it's no longer a true `Foo`.

The question that comes up is: Should (3) even be considered legal code in a statically typed language?

Ideally, I would like for (3) to be legal in my type system. It's legal Python, so it ought to be supported (if I can
manage it).

If we use a static type system with no inference, we would rewrite the code above as:

{% highlight viper linenos %}
x: Foo = Foo()
x.baz: Int = 16
print(x.baz)
{% endhighlight %}

This clearly doesn't make sense, I think. We've declared `x` to be of type `Foo` *exactly*. Within the scope in which
`x` is defined, it should only be able to be treated as a `Foo`. Since `Foo` does not define a `.baz` attribute, (3)
would not be legal.

But what if we introduce some form of type inference? If `x` is not explicitly declared to be a `Foo`, then why should
(3) be considered illegal?

## Extensible types

Perhaps, in a type system with inference, `x` is not assumed to be a `Foo`. Perhaps it's assumed to be an
`Extensible Foo` instead.

An `Extensible Foo` is a subclass of `Foo`, so all `Foo`-related attributes can be referred to from it, but it also
fits any subclass of `Foo` that gets introduced along the way (such as our modification produced at (2)).

This is not unrelated to Swift's notion of [extensions](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html).
The Swift docs say:

> Extensions can add new functionality to a type, but they cannot override existing functionality.

So as long as our `Extensible Foo` does not override any functionality of `Foo`, we can treat the additions as
extensions.

Essentially, what I'm proposing is limited-scope implicit type extensions. When a value is modified as in (2) above,
a type extension (like those in Swift) is implicitly created to extend the type of that value. The type of the value
after this modification is the same as the original type, only now it's been extended with new functionality. This
extension is only active (a) within the current scope and (b) for that specific object.

## Caveats

Consider the following:

{% highlight viper linenos %}
x = Foo()
y = Foo()
x.baz = 16
print(x.baz)
print(y.baz)
{% endhighlight %}

This code would produce a type error, because `y` does not have an attribute `.baz` defined on it. `y` is just a
`Foo`, whereas `x` is an `Extensible Foo` by virtue of later being modified.

Now consider:

{% highlight viper linenos %}
x = Foo()
print(x.baz)  # (1)
x.baz = 16
print(x.baz)  # (2)
{% endhighlight %}

In this example, (1) should not be legal but (2) should. The implicit extension of `Foo` does not become active until
the value of `x` is modified to have a `.baz` attribute. So the type system will need to be sophisticated enough to be
able to track these kinds of changes. The scoping would no longer just be lexical, but would now care about individual
statements.

At this point, the question is raised: Is this even still a static type system? The types of values appear to be
changing as needed, which seems much more like a dynamic type system at face value. In truth, I'm not exactly sure how
to reconcile this. I haven't thought through all the implications yet, nor have I taken any considerable amount of time
to figure out how to solve it. But now I've written down my thoughts, and maybe this will help me in moving forward.

I think the most likely course of action is that I will forbid this kind of usage in the interim so I can resume work
on Viper's implementation, but eventually I'll have to come back to it and make a final decision. There will probably
be more blog posts on the topic between now and then, so stay tuned!