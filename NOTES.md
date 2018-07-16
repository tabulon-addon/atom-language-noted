[TOC]
## NOTES - pertaining to the development and maintenance of [language-noted]

##### RegEx issue : Interpolating **empty regexen** in `CoffeScript`

It appears that, empty regexen that will be interpolated elsewhere MUST be denoted with double-quotes (seemingly due to a CoffeeScript bug as of 2018-07)

````coffeescript
  r1 = //
  r2 = /#{r1}thingy/  # Does NOT work!

  # instead, the following appears to work, as expected:
  r1 = ""
  r2 = /#{r1}thingy/  # works!
````

##### RegEx issue : Could not get **negative lookbehind** `(?<! ...)` to work!

I could not get **negative lookbehind** `(?<! ...)` to work when the grammar is loaded dynamically by Atom.

It kept giving an 'Invalid group' error for the regex, although it works perfectly fine on the with 'coffee', go figure...

It might have something to do with the version of 'coffescript' or 'node.js' that are being used by
my current version of Atom (v1.28.2 -  64bit MacOS build. I don't know.


##### RegEx issue : Missing branch reset
Regex **branch resets**  (:| ... ) would have come so handy in our regexen below, but JavaScript doesn't support them.

Without **branch resets**, each capturing group appearing in an alternation will receive its own capture group (backreference) number.

Therefore, I had to resort to a  _**hack**_  which involves concatenting separately numbered capture groups from different alternatives.
relying on the fact that only one of them will be non-empty for any given match.

As an example, consider the following regex :

````javascript
  /x((a)|(b)|(c))y/
````
This will actually produce 5 separate back-references, the first two being as usual and expected :
  - 0 : The whole match
  - 1 : 'a', or 'b', or 'c'; depending on which one matched

But then, it will also carry the following
  - 2 : 'a', if that's the alternative that matched; empty otherwise.
  - 3 : 'b', if that's the alternative that matched; empty otherwise.
  - 4 : 'c', if that's the alternative that matched; empty otherwise.

Usually, all you want is a single backreference number regardless of the alterantive that matched (since those for all the other alternatives will be empty anyway).
Instead, you end up with a gzillian backreference numbers.

Naturally, in this trivial example, you don't need to use a **branch reset** because $1 is already what you would want.
However, it is not always that trivial and  **branch resets** solve this problem for the general case.
Alas, as mentioned earlier, **Javascript** does not support them as of today (`July 2018`).


------------
[language-noted]: <#>
[language-todo]: <https://github.com/atom/language-todo>
[language-todo-more-words]: <https://github.com/jameelmoses/atom-language-todo-more-words>
[language-todo-extra-words]: <https://github.com/dkiyatkin/atom-language-todo-extra-words>

[screenshot-noted]: <assets/img/screenshot-noted.jpg>
