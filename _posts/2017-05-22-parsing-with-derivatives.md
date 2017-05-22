---
layout: post
title: Parsing with Derivatives
date: 2017-05-22 02:01:00
categories: viper programming-languages parsing
---

Recently, I wrote about my [lexing strategy for Viper](/blog/2017/05/17/lexing-viper/). I think I've got enough of it
worked out that I can begin moving on to the parsing phase of Viper's development (at least for a bit). Or at least, the
tests all pass at the moment and I can convert text into a stream of lexemes, so... I think it should be fine, haha.

It turns out... there are *a lot* of different ways to parse lexemes into an abstract syntax tree. I've not written a
parser before, so I asked a few faculty in my department for their ideas. After looking a little bit into each of the
suggestions I was given, I decided to go with
[Parsing with Derivatives (PDF)](http://matt.might.net/papers/might2011derivatives.pdf). The author, Dr. Matt Might, was
a professor at my school until very recently, [when he left us to go to the University of Alabama at Birmginham's School
of Medicine](https://www.uab.edu/medicine/news/latest/item/1411-white-house-strategist-to-lead-uab-s-personalized-medicine-institute).
Which is a bummer, because I never got to take his famous compilers class... but oh well. I think this will lead him to
where he needs to go, so I'm happy for him — though a little disappointed for myself!

The gist of parsing with derivatives is actually incredibly simple. Let's assume we have a language and a sequence of
tokens for which we want to test membership. We merely take the derivative of the language with respect to each token in
the sequence, and if the resulting language contains the null string then our sequence is valid! (I'll explain these
parts in further detail below.)

## Taking the derivative of a language
 
Imagine you have a language, $$ L $$, which consists of some set of tokens. (Often languages are described in terms of
"strings", but really it doesn't matter.) For the sake of argument, let's imagine that we have an alphabet $$ A $$ which
gives us the following valid tokens:

| `a` | `b` | `c` |

And let's say that our language $$ L $$ contains all three-token sequences for `a`, `b`, and `c`:

| `aaa` | `baa` | `caa` |
| `aab` | `bab` | `cab` |
| `aac` | `bac` | `cac` |
| `aba` | `bba` | `cba` |
| `abb` | `bbb` | `cbb` |
| `abc` | `bbc` | `cbc` |
| `aca` | `bca` | `cca` |
| `acb` | `bcb` | `ccb` |
| `acc` | `bcc` | `ccc` |

PWD is built on a concept called a *language derivative*, which was originally defined in a 1964 paper published by
[Janusz Brzozowski](https://en.wikipedia.org/wiki/Janusz_Brzozowski_(computer_scientist)) titled ["Derivatives of
Regular Expressions"](https://doi.org/10.1145%2F321239.321249). The author takes a language $$ L $$ and defines its
derivative with respect to a character $$ c $$ (or token, in our case) as the result of filtering $$ L $$ to only those
sequences which *begin* with $$ c $$, and then removing the initial $$ c $$ from those sequences. The resulting language
is called $$ D_c(L) $$ — the derivative of $$ L $$.

Let's stick with our $$ L $$ and walk through an example. I'm going to take the derivative of $$ L $$ with respect to
the token `a`. First we filter so we only have sequences which start with `a`:

| `aaa` | `aba` | `aca` |
| `aab` | `abb` | `acb` |
| `aac` | `abc` | `acc` |

and *then* we "chop" (remove) the initial `a` from each of those:

| `aa` | `ba` | `ca` |
| `ab` | `bb` | `cb` |
| `ac` | `bc` | `cc` |

This resulting set of sequences is called $$ D_a(L) $$.

## Testing membership

So... what does all of this get us?

Well, let's imagine we have a set of sequences which we would like to be able to recognize with our parser. We don't
want to accept *all* of $$ L $$ as valid parses. So, for example, let's say we want to accept `aaa`, `abc`, and `aac`. I
will call this smaller subset of sequences $$ L_1 $$. Mathematically, we can say: $$ L_1 = \{aaa, abc, aac\} $$.

Now, we receive a sequence of tokens $$ S $$. What we're going to do is iterate through $$ S $$ and progressively take
the derivatives of $$ L_1 $$ with respect to each token in $$ S $$. If at the end of iterating through $$ S $$ we have
the empty string in our language, then the parse was successful!

(I'll explain more about empty strings and "nullability" in a bit. Just hang tight!)

So, let's imagine that $$ S $$ is the sequence `aac`. Our first step is to derive $$ L_1 $$ with respect to `a` — the
first token in the sequence. Well as we know, that's just $$ L_1 $$ but limited to only those sequences which start with
`a`, and then we remove the beginning `a` tokens. So $$ D_a(L_1) = \{aa, bc, ac\} $$.

Now we have `ac` left to parse in our sequence $$ S' $$. So we pop off the next character — another `a` — and take the
derivative again. This time we're left with $$ D_a(L_1') = \{a, c\} $$ (where $$ L_1' = D_a(L_1) $$, to be clear).

Finally, we have only `c` left in $$ S'' $$. So we're going to take the derivative of $$ L_1'' $$ with respect to `c`...
which gives us $$ D_c(L_1'') = \{\} $$.

So... now what? How do we know from just the empty set whether our parse was successful? You and I know that prior to
the chopping stage, the derivative had filtered the language down to $$ \{c\} $$. But how do we now know that we're
done?

Enter "nullability".

## Nullability

Essentially, we have two kinds of empty sets: one which indicates "No, this parse was not successful", and one which
says that the parse was accepted. The former is a result of an unsuccessful filtering, and the latter of a successful
filtering and chopping.

In his paper, Brzozowski names these two languages the *empty language* $$ \varnothing $$ and the *null language*
$$ \epsilon $$ (in the original paper the symbols used were $$ \phi $$ and $$ \lambda $$, but I'm going to use Dr.
Might's notation). Whereas $$ \varnothing $$ indicates a language which contains no elements ($$ \varnothing = \{\} $$),
$$ \epsilon $$ is the language which contains only the empty string, `""`.

A concise, mathematical definition would require further background from the paper than I intend to discuss here.
However, simply put: if a derivative with respect to a particular token is successful, and if the language allows for a
termination at that point, then the result of the derivative includes $$ \epsilon $$. If, on the other hand, the
derivative was *not* successful, then the result is $$ \varnothing $$.

## Putting it all together

Now let's revisit our language $$ L_1 = \{aaa, abc, aac\} $$. We're going to do two parses over it: $$ S_1 = aac $$, and
$$ S_2 = aax $$.

We can see that both $$ S_1 $$ and $$ S_2 $$ start with `aa`, so we're going to take two derivatives of $$ L_1 $$ with
respect to `a`: $$ D_a(D_a(L_1)) = L_1'' = \{a, c\} $$.

We'll do $$ S_1 $$ first, so the next token will be `c`. $$ D_c(L_1'') = \epsilon $$, because the filter-and-chop was
successful. A result of $$ \epsilon $$ means the parse was successful!

Now with $$ S_2 $$, we get back $$ D_x(L_1'') = \varnothing $$. Our parse failed.

## Odds and ends

Unfortunately, things are always simpler in theory than in practice with stuff like this. While parsing with derivatives
is perfectly adequate for regular languages, context-free languages can pose a serious problem for the implementation.
Infinite recursions pop up easily, so a few strategies were introduced to resolve the issues. This led to what might be
called "very poor" performance. From Dr. Might's paper:

> The implementation is brief. The code is pure. The theory is elegant. So, how does this perform in practice? In brief,
> it is awful.

He later collaborated with Michael Adams and Celeste Hollenbeck to produce a paper titled ["On the complexity and
performance of parsing with derivatives"](http://dx.doi.org/10.1145/2908080.2908128) which went on to significantly
improve the performance of the technique. (Incidentally, it was Michael who pointed me to parsing with derivatives in
the first place!)

I like the idea behind parsing with derivatives, though, so I'm going to try to use it for implementing Viper's parser.
I'm sure I'll write about it plenty in the coming posts, so stay tuned!
