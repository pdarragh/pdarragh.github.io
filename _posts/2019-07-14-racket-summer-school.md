---
layout: post
title: "Racket Summer School 2019"
date: 2019-07-14 13:42:31 -0600
categories: education racket
---

I spent the last week at the [Racket Summer School](https://school.racket-lang.org),
a really fun and action-packed week that was focused entirely on the concept of
*Language-Oriented Programming* (LOP for short). The sessions were taught by
Racket's principle designers and implementers, and it was a great way to get a
better feel for the crazy power Racket offers programmers. (And it was also a
great way to meet new and interesting people!)

In this post, I'll give a brief overview of what was covered at the school for
anybody who couldn't make it (or who wants a reminder). It won't be very
technical, and it also won't be complete! The technical material is all
available online [here](https://school.racket-lang.org/2019/plan/) for people
who are more interested in that sort of thing.

## Day 1: Language-Oriented Programming

The first day started with a round of introductions. There were probably ~50
people there, which I thought was a pretty good number! I was surprised at the
diversity of backgrounds of the people there. There were undergraduate and
graduate students (and the grad students were mostly not in programming
langauges!), educators (in computer science and otherwise), researchers, and
industry engineers who all just wanted to learn more about Racket for one reason
or another.

After introductions, the first lecture was given by [Matthias Felleisen](https://felleisen.org/matthias/),
the progenitor of the entire Racket project (and kind of a big deal in the field
of PL in general). Over the course of a few hours, he laid out the primary
motivation of Racket: the ability to write new programming languages to suit
your needs for any given task. From his perspective, the best way to enable this
was to write an *extensible* programming language --- one which the user can
modify and manipulate by design to enhance their programming abilities as
needed.

Since my undergraduate PL course was taught by [Matthew Flatt](http://www.cs.utah.edu/~mflatt/)
(whose PhD was advised by Matthias and who is another of the primary Racket
implementers), a lot of this was not completely new to me. However, it was
immediately clear that Matthias is very passionate about his goals. He laid out
excellent justification for the need for such a langauge as Racket, which was
very cool to see.

The principle idea underpinning Racket's design is the *macro*, which is a
language feature that enables the programmer to modify the syntax of a program
at compile-time. This allows the programmer to create their own syntactic
abstractions, essentially developing sub-languages that run on top of Racket and
which can easily rely on the underlying support of Racket's other functionality.

On Monday afternoon, the lecture was given by [Jay McCarthy](https://jeapostrophe.github.io),
an associate professor at UMass Lowell and another principle implementer of
Racket.

Jay started by further motivating the purpose of macros. He compared x86
assembly ("the most beautiful of all assemblies") and C ("the language with the
most buttery --- ah! --- popcorn-like syntax", whatever that means haha). He
pointed out that assembly does not provide any way to directly create repeatable
procedurs, but there is a pattern you can follow to emulate the same capability.
In contrast, C provides a built-in way to do this: function definition. This
makes writing repeatable procedures much easier and, possibly more importantly,
much *safer*.

> "Assembly does not respect the pattern of procedures that you get with the
> abstraction."
>
> --- Jay McCarthy

So the conclusion he arrived at was that language extensions allow programmers
to be more efficient (by providing short forms), but also provide new
*abstraction boundaries*. The more you can abstract, the more complex ideas you
can work with in your head.

Macros are a key part of the language extension philosophy, and specifically Jay
said that they answer the following two questions:

1. What are patterns that we see over and over again?
2. What are the abstractions we devise to handle those patterns?

Then we spent the rest of the class time writing our own simple macros to
practice.

## Day 2: Advanced Macros

For the second day, Jay started us off by showing us what makes a macro bad.

> "A macro that exposes its implementation ain't no macro."
>
> --- Jay McCarthy

We focused on the idea of writing macros that are transparent to the user, such
that they feel natural to use. The more natural a macro feels, the less likely
it is that it will be used to produce invalid or unexpected results. Above all,
macros should be easy to use.

One part of this design philosophy is the idea that macros should throw
exceptions at reasonable times. Many macros operate at compile-time, which means
you should design your error-handling procedure to trigger at compile-time, too.
(Of course, there are times when this isn't possible or practical.)

Another aspect of easy-to-use macros with failure-indication is the notion of
*syntax classes*. A syntax class allows a macro to essentially test whether an
argument is of the correct class, ensuring you don't write a macro that
transforms something you weren't expecting.

Syntax classes are enforced via *contracts*, which are functions that wrap other
functionality to ensure type correctness. Custom contracts can be specified to
ensure run-time correctness, and if you write a lot of macros with the same
contracts then you can extract those contracts into macros of their own! It's
macros all the way down, it seems.

In the afternoon, we moved on to discussing *hygiene*. Hygiene is the idea that
macros should preserve lexical scope of variables, which is tricky if your macro
system is too primitive (like C's preprocessor macros). After introducing
hygiene, Jay immediately moved to explaining that sometimes you actually want to
break it. In these cases, you can use things like *syntax parameters* or
*literals* to accomplish your goals more safely.

## Day 3: Modules, Macros, and Languages

On Wednesday, we switched lecturers to Matthew Flatt, a professor at the
University of Utah (incidentally my favorite professor I took classes from).

Matthew introduced the idea of *modules*, which are ways of wrapping related
code together. In Racket, you can manipulate certain aspects of the module
import/export system to accomplish some neat things.

Throughout the day, we were working on a Racket extension/language that provides
the ability to execute shell commands as though they were Racket functions.

We learned about what Matthias later called *interposition points*, which are
all identified with names that start with `#%`. Interposition points allow a
language implementer more advanced customization of the environment they export
to other users. I thought these were really pretty neat. They're used
implicitly, which means that overriding one will automatically give you some
altered functionality in the exported language, which is very cool.

Later in the day, Matthew explained some ways to more directly manipulate the
syntax being generated or read in macros through use of things like `#%datum`.
While these aren't always necessary, they can be needed in some specific cases.

The last major component of the day was implementing recursive macros and macros
that define other macros. It turns out there is some intricacy in getting all
the macros to expand things at the right time during execution (i.e.,
compile-time vs run-time, except it's more nuanced than just those two cases).

## Day 4: Types and Type Checking

Taking a break from the mostly-dynamically-typed nature of Racket, Thursday was
all about types and writing type checkers. Our lecturer was [Jesse Tov](http://users.cs.northwestern.edu/~jesse/),
a professor at Northwestern University.

He showed us a super cool project built on Racket called [Turnstile](https://docs.racket-lang.org/turnstile/index.html).
Turnstile is a language that allows the programmer to specify type judgment
rules and then produces a type checker to accompany those rules.

The really cool aspect of this was the notion of [type systems as macros](http://www.ccs.neu.edu/home/stchang/pubs/ckg-popl2017.pdf).
It turns out Turnstile is implemented mostly through some very cool macros!

Jesse started by giving a fast-but-thorough overview of formal type systems and
type judgment rules, which was good since a large number of people in the class
had never seen them before.

The latter half of the day was mostly working through exercises, implementing a
small language using Turnstile. This really solidified the idea of using macros
to perform interesting operations at compile-time; in this case, Turnstile
performs all the type-checks during compilation through macros, which is really
cool to me.

## Day 5: Wrapping Up

For the final day, our primary lecturer was [Robby Findler](http://users.cs.northwestern.edu/~robby/),
who is a professor at Northwestern University and has been a primary
implementer of Racket since the beginning.

The goal of the first half of the day was to put everything we'd learned into a
single cohesive whole. Robby lectured a bit about combining some of the
techniques together, and then set us loose on a lab exercise to implement a
regular expression language (which I still have to finish haha).

After we worked on the lab for a while, Robby showed us a few examples of cool
languages that had been implemented in Racket:

- Scribble --- write living documentation
- PLT Redex --- generate operational semantics rules and evaluators
- Haiku --- randomly generate haiku poems
- 2d/cond --- implement predicated functions graphically

Throughout this presentation, Robby tied what we were seeing to what we had
learned throughout the week. This was a really cool way to see what was
possible in Racket.

Lastly, Matthias took over and wrapped everything up. He provided an overview of
the whole week, tying everything together and reviewing the key points of the
Racket philosophy. (I took thorough notes but I don't know that they're super
helpful here. Maybe I'll upload them separately later.)

> "We are in the Stone Age of programming languages."
>
> --- Matthias Felleisen (to me over dinner on Wednesday night)

## Retrospective

In all, I really had a blast at Racket Summer School. I learned a ton about
Racket and language-oriented programming, and I also made new friends with some
very interesting people. If given the opportunity, I'd probably happily go back
every year from here on --- which means that I recommend you go if you have even
the smallest inkling in programming languages.

Now, go and [read the lecture notes and do the labs](https://school.racket-lang.org/2019/plan/)!
