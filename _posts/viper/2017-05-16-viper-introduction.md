---
layout: post
title: Viper Introduction
date: 2017-05-16 10:18:00
categories: viper programming-languages syntax
---

Over the past two weeks, I've been working on starting a new language. I've never written my own programming language
from scratch, so I think it'll be an interesting experience. I'll be journaling my thoughts along the way, so feel free
to follow along with my progress as I go!

## Motivation

I've long been interested in programming languages and their development, but the real desire to create my own started
a couple years ago when I took a class simply titled "Programming Languages", taught by Dr. Matthew Flatt (link to the
most recent course overview [here](https://www.eng.utah.edu/~cs6510/)). In this class, we "wrote" our own language
(guided by the book and the lectures) using Racket. In that class, I learned about functional programming for the first
time and began to think about what kind of a language *I* would want to write. But I shelved the project because I
didn't feel like I had enough know-how to be able to do it.

Since then, I've taken a few more courses and talked to many professors (such as my research advisor, Dr. Michael Adams)
about the structure and implementation of programming languages. Most recently, I took another class from Dr. Flatt
called ["Programming Languages and Semantics"](http://www.eng.utah.edu/~cs7520/). In this class, we were taught about
the formal specifications of programming languages — specifically operational semantics and type rules. After finishing
the class this past spring, I decided that maybe now I know enough to be able to write my own language.

## Design

I've tentatively named the language "Viper", since it's based in Python and I'm very clever. You can see what I've got
going on over [here](https://github.com/pdarragh/Viper).

The main goal is to develop a Python-esque language, but with some features from other languages that I really like. I
don't know whether these are all *good* ideas, but it's what I'm working with for the moment. (You can see the current
state of language features [here](https://github.com/pdarragh/Viper/projects/1).) Some of the main ones are:

* Strong, static typing without type inference (so more C/Java-like in that regard)
* Parameter names and (optional) argument labels, like Swift
* Imperative execution
* Classes, interfaces, and other object-oriented structures
* Algebraic data types
* Custom operator definitions/operator overloading

These are just a few things that I've thought of that I think I would like in my language (although we'll see what does
and doesn't make it into the final version). For the moment, I intend to either compile to Python or else write an
interpreter instead. (Python is the current target primarily because I'm most familiar with it; I would eventually
rather get it targeting some other, better-performing language.)

## Syntax

The first step was to decide on some syntax. There are more examples on
[the project wiki](https://github.com/pdarragh/Viper/wiki/Examples), but below are a few samples to get an idea of what
I'm after.

### Python-like syntax with static, non-inferred types

Overall I like the *feel* of Python, so I wanted to keep Viper very similar in some respects. However, I wanted a
language where the programmer must specify all types.

{% highlight viper linenos %}
def fib(n: Int) -> Int:
    if n == 1 or n == 2:
        return 1
    return fib(n - 1) + fib(n - 2)
{% endhighlight %}

### Support for algebraic data types

I use Haskell semi-regularly, and I really enjoy ADTs. Sometimes I don't want to get bogged down with all of the details
of implementing a full class; I just want a simple way to describe the shape of some data. I want ADTs in Viper, but I
also intend to support pattern matching against them.

{% highlight viper linenos %}
data Tree(a):
    Leaf a
    Branch (Tree a) (Tree a)
{% endhighlight %}

### OOP-style interfaces and inheritance

Sometimes, OOP methodologies make more sense to me intuitively. I wanted to support these as well as ADTs. Scala is an
example of a language which uses both to good effect, so I know it's not inconceivable to have both features in the
language.

{% highlight viper linenos %}
interface Shape:
    def get_area() -> Float

Shape Circle:
    def init(radius: Int):
        self.radius: Int = radius

    def get_area() -> Float:
        return pi * (self.radius ^ 2)

Shape Quadrilateral:
    def init(length: Int, width: Int):
        self.length: Int = length
        self.width: Int = width

    def get_area() -> Float:
        return self.length * self.width

Quadrilateral Rectangle:
    pass

Quadrilateral Square:
    def init(side: Int):
        self.length: Int = side
        self.width: Int = side
{% endhighlight %}

These are just a few of the syntactic features of the language so far, and I'm sure I'll end up revising even these
before long. Mostly I just wanted a place to start from and work from there.

The next post will go over the lexer I've written, so stay tuned!
