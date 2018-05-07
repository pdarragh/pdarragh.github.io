---
layout: post
title: Lexing Viper
date: 2017-05-17 13:31:00 -0600
categories: viper programming-languages lexing syntax
---

After settling on [Viper](https://github.com/pdarragh/Viper)'s syntax (at least somewhat), I decided to set about
building a lexer. I've never written one of these from scratch before, so it was a learning experience (which is true of
pretty much this whole project, really). When writing it I wasn't overly concerned with performance; I don't mind if
it's considered "slow", at least for now. Maybe eventually I'll write a better one, but for now this is what I've got.

For some background, a lexer is a program which takes in some arbitrary text and divides it up into various tokens,
called lexemes. You then use the lexemes to perform a *parse* of the text. So an analogy in English might be that lexing
is breaking up the words in a sentence by looking for whitespace, but you also separate punctuation into separate
lexemes in your head — after all, the period at the end of a sentence isn't literally part of the last word of the
sentence, right?

Lexing has nothing to do with determining the *meaning* of a set of tokens, though. It's purely about splitting the
tokens up. The meaning will come later.

Viper's [lexer](https://github.com/pdarragh/Viper/blob/master/viper/lexer.py) has a few different modes of operation:

* Lex some arbitrary text (newlines included)
* Lex a file
* Lex a line
* Lex a token (no spaces)

The first two modes handle splitting the input text into separate lines. They then pass these lines along to the third
mode, which splits the lines based on whitespace. Finally, the individual tokens are passed to the fourth mode to be
turned into `Lexeme` objects, and at the end of it we get a list of lexemes.

## Lexemes

The `Lexeme` objects for Viper can be subdivided as:

* `Indent` — four spaces
* `NewLine` — the end of a line (or beginning of another line, depending on perspective)
* `Comma` — a separator (not allowed to be used in operators)
* `Number` — integers, floats, scientific notation
* `Name` — a lowercase name of a function or variable
* `Class` — an uppercase name of a class or type
* `Operator` — a combination of symbols

From my understanding, most lexers use regular expressions to determine which tokens belong to what class of lexeme. I'm
fairly familiar with regular expressions, so this part wasn't too bad. The `Indent`, `NewLine`, and `Comma` lexemes were
all very straightforward to implement; they're either individual characters (like the comma `,` and newline `\n`) or
they're a sequence of spaces at the front of a line (the indent).

### Numbers

The `Number` took a little more work, but I mostly copied the rules for Python's own lexer to write it (since I intend
to support the same numerical representations):

{% highlight python %}
RE_NUMBER = re.compile(r'(?:\d+)'                           # 42
                       r'|'
                       r'(?:\.\d+(?:[eE][+-]?\d+)?)'        # .42 | .42e-8
                       r'|'
                       r'(?:\d+[eE][+-]?\d+)'               # 42e3
                       r'|'
                       r'(?:\d+\.\d*(?:[eE][+-]?\d+)?)')    # 42.7e2 | 42.e9 | 42. | 42.3e-8
{% endhighlight %}

### Names

`Name` lexemes were a little tricky. I wanted to enforce that all function and variable names had to start with either
an underscore or else a lowercase letter. (Haskell enforces the lowercase/uppercase distinction, and I find it
useful there.) I also wanted the ability to separate either by underscore or by hyphen, and then I wanted the name to be
able to end with certain symbols such as `?` or `!` (like in Scheme).

The end result is a rather complicated-looking regex:

{% highlight python %}
RE_NAME = re.compile(r'_+|(?:_*[a-z][_a-zA-Z0-9]*(?:-[_a-zA-Z0-9]+)*[!@$%^&*?]?)')
{% endhighlight %}

Essentially, a "name" is either a string of underscores, or else it's a series of characters which:

* May start with any number of underscores (or not)
* Followed by a lowercase letter
* Followed by any number of letters, numbers, or underscores
* Followed by any number of similar constructions, but beginning with a hyphen
* Optionally followed by a symbol, such a `!`, `@`, `?`, etc (though not all symbols are supported, such as parens)

| Valid Names   | Invalid Names |
|---------------|---------------|
| `foo`         | `Foo`         |
| `_foo`        | `FOO`         |
| `_`           | `_Foo`        |
| `___`         | `_FOO-BAR`    |
| `__foo_bar`   | `-foo`        |
| `foo-bar`     | `foo-?`       |
| `foo?`        | `?-foo`       |
| `foo-bar!`    | `!foo-bar`    |

### Classes

The `Class` lexeme (which will also represent types) is a bit simpler:

