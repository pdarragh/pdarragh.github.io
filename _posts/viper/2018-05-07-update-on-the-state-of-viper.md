---
layout: post
title: "An Update on the State of Viper"
date: 2018-05-07 15:19:00 -0600
categories: viper programming-languages
---

It's been quite a while since I've written about the programming language I'm working on, Viper. I figure it's about 
time for me to delve into the changes that have happened over the past year or so (especially in the last six months),
so this post will serve as a brief overview of the current state of development!

## Lexing

I [previously wrote]({% post_url /viper/2017-05-17-lexing-viper %}) about how I implemented Viper's lexer. Although 
there have been 320+ commits since that post, I have made relatively few changes to this portion of the language
implementation, but I will highlight the main advancements.

Where before I had only seven classes of lexemes, I now have 18. These additional lexeme types are useful in expanding
the capabilities of the grammar. I added special lexemic forms for various possible symbols, such as dedentation, some
punctuation, and reserved words.

Otherwise, the lexing system is more or less the same as before. I have not implemented a maximal munch-style lexer as 
yet because I can't decide if that's the way I want to go (although it does seem to be the most popular method, so
perhaps I ought to just for the sake of consistency).

## Parsing

Parsing is where the vast majority of work has gone in the past half-year. Since my last writing, I completely rewrote
my implementation of Might's "Parsing With Derivatives". Now it is correct, though somewhat incomplete as I did not
implement memoization to compute the least fixed point. (Effectively, this means that I cannot write left-recursive
grammars, I think.) However, I did extend PWD to have a couple extra convenience forms to make certain kinds of
grammatical specifications easier to express. I will write more about this new PWD implementation in a future post.

I wrote a script which generates abstract syntax tree (AST) node classes from the grammar file. This took the better
part of a week and is probably also deserving of its own blog post.

Instances of the AST classes are dynamically generated during parsing by the updated PWD implementation. (Specifically,
they come up when an epsilon term is generated and parsed.) The end result of this is that a successful parse yields an
AST on its own, with no extra information. (This is not particularly remarkable, but it is a good measure of how far my
parsing system has come!)

## Other

I made some other adjustments:

- changed the format of the grammar file
- implemented an "interactive mode" to help with tests
- extended testing significantly
- restructured the project

## Future work

There is still work to be done. My parser now works correctly, but there are some things I would like to implement for 
it. Specifically, I would like to be able to provide good error messages (which is currently not an easy feat in PWD). I
would also like to try to support non-deterministic parsing, meaning that all potential parses of a sentence would be
returned. Lastly, I would like to try to suggest potential solutions for invalid parses to the user automatically.

I also need to really solidify the syntax/semantics of the language in general. So far, I have been working with a
relatively small grammar because it makes testing easier, but I need to expand the grammar to include the features I
want to be able to support. (For example, I only recently added forms for if/else branches.) This will involve a lot of
design, and I intend to discuss many of these decisions through future blog posts.

Once the syntax is somewhat more determined, I can start working on a simple interpreter. I want the interpreter to get
going so I have something to play with to determine whether the language is headed in the right direction.

After the basic interpreter implementation, I will start on the type system. This should hopefully be fairly
straightforward, since I am making the language statically typed and I am avoiding type inference (for now, at least).
I may have to come up with something clever to simultaneously support OO-style inheritance and true algebraic data types
at the same time.

I think after that all that will be left is refining the language. I doubt very much whether my first complete
implementation will be quite what I want, so I expect to adjust it over time.

I may or may not eventually implement a true compiler. The original plan was to compile to Python, but I'm not sure
that that's really worth my time. I may try to compile to LLVM or something, but I haven't really thought about it too
much yet since that's still so far away.
