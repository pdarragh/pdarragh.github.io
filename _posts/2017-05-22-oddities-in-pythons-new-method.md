---
layout: post
title: Oddities in Python's __new__ Method
date: 2017-05-22 16:06:00 -0600
categories: python
---

Last night, I posted about Matt Might's "Parsing with Derivatives" paper ([post
here](/blog/2017/05/22/parsing-with-derivatives)). To aid me in understanding what I was writing about, I implemented a
few simple classes in Python. [Here is the file on
GitHub](https://github.com/pdarragh/Personal/blob/master/Python/PWD.py), though fair warning: it's not complete by any
means, and there are hardly any comments to explain anything. Well anyway, along the way I encountered something
interesting about Python's `__new__` special method.

## Special methods

If you don't know, "special methods" are what Python calls those methods with two underscores on either side. There are
a number of these methods which are used to provide functionality throughout the language. For example: you can
implement the `__gt__` method, which specifies what happens when you compare an instance of your class with the
greater-than operator `>`. Or you can implement `__getattr__`, which defines the functionality for accessing the methods
and fields inside an object with the dot `.` (e.g. `myobject.field`).

Many Python programmers are familiar at least with `__init__`. This is often considered the Python equivalent of the
constructor method seen in plenty of other object-oriented languages. However, it is often glossed over that [*the
object has already been constructed by the time this method is called*](https://stackoverflow.com/a/674369/3377150). It
can be used to set up fields and check that the inputs are valid, but the object has already been allocated in memory
before any `__init__` code is executed. How can that be?

## The \_\_new\_\_ method

The true "constructor method" for Python is `__new__`. It is the responsibility of `__new__` to actually *create* the
object requested. The result of `__new__` is then passed along to `__init__` in the form of the first argument to
`__init__`, most often labeled `self` in Python (though technically you can name it whatever you like).

Generally speaking, you almost never need to override the `__new__` method. As Python is a dynamic language, you can get
away by implementing practically everything in the `__init__` method instead, and this is usually the preferred method
of doing things.

But, sometimes, you need something *special* to happen. In these cases, you can use `__new__` to customize the
instantiation process for your class.

## The set-up

So there I was, implementing some classes for parsing with derivatives. I had an abstract class `A`, and then various
subclasses of `A` (say, `B`, `C`, and `D`) which all existed in a flat hierarchy (they were all "siblings", I guess you
could say). The constructor for one of these classes (let's say it's `C`) in particular accepted two arguments, both
instances of `A`. However, if the first argument was actually an instance of `B`, I wanted to return the second argument
instead of creating a new object.

This was simple enough. Roughly:

{% highlight python linenos %}
class A:
    def __str__(self):
        return f'{type(self).__name__}({id(self)})'

    def __repr__(self):
        return str(self)


class B(A):
    pass


class C(A):
    def __new__(cls, a1: A, a2: A):
        if isinstance(a1, B):
            return a2
        else:
            return super().__new__(cls)
            
    def __init__(self, a1: A, a2: A):
        self.a1 = a1
        self.a2 = a2
            
    def __str__(self):
        return f'C<{id(self)}>({self.a1}, {self.a2})'


class D(A):
    pass
{% endhighlight %}

(You'll note that `__new__` accepts the same arguments that are passed to `__init__`. Additionally, the call to the
super class's constructor via `return super().__new__(cls)` is the recommended method of instantiating the class and
subsequently invoking the `__init__` method.)

This accomplishes almost exactly what I want.

## The problem

Except... I had this weird issue. Here's some output from the interpreter:

{% highlight pycon %}
>>> C(A(), A())
C<4481999928>(A(4482368232), A(4482129144))
>>> C(A(), B())
C<4482602544>(A(4482602488), B(4482602432))
>>> C(B(), A())
A(4481255576)
>>> C(B(), B())
B(4481457680)
>>> C(A(), C(A(), B()))
C<4482559728>(A(4482429672), C<4482559392>(A(4482559672), B(4482559336)))
>>> C(B(), C(A(), B()))
Traceback (most recent call last):
  File "<input>", line 1, in <module>
    C(B(), C(A(), B()))
  File "<input>", line 6, in __repr__
    return str(self)
  File "<input>", line 13, in __str__
    return f'C({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C({self.a1}, {self.a2})'
  [Previous line repeated 191 more times]
RecursionError: maximum recursion depth exceeded
>>>
{% endhighlight %}

Well, that sure is odd! Why is there a `RecursionError`?

{% highlight pycon %}
>>> c = C(B(), C(A(), B()))
>>> type(c)
<class '__console__.C'>
>>> c.a1
B(4481867448)
>>> c.a2
Traceback (most recent call last):
  File "<input>", line 1, in <module>
    c.a2
  File "<input>", line 6, in __repr__
    return str(self)
  File "<input>", line 13, in __str__
    return f'C({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C({self.a1}, {self.a2})'
  [Previous line repeated 191 more times]
RecursionError: maximum recursion depth exceeded
>>> 
{% endhighlight %}

This stumped me for a while. I pored over blog posts and documentation, and I could not for the life of me figure out
what was going on here. Let's walk through that again, but a bit closer:

{% highlight pycon %}
>>> c1 = C(A(), B())
>>> c1
C<4482278848>(A(4481411504), B(4481277848))
>>> c2 = C(B(), c1)
>>> c2
Traceback (most recent call last):
  File "<input>", line 1, in <module>
    c2
  File "<input>", line 6, in __repr__
    return str(self)
  File "<input>", line 13, in __str__
    return f'C<{id(self)}>({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C<{id(self)}>({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C<{id(self)}>({self.a1}, {self.a2})'
  [Previous line repeated 191 more times]
RecursionError: maximum recursion depth exceeded
>>> c2.a1
B(4482140480)
>>> c2.a2
Traceback (most recent call last):
  File "<input>", line 1, in <module>
    c2.a2
  File "<input>", line 6, in __repr__
    return str(self)
  File "<input>", line 13, in __str__
    return f'C<{id(self)}>({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C<{id(self)}>({self.a1}, {self.a2})'
  File "<input>", line 13, in __str__
    return f'C<{id(self)}>({self.a1}, {self.a2})'
  [Previous line repeated 191 more times]
RecursionError: maximum recursion depth exceeded
>>> id(c1)
4482278848
>>> id(c2)
4482278848
>>> id(c2.a2)
4482278848
>>> id(c2.a2.a1)
4482140480
>>> 
{% endhighlight %}

This is not the behavior I expect. I had anticipated that the ID of `c1` and the ID of `c2` would be identical; that's
the point of returning the `a2` argument in the `__new__` method, after all! But what I didn't expect was that for some
reason, `c2` had the wrong values. `c2.a1` should give us `A(4481411504)`, and `c2.a2` should give `B(4481277848)`.
Instead, `c2.a1` is the new `B` object (which no `C` instance should have!) and `c2.a2` is... a recursive reference to
`c2`?

We can shed some light on the situation by going back and examining `c1`:

{% highlight pycon %}
>>> c2.a1
B(4482140480)
>>> c1.a1
B(4482140480)
>>> 
{% endhighlight %}

Clearly, `c1` has been tampered with!

## The explanation

Although I was reading blog post after blog post about the `__new__` method and various pitfalls to watch out for, I was
not reading carefully enough. In fact, here's the relevant excerpt from [the official
documentation](https://docs.python.org/3/reference/datamodel.html#basic-customization):

> If `__new__()` returns an instance of *cls*, then the new instance’s `__init__()` method will be invoked like
> `__init__(self[, ...])`, where *self* is the new instance and the remaining arguments are the same as were passed to
> `__new__()`.

This seems reasonable... until you *really* read it. The key phrase here is "returns an instance of *cls*". What is
glossed over is that Python does not actually check that this returned instance is a *new* instance, despite the
documentation saying it is.

What was happening was my `__new__` method was returning an instance of `C` — the instance `c1` which had already been
initialized! Since this is "an instance of *cls*", the `__init__` function was called again, but *this* time `self` was
pointing to the object `c1`, with the new `B` instance as `a1` and *itself* as `a2`. Since my `__init__` doesn't check
the arguments, it was blindly filling out the fields in the object as it thought it should. This led to `c1.a2` (and
`c2.a2`) pointing to the parent object `c1`, resulting in an infinite recursion when I attempted to get the string
representation of the instance.

## The solution

I found various suggested solutions for semi-similar issues (although I did not find any record of anybody having
*quite* the same problem as me), and what I ended up going with was [based on this StackOverflow
answer](https://stackoverflow.com/a/2484444/3377150):

{% highlight python linenos %}
class C(A):
    def __new__(cls, a1: A, a2: A):
        if isinstance(a1, B):
            return a2
        else:
            new_self = super().__new__(cls)
            new_self.a1 = a1
            new_self.a2 = a2
            return new_self
    
    ...
{% endhighlight %}

There is no `__init__` definition in the class any longer; if there's no `__init__`, then `__init__` can't be called
when an instance of `C` is returned from `__new__`!

This produced the desired results. It was a whirlwind of exploration for a couple hours there, but in the end it was
kind of fun to figure this out!