* Start with a capital letter
* Followed by any number of letters, numbers, or underscores
* Followed by any number of similar constructions, but beginning with a hpyen

Here's the Python regex for it:

{% highlight python %}
RE_CLASS = re.compile(r'[A-Z][_a-zA-Z0-9]*(?:-[_a-zA-Z0-9]+)*')
{% endhighlight %}

| Valid Classes | Invalid Classes   |
|---------------|-------------------|
| `FOO`         | `_FOO`            |
| `Foo`         | `foo`             |
| `FOO_BAR`     | `_foo`            |
| `FOO-BAR`     | `-foo`            |
| `FooBar`      | `Foo?`            |
| `Foo_Bar`     | `fOO`             |
| `Foo_Bar_`    |                   |

### Operators

The last type of lexeme for Viper is the `Operator`. This represents the various symbols which, as you may have guessed,
can constitute operators in Viper.

I wanted the language to be customizable in this respect, so I tried not to restrict the possible symbols for operators
more than I had to. Here's the regex I ended up with:

{% highlight python %}
RE_OPERATOR = re.compile(r'[!@$%^&*()\-=+|:/?<>\[\]{}~.]+')
{% endhighlight %}

As you can see, you can pretty much stick any symbols together to form a new operator. There are no restrictions on, for
example, whether the parentheses need to be balanced or something. (Whether this will end up being a point of pain for
me remains to be seen, haha.)

## Ambiguity

Of course, there are some potential sources of ambiguity in the language. For example, consider the token `foo?!bar`.

Is this the same as `foo ?! bar`, or should it be lexed as `foo? ! bar`? I opted to take the
[maximal munch](https://en.wikipedia.org/wiki/Maximal_munch) approach: we look for the longest potential tokens from
left to right. The end result is that the above example would be correctly parsed as `foo? ! bar` (where `!` is used as
an operator).

## Regex Matching Chain in Python

Unfortunately, Python's regex library `re` is a little difficult to deal with when you want to make a bunch of
comparisons to a single token.

Consider you have a token, `token`, and a set of regular expressions, say `RE_1`, `RE_2`, and `RE_3`. These regular
expressions have parenthetical groups inside them that you would want to extract from if `token` matches.

The regular way of doing this in Python is roundabout and somewhat convoluted:

{% highlight python %}
RE_1 = re.compile(r'...')
RE_2 = re.compile(r'...')
RE_3 = re.compile(r'...')

def identify_token(token):
    match = RE_1.fullmatch(token)
    if match is not None:
        return Lexeme_1(match.group(1))
    match = RE_2.fullmatch(token)
    if match is not None:
        return Lexeme_2(match.group(3))
    match = RE_3.fullmatch(token)
    if match is not None:
        return Lexeme_3(match.groups())
    raise UnimplementedError
{% endhighlight %}

As you can see, this is repetitive and not very useful. Why do we have to keep assigning a new `match` variable? I
looked around and eventually found
[this solution](http://code.activestate.com/recipes/456151-using-rematch-research-and-regroup-in-if-elif-elif/).
However, I decided to rework it a bit to fit with my style more.

The basic idea is to create a class which you can use to do the comparisons. This class will return a truthy value if
the match is successful. The end result is that you can use a simpler if/else system to achieve more readable code.

My class ended up looking like this:

{% highlight python %}
class RegexMatcher:
    def __init__(self, token):
        self._token = token
        self._match = None

    def fullmatch(self, pattern: PatternType):
        self._match = pattern.fullmatch(self._token)
        return self._match

    def group(self, grp: Union[int, str]):
        return self._match.group(grp)
{% endhighlight %}

It's not very lengthy, which I think is good. (You'll also notice that I like to use Python 3's type annotations, though
those can be left out if desired.) Now to use it, simply do:

{% highlight python %}
def identify_token(token):
    matcher = RegexMatcher()
    if matcher.fullmatch(RE_1):
        return Lexeme_1(matcher.group(1))
    elif matcher.fullmatch(RE_2):
        return Lexeme_2(matcher.group(3))
    elif matcher.fullmatch(RE_3):
        return Lexeme_3(matcher.group(0))
    else:
        raise UnimplementedError
{% endhighlight %}

Maybe it doesn't look like much to you, but I prefer this version considerably. It just makes more sense to me. So...
that's what I went with!

## Summary

In conclusion, I have a lexer now. It appears to run correctly (or so my tests would indicate, I think), so I'm happy
with it. I imagine it'll change somewhat over the coming months as I work more on Viper, but for the moment it's solid
and that's what I wanted.

Stay tuned for more development on Viper!
