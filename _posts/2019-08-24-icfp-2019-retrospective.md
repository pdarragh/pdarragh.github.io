---
layout: post
title: "ICFP 2019 Retrospective"
date: 2019-08-24 14:31:21 +0200
categories: conferences
---

This year was my first time attending the [ACM SIGPLAN International Conference
on Functional Programming](https://icfp19.sigplan.org) in Berlin, Germany. It
was an amazing opportunity to learn about a lot of cutting-edge research in
programming languages, but I also capitalized on my time and made a lot of new
friends and acquaintances along the way.

## Racketfest

Prior to the main ICFP conference was a smallish conference known as
[Racketfest](https://racketfest.com) --- a celebration of all things
[Racket](https://racket-lang.org). We had a keynote and four talks this year:

**"Language-Oriented Programming the Racket Way" --- Matthew Flatt (Keynote).**
Matthew explained the Racket philosophy: instead of struggling to find out how
to solve your problem in an existing language, simply build the right language
for the job.

**"Privacy-Hardened Languages in Racket" --- Kristopher Micinski.** Kris
explained the principles of *faceted execution* (a technique for segregating
data's properties based on the current user) and how he integrated these ideas
into a new `#lang` for Racket called Racets.

**"Small, Elegant, Practical: The Benefits of a Minimal Approach" --- Prabhakar
Ragde.** Prabhakar is a lecturing faculty at Waterloo University who spends a
lot of time focusing on how to improve his introductory courses. Waterloo is
notable for being one of the few schools where Racket is used as students' first
language. This talk emphasized the utility of a small core language for
education.

**"A Normalizing `#lang`" --- David Thrane Christiansen.** David works at
Galois, a Portland-based company usually noted for primarily using Haskell.
For this talk, David explained how to convert an evaluator to a normalizer --- a
useful technique for certain theoretical applications (such as implementing a
proof assistant).

**"The Heresy Programming Language, or: Learning through Madness" --- Annaia
Berry.** Annaia walked through her process implementing the Heresy `#lang`: a
BASIC dialect with a very Lispy flavor. She talked a lot about the process of
implementing language features "the wrong way" and how sometimes doing things
the wrong way is the best way to learn how to do it the right way.

After the talks, we went to lunch at a local market and got to know each other
over good food. Then we returned to the venue and enjoyed an informal "office
hours" where attendees could talk to the presenters and ask for their input on
various ideas. Overall, Racketfest was hugely fun and I'm glad I was able to go.

## PLMW

The Sunday before ICFP, there are a number of workshops that people can attend.
This year, I chose to go to the Programming Languages Mentoring Workshop (PLMW),
a workshop intended primarily for PhD students and soon-to-be PhD students. Most
attendees of PLMW are there on a scholarship offered by the conference, which I
think is very cool (although I was not one of them).

The first couple of talks were essentially digests of research presentations.
We had Sam Lindley from the University of Edinburgh and Imperial College London
talk about his work in effect handlers, and then we learned about refinement
types and Liquid Haskell from Niki Vazou of IMDEA (a research institute based in
Spain). (Of course since I love all things types, I liked the latter quite a
lot!)

The remainder of the talks were less technical:

- Amal Ahmed (Northeastern University) talked about how to manage your time well
  during the early phases of your PhD, as well as how to find an advisor who
  works well with you.
- Kathleen Fisher (Tufts University) gave information about how to manage a good
  work-life balance during your PhD and throughout an academic career.
- Ilya Sergey (Yale-NUS College) talked about the far-reaching implications of
  "functional** programming in industry and in academia.
- Derek Dreyer (Max Planck Institute and ICFP 2019 General Chair) gave a talk
  about how to give a talk that people can follow, which had a lot of good
  points that I might write up some time.

Following the talks (which included lunch and breaks), we had an opportunity to
get to know each other better through a competition! We were split into teams of
five and given a set of 20 algorithms implemented in different (and often
uncommon) languages, which we had to identify from a list of options and race to
submit the correct answers. At the end of the competition, there was a tie for
first and a tie for third, so a tiebreaker was held. My team ended up winning
our tiebreaker (no thanks to me) and we finished third! As reward, we all got
IMDEA-branded stainless steel water bottles.

The last PLMW event was a panel moderated by Simon Peyton Jones. Panel members
included Satnam Singh (who had been in academia but moved to industry with
Google), Zoe Paraskevopoulou (a PhD student at Princeton), Jeremy Gibbons
(Oxford and editor-in-chief of the Journal of Functional Programming), Andrey
Mokhov (Newcastle University), and Amal Ahmed (Northeastern). In addition, many
other veterans of the field chipped in with their responses to questions. In
retrospect, I probably should've taken notes on all the good questions!

## Morning Keynotes

Each day of the main conference (Monday--Wednesday** started with a keynote. I
believe these will be uploaded at some point. The talks were:

- Monday: "Blockchains are Functional" --- Manuel Chakravarty (Tweag I/O)
- Tuesday: "Solver-Aided Programming for All" --- Emina Torlak (University of
  Washington)
- Wednesday: "Derivations as computations" --- Andrej Bauer (University of
  Ljubljana)

I most enjoyed the second keynote. Emina talked a lot about the Rosette `#lang`,
which is often considered an exemplar of Racket's capabilities.

## Technical Talks

Of course the main meat of ICFP is the technical talks! These were all recorded
and will be made available at some point, but a few in particular stood out to
me. I'll just give some brief highlights here from the main conference:

**Rebuilding Racket on Chez Scheme (Experience Report).** The Racket team has
been working for a while on moving their code base from mostly C to Chez Scheme.
Although performance has suffered slightly in most cases (some 3% increase in
execution time), the team considers the endeavor to have been mostly useful due
to significant improvements in maintainability.

**Approximate Normalization for Gradual Dependent Types.** While I didn't pay
much attention to the normalization aspect of this talk, I really loved their
effort in building gradual dependent types. Dependent types are useful but a bit
much to be used everywhere in regular programming, so providing the ability to
only use them sometimes (i.e., *gradually*) is a huge boon to the user
experience. The PI for this work was Ronald Garcia at UBC, who is on my
shortlist for potential advisors (which I'll talk more about in a blog post
soon, I think).

**Selective Applicative Functors.** Haskell has support for varying levels of
abstraction leading up to monads (functors, applicatives, monads), and this team
believes they've identified a deficiency in this hierarchy. To solve this, they
introduced the *selective*, which sits between applicatives and monads.

**Teaching the Art of Functional Programming Using Automated Grading (Experience
Report).** McGill University has been testing an online student homework suite
called Learn-OCaml. This software is intended as an automated grader which can
also offer feedback and suggestions to students so they can improve without
needing to wait until after grading. This paper was an evaluation of the first
year or so of using this software in introductory courses at McGill.

**The future of OCaml PPX: towards a unified and more robust ecosystem (OCaml
Workshop).** While I don't use OCaml as an everyday language, I thoroughly
enjoyed listening to the ideas going around for improving its metaprogramming
facilities.

**Functors and Music (Demo at FARM).** This was an extremely impressive demo
that showed off a Haskell DSL for making music. The author showed how to write a
new song live. It was really a very impressive demo! I really liked this one.

## Faculty Search

Of course, a large motivation in attending ICFP this year was to meet faculty
who I might like to work under for my PhD. I had a list of people I wanted to
talk with prepared before I arrived, but I also capitalized on any opportunity
to meet people I hadn't expected to. In general, everybody I spoke to was
incredibly supportive and willing to chat about my interests and whether they
felt they might be a good match for me (and often who else I should talk to who
might fit better!).

While I talked to many faculty during my time at ICFP, there are some people who
I had more specific conversations with about my intended focus of research
and/or the PhD application process. Many thanks to the following people for
helping me in this regard:

- Dan Friedman (Indiana University)
- Ryan Newton (Indiana University)
- Chung-chieh Shan (Indiana University)
- Sam Tobin-Hochstadt (Indiana University)
- Kris Micinski (Syracuse University)
- Amal Ahmed (Northeastern University)
- Kathleen Fisher (Tufts University)
- Norman Ramsey (Tufts University)
- William Bowman (University of British Columbia)
- Ronald Garcia (University of British Columbia)
- Cyrus Omar (University of Michigan)
- Matthew Flatt (University of Utah) (he couldn't escape me even here!)
- David Darais (University of Vermont)

(Names are grouped by university in alphabetical order.)

## Other Fun

I attended a lot of technical talks, but I also wanted to make the most of my
short time in Berlin! I was fortunate to make some good friends throughout the
conference, and together we managed to have a really good time. We ate good
food, saw some history (such as the Berlin Wall Memorial, among others), and
otherwise enjoyed one another's company. Special thanks especially to my new
Twitter and conference BFF [Paulette Koronkevich](https://koronkevi.ch)
([@koronkebitch](https://twitter.com/koronkebitch)) who introduced me to many
other people and was generally great to explore with.

---

On Monday night, we organized a group to go to a local comedy show where one of
the conference attendees (Joachim Breitner / [@nomeata](https://twitter.com/nomeata))
was performing. We had a great time and loved the comedy --- plus we went to get
some very good burgers afterwards!

---

On Wednesday, I went with my new friends Madelyne
([@madxiaodisease](https://twitter.com/madxiaodisease)) and Clark
([@CRY3rn](https://twitter.com/CRY3rn)) to check out a tour of some Cold War
bunkers. We missed the tour by a few minutes, but we still managed to have a
good time seeing some of the sights. We saw the Berlin Wall Memorial, the
Reichstag, Brandenburg Gate, and the Memorial to the Murdered Jews of Europe.
Berlin is rich with history, and I'm glad we were able to make some time to see
at least a part of it!

---

Thursday morning, Paulette and I decided we wanted chocolate (because who
doesn't want chocolate), so we went to Rausch Schokoladenhaus and WOW was it
worth the visit. On the third floor, there's a cafe that specializes in
various chocolate-based desserts. We had a great time trying the creme brulee, a
raspberry torte, an eisschokolade ("ice chocolate"), and other small pieces here
and there. I picked up a few things to take home, which I'm looking forward to
enjoying with my friends there!

---

Then, on Thursday night, there was an industry reception with speakers from
Galois, Jane Street, Google, Facebook, and ahrefs. I ended up having a great
conversation with Yaron Minsky, Jane Street's CTO, with a group of other
students for a couple hours, which I really enjoyed. He had a lot to say about
OCaml, functional programming in industry, and lots of other things along the
way.

---

Friday afternoon, I had the good fortune to end up at a lunch table with Yaron
Minsky (Jane Street's CTO), Kathleen Fisher (professor at Tufts University), and
Simon Peyton Jones (a heavyweight in PL research for a few decades now, who
works at Microsoft Research at Cambridge). We talked about a lot of things, but
especially interesting was our discussion regarding the representation of women
in STEM (and CS specifically) both in industry and in academia. I really
appreciate that they were so willing to let me join in the discussion with them
despite none of them knowing me (except Yaron, who I'd only met the night
before).

## Parting Thoughts

Overall, I am **so** happy that I attended this conference. I really had a great
time meeting everyone and learning so much about what's happening in this field.
More than anything, this has solidified my resolve to go after my PhD and work
on things like this.

I would like to specifically give thanks to my (now former) PI, Michael Adams,
who was kind enough to fund this journey. I often say I wouldn't be where I am
now without his help and support over the past few years, but his willingness to
send me to Germany to learn from all these other great people will forever stand
apart. Thanks for everything, Michael!

Also, thanks to my new PI, Eric Eide, for letting me disappear for a week and a
half less than a month after starting with his group. I really appreciate it!

Lastly, you may have noticed, but there are a few Twitter handles in the above
text. It turns out that programming languages people are very active on Twitter!
It's a great way to organize and stay in touch. (If you read this and want to be
friends, feel free to follow me [@_pdarragh](https://twitter.com/_pdarragh)!)

Overall, ICFP 2019 was really great. Thanks to everybody who contributed to
making it such an amazing and memorable experience. I can't wait to see you all
next year!
