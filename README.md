[TOC]
## [language-noted] - Flexible :@TODO support in Atom, with a little very simple syntax of its own

##### SCREENSHOT

````comment
![screenshot-noted]
````

### OVERVIEW

Just like [language-todo] and its derivatives, [language-noted] allows constructs for things like TODO, HACK, OMG to be highlighted.

Unlike [language-todo] and its cousins that use a list of hard-coded words into the mini-language for this purpose, [language-noted] allows you jot _**anything**_ down with a simple **light-weight markup syntax** that carries information about the _'spirit'_ of the subject at hand (i.e. basically, how it makes you _feel_ :-).

For example : :@@TODO, !@ATTENTION, -@OMG, *@HACKED.

Here, It is NOT the actual word that is being referenced / marked-up,  but prefix marker (!,:,+,-, etc) that sets up the whole _spirit_ of the final styling. that will determine the _**spirit**_ (and hence the ultimate visual styling); .

As mentioned above, this is where things diverge from the apprach taken by [language-todo] and that its cousins that match (and later style)
based on the literal words. It's much more flexible with just a little extra overhead.

### REFERENCE

#### Notelet

The main term that is recognized by [language-noted] is called a _**notelet**_.

A _notelet_ is basically a twitter-style reference (i.e. a `#hashtag` or a `@mention`), prefixed with a special marker that conveys information about the _**spirit**_ of the subject at hand.

| symbol | spirit    | precisions   | example          | visual |
| ------ | --------- | ------------ | ---------------- | ------ |
| ~      | artisan   |              | ~@YOUR_NAME_HERE |        |
| :      | eager     |              | :@TODO:          |        |
| %      | shaky     |              | %@DEPRECATED     |        |
| _      | spooky    | (underscore) | %@OMGRLY         |        |
| -      | bad       | (dash)       | -@WTF            |        |
| !      | alert     |              | !@ATTENTION:     |        |
| *      | fishy     |              | *@HACK           |        |
| +      | good      |              | +@DONE           |        |
| >      | pertinent |              | >#SEE-ALSO:      |        |
| ?      | curious   |              | ?#WHY?           |        |
| ,      | bland     |              | ,#RETURNS        |        |
| ;      | dull      |              | ;@IDEA:          |        |
| &      | verbose   |              | &#WHAT-IF:       |        |
| #      | hashtaggy |              | #hello           |        |
| @      | mentionny |              | @world           |        |


Remember: In the end, it's the _spirit_ that matters for visually styling (i.e. highlighting) the _notelet_. [language-noted] doesn't care, and in fact doesn't even know about, the semantics of the literal expression that is being referenced. Therefore, it doesn't attempt to do anything special about that.

##### Terminology

As an example :

````
 !@<Hello world!>

````

Let's cut it into pieces:


| term | description | remarks |
| ---- | ----------- | ------- |
| !    |             |         |




#### Radar

Another term that is recognized by [language-noted] is the `radar://` link, in an attempt to provide iso-funcionality with [language-todo] and its cousins.

Afaik, there is no standard definition that governs its use. It appears to be just a convention that consists of a _pseudo-URL_ used for referring to a precise object (usually a _"support ticket"_, _"bug report"_, _"issue"_, ...) that has some actual/supposed connection to the _code region_ that is being commented.

It's best decribed with the pattern copied from the [language-noted] grammar.

```cson
radar: {
  match: '<(ra?dar:/(?:[/](?:problems?|issues?|tickets?|bug-reports?|bugs?|reports?))/(?:[&0-9 \\-.%\,;A-Aa-z_]+))>'
  name: 'storage.type.class.radar.spirit.pertinent.text.noted'
  captures:
    1: name: 'markup.underline.link.radar.standout.spirit-pertinent.text.noted'
}
```

The regular expression is just a slightly relaxed version of the one that ships with [language-todo] and its cousins.




### STYLING


### FUTURE PLANS

The hard-coded approach taken by [language-todo] and its cousins does have its merits:

  1. Less keystrokes
  2. Arguably less mental overhead (although, as you can see, the [language-noted] syntax is extremely simple and succint.
  3. Existing sources (that don't follow the [language-noted] convention) files are highlighted just the same

The first two points are not much of deal, really.

Just one added character is not much at all; and it shouldn't bother anyone visually, as it's burried with the rest of the comments (since it
is not highlighted).

Also, as you can see, the [language-noted] syntax is extremely simple and succint. Plus, you only have to learn it once,
and then anything you throw at it is highlighted the way you expect it to be (since you've got control).
This is probably much less mental overhead than trying to remember the exact hard-coded list of words recognized by the mini-language.

The **last point above** (which involves existing source files), on the other hand, is an important one, and that's why I plan on shipping
one or two extra langage packages that provide compatibility with [language-todo] or [language-todo-more-words].

When done, these will be just recognize common annotation words like TODO or HACK (bareword form or with a '@' prefix, as in @TODO or @OMG), and
mark their syntax _scope_ in a way that is compatible with [language-noted].

I don't know if I will be making two such packages (each corresponding to the individual word-list of [language-todo] and [language-todo-more-words]),
or just one _"soup"_ that caters a single merged word-list. I guess it will depend on how lazy I feel at the time. As of today, I am already inclined to
the _soup_ option, since I don't want to spend that much time on this stuff -- _(contrary to how it might appear :-)_

Another "plan", further up, is to ship yet another extension for [language-noted] for recognizing **inline documentation** in source comments.
This one requires a bit more thought than just comming up with a new word-list. Although that alone would already be of some use
_(in much as any of this really is)_, the real gain will come from finding a way to make it play nicely with **asciiDoc** and/or **wikiDoc**.

Anyhow, it's really easy to do your own extension like the ones evoked above.

------------

### CREDITS ###

Vaguely based on [language-todo] and also borrowed some ideas and colors from [language-todo-more-words] [language-todo-extra-words].
Those all appear to have some things in common in any case.

Contributions are greatly appreciated; but will only be handled as my schedule permits.
If you wish to make a contribution, please fork this repository and open a pull request to add snippets, make grammar tweaks, etc.

------------
[language-noted]: <#>
[language-todo]: <https://github.com/atom/language-todo>
[language-todo-more-words]: <https://github.com/jameelmoses/atom-language-todo-more-words>
[language-todo-extra-words]: <https://github.com/dkiyatkin/atom-language-todo-extra-words>

[screenshot-noted]: <assets/img/screenshot-noted.jpg>
