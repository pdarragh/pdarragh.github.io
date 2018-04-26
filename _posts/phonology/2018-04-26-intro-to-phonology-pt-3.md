---
layout: post
title: "Introduction to Phonology, Part 3: Phonetic Features"
date: 2018-04-26 01:35:00
categories: phonology linguistics phonetics
---

In [the previous post]({% post_url /phonology/2018-04-11-intro-to-phonology-pt-2 %}), I covered most of the basics of
phonetics concerning how we can describe speech sounds, or "phones". Specifically, I talked about two sets of aspects
(one for vowels and one for consonants), and how some of these can be subdivided. Next, I'll talk a little more about
these subdivisions (and some more than I left out last time).

It's a little messy to deal with separate features for vowels and consonants, so instead we consider that all features
can apply to *any* sound, and that each feature has a specification of either *positive* or *negative*. For the purposes
of this post, we will assume that all sounds have specifications for *all* features.

The full feature list can be divided into four broad groups: **major class features**, **manner features**,
**place features**, and **laryngeal features**. I will discuss the groups in broad terms, and then I will go into a bit
more depth with each feature. For each feature, I will provide a listing of the phones that are considered to have a
positive specification for that feature. These listings are images taken from
[this document about the phonological features](/assets/files/phon_features_and_ipa.pdf) (PDF), which was provided to
students in my phonology class taught by Dr. Aaron Kaplan at the University of Utah, though I do not know if he wrote it
himself.

## How to discuss features

I mentioned above that phones can be specified in terms of *positive* and *negative* values for all features. When we
write about a sound's features (or about how a feature relates to a sound), we write the feature in brackets with a +
or - to indicate its value. For example, the *voiced velar stop* [g] is [+voiced], [+dorsal], [+high], among other
things.

When a phone has multiple feature specifications that we are interested in talking about, we produce a *feature matrix*.
[g] could be [+voiced, +dorsal, +high]. (Often, in literature, these are written in a vertical fashion with the brackets
extending the length of the stack, but for brevity's sake I will stick to in-line matrices.)

Additionally, all features have a shorthand name. [g] is [+voi, +dor, +hi]. This is done simply to save space. I will
provide the shorthand names for all features in this post, though I will stick to the full names for my discussion.

## Major class features

There are four major class features:

- syllabic
- vocalic
- approximant
- sonorant

(The document I linked above lists 8, but I have separated the manner features from these.)

These four features don't have much in common physically, but they guide the overall "type" of a phone.

### [syllabic] / [syl]

[![Syllabic Phones](/assets/images/phonology/feat-syllabic-trans.png)](/assets/images/phonology/feat-syllabic.png)

[+syllabic] sounds are those which may function as the *nucleus* of a syllable. I will avoid an in-depth discussion of
prosody (syllables 'n' stuff) for now, but the basic gist is that these sounds can be the "center" of a syllable. By
default, only vowels are [+syllabic], and all consonants are [-syllabic].

However, sometimes certain consonants can become [+syllabic]. In English, we sometimes find [ɹ] (the "r" sound in "her"
and "red") becomes syllabic. For example, consider the word "fire". Some people pronounce this as a single syllable,
but I pronounce it as two: ['faɪ.ɹ] (where the . in the middle denotes the separation of two syllables, and the leading
single-quote ' precedes the stressed syllable). However, when dealing with some languages (such as English) this is
often instead transcribed into IPA as ['faɪ.əɹ].

### [vocalic] / [voc]

[![Vocalic Phones](/assets/images/phonology/feat-vocalic-trans.png)](/assets/images/phonology/feat-vocalic.png)

The vowels and glides (or "semi-vowels") are considered [+vocalic], and all other sounds are [-vocalic]. This feature
exists primarily to distinguish the glides from other consonants due to their similarity to vowels. (Glides are
essentially just vowels that want to be consonants.)

### [approximant] / [approx]

[![Approximant Phones](/assets/images/phonology/feat-approximant-trans.png)](/assets/images/phonology/feat-approximant.png)

[+approximant] phones are a superset of the [+vocalic] phones. [+approximant] applies to all of the
[approximants]({% post_url /phonology/2018-04-11-intro-to-phonology-pt-2 %}#approximants), which includes vowels,
liquids (e.g. [l], [r], [ɹ]), and glides (e.g. [w], [j]). All other sounds are [-approximant].

### [sonorant] / [son]

[![Sonorant Phones](/assets/images/phonology/feat-sonorant-trans.png)](/assets/images/phonology/feat-sonorant.png)

[+sonorant] are another superset, this time of the [+approximant] phones. [+sonorant] additionally includes nasal
consonants. (Specifically, "sonorant" refers to any speech sound which produces a non-turbulent airflow.)

## Manner features

There are also four manner features:

- continuant
- lateral
- nasal
- strident

These features are used to describe how the articulators are used to modify the airflow as it comes out from the lungs.
The combination of these four binary manner features produces the seven
[manners of articulation]({% post_url /phonology/2018-04-11-intro-to-phonology-pt-2 %}#manner-of-articulation) that I
detailed in the previous post.

### [continuant] / [cont]

[![Continuant Phones](/assets/images/phonology/feat-continuant-trans.png)](/assets/images/phonology/feat-continuant.png)

The phones which are [+continuant] involve a partial occlusion of the airway, meaning your mouth might be mostly
closed or your tongue may be blocking the airflow, or a few other things. Air must flow over a period of time; that is,
the airflow is *continuous*. All vowels, glides, liquids, and fricatives are [+continuant]. Stops, affricates, and
nasals are [-continuant]. Data are inconclusive for laterals, taps/flaps, or trills.

### [lateral] / [lat]

[![Lateral Phones](/assets/images/phonology/feat-lateral-trans.png)](/assets/images/phonology/feat-lateral.png)

The [+lateral] sounds are those which involve air flowing around the sides of the tongue (instead of over the top of
it). The lateral approximants and fricatives are [+lateral], and other sounds are [-lateral]. (There are also lateral
clicks which appear only in African languages, but these are not detailed in the charts on this page because I am only
discussing sounds with a [pulmonic egressive airflow]({% post_url phonology/2018-04-11-intro-to-phonology-pt-2 %}#airstream-mechanisms).)

### [nasal] / [nas]

[![Nasal Phones](/assets/images/phonology/feat-nasal-trans.png)](/assets/images/phonology/feat-nasal.png)

[+nasal] sounds allow air to escape through the nasal cavity (nose). Most sounds are [-nasal], but the stops indicated
above are all [+nasal].

### [strident] / [stri]

[![Strident Phones](/assets/images/phonology/feat-strident-trans.png)](/assets/images/phonology/feat-strident.png)

Sounds which are [+strident] are characterized by high-frequency noise. All affricates are [+strident], and fricatives
at the following places of articulation are also [+strident]: labiodental, alveolar, palato-alveolar, retroflex, and
uvular. All other sounds are [-strident].

## Place features

There are eleven total place features (including the dependent features). Place features describe where in the mouth the
primary articular is positioned to produce a particular sound. The place features are:

- labial
  - round
- coronal
  - anterior
  - distributed
- dorsal
  - high
  - low
  - back
- pharyngeal
  - ATR

The indentation of certain features indicates *dependent features*. A dependent feature, such as **round**, can only be
given a specification if its parent feature has a *positive* specification. So a sound which has a [-labial]
specification cannot be [+round] or [-round]. "Well that seems weirdly selective," you might say --- and you'd be right!
But that's the way it goes. There is more theory to this which will be talked about in a later blog post.

I will list dependent features as subheadings of their parent features.

### [labial] / [lab]

[![Labial Phones](/assets/images/phonology/feat-labial-trans.png)](/assets/images/phonology/feat-labial.png)

The [+labial] phones are those which require use of the lips to produce, which corresponds to the *labial* and
*labiodental* places of articulation detailed in the previous post. Additionally, glides and vowels are considered to be
[+labial] since they can have a [round] specification.

[labial] has one dependent feature: [round].

#### [round] / [rnd]

[![Labial/Round Phones](/assets/images/phonology/feat-round-trans.png)](/assets/images/phonology/feat-round.png)

To be [round], a phone must first be [+labial] --- which is why you only see a subset of the IPA chart given for these
sounds. [+round] sounds require the lips to be made into the shape of an O (which, incidentally, is what happens when
you make the sound [o]). [+labial] sounds produced without this rounding are [-round].

### [coronal] / [cor]

[![Coronal Phones](/assets/images/phonology/feat-coronal-trans.png)](/assets/images/phonology/feat-coronal.png)

[+coronal] sounds require articulation of the front part of the tongue. Interdental, alveolar, palato-alveolar,
retroflex, and palatal consonants (sans glides) are all [+coronal], and other phones are [-coronal].

[coronal] has two dependent features: [anterior] and [distributed].

#### [anterior] / [ant]

[![Coronal/Anterior Phones](/assets/images/phonology/feat-coronal-anterior-trans.png)](/assets/images/phonology/feat-coronal-anterior.png)

[+anterior] phones are those made by using the tip of the tongue at the front of the mouth. Interdentals and alveolars
are [+anterior], whereas the other [+coronal] phones are [-anterior].

#### [distributed] / [dist]

[![Coronal/Distributed Phones](/assets/images/phonology/feat-coronal-distributed-trans.png)](/assets/images/phonology/feat-coronal-distributed.png)

To distinguish how the front of the tongue is used, we use the feature [distributed]. [+distributed] phones are those
where the tongue is sort of spread wide (the articulation is made with the *blade* of the tongue), and phones which are
[-distributed] use only the tip of the tongue in articulation. Interdentals, palato-alveolars, and palatals are
[+distributed] while other [+coronal] phones are [-distributed].

### [dorsal] / [dor]

[![Dorsal Phones](/assets/images/phonology/feat-dorsal-trans.png)](/assets/images/phonology/feat-dorsal.png)

In contrast to [coronal], the [+dorsal] sounds are those made by articulating the *back* half of the tongue.
Palato-alveolar, palatal, velar, uvular, and pharyngeal consonants and all vowels (and glides) are [+dorsal].

[dorsal] has three dependent features: [high], [low], and [back], each referring to the physical positioning of the
tongue in the mouth.

#### [high] / [hi]

[![Dorsal/High Phones](/assets/images/phonology/feat-dorsal-high-trans.png)](/assets/images/phonology/feat-dorsal-high.png)

The [high] feature specifies the height of the tongue body in the mouth, where [+high] indicates that the tongue body is
raised (and [-high] merely indicates that it is not). Alveo-palatal, palatal, and velar consonants and glides and
close/high vowels are [+high], and other [+dorsal] sounds are [-high].

Note that a sound cannot be both [+high] and [+low], but it can be [-high] and [-low].

#### [low] / [lo]

[![Dorsal/Low Phones](/assets/images/phonology/feat-dorsal-low-trans.png)](/assets/images/phonology/feat-dorsal-low.png)

Similar to [high], the [low] feature specifies the height of the tongue body in the mouth, where [+low] indicates the
tongue is depressed. Pharyngeal consonants and low vowels are [+low], and other [+dorsal] sounds are [-low].

Note that a sound cannot be both [+low] and [+high], but it can be [-low] and [-high].

#### [back] / [bk]

[![Dorsal/Back Phones](/assets/images/phonology/feat-dorsal-back-trans.png)](/assets/images/phonology/feat-dorsal-back.png)

In contrast to [high] and [low], the [back] specification details the horizontal position of the tongue body in the
mouth during sound production. The velar, uvular, and pharyngeal consonants and central and back glides and vowels are
[+back], and other [+dorsal] sounds are [-back].

### [pharyngeal] / [phar]

[![Pharyngeal Phones](/assets/images/phonology/feat-pharyngeal-trans.png)](/assets/images/phonology/feat-pharyngeal.png)

The pharyngeal consonants are (of course) [+pharyngeal], and vowels can have a [pharyngeal] specification in languages
where there is a tenseness contrast of vowels.

[pharyngeal] has one dependent feature: [ATR].

#### [ATR]

[![Pharyngeal/ATR Phones](/assets/images/phonology/feat-pharyngeal-atr-trans.png)](/assets/images/phonology/feat-pharyngeal-atr.png)

ATR stands for "advanced tongue root". This feature indicates whether the root of the tongue has been moved forward, but
what it really provides is a contrast between tensed and un-tensed vowels. [+ATR] vowels are tense, and [-ATR] sounds
are lax.

## Laryngeal features

Last, we come to the laryngeal features. "Laryngeal" means these features have to do with how the larynx is utilized
during sound production. There are three laryngeal features:

- voiced
- aspirated
- glottalized

### [voiced] / [voi]

[![Voiced Phones](/assets/images/phonology/feat-voiced-trans.png)](/assets/images/phonology/feat-voiced.png)

The [+voiced] phones are those which involve the vibration of the vocal folds, whereas [-voiced] phones do not induce
vibration.

### [aspirated] / [asp]

[![Aspirated Phones](/assets/images/phonology/feat-aspirated-trans.png)](/assets/images/phonology/feat-aspirated.png)

Phones which are [+aspirated] have a stronger outward airflow. All voiceless fricatives (plus the voiced glottal
fricative) are [+aspirated], and other sounds are [-aspirated] by default.

[+aspirated] is often specified for other phones, though. Stops can become [+aspirated] (this occurs in English when a
voiceless stop is in the onset of a stressed syllable), and vowels can become [+aspirated] when spoken with
["breathy voice"](https://en.wikipedia.org/wiki/Murmured_voice) (which I will maybe talk about another time).

### [glottalized] / [glot]

[![Glottalized Phones](/assets/images/phonology/feat-glottalized-trans.png)](/assets/images/phonology/feat-glottalized.png)

By default, the implosive consonants (third row in this IPA chart) and the glottal stop are [+glottalized], and all
other sounds are [-glottalized]. (The *implosive* consonants are produced using both pulmonic ingressive and pulmonic
egressive airflows at the same time.)

## Summary

Each unique combination of these features corresponds to exactly one speech sound. (Take note, however, that not all
possible combinations are deemed physically producible.) This means that instead of writing out the names of phones and
hoping that we remember all of the facts about that phone, we can instead give a feature matrix consisting of the
necessary specifications to identify the sound in question.

The feature matrices can be quite useful for comparing and contrasting multiple phones, as I will show you in a future
post.
