# More TODO support in Atom

 Just like 'language-todo' and co, it allows constructs like @TODO, @HACK, @OMG to be highlighted; but instead of those words being
 hard-coded into the mini-language, they are jotted down with a simple light-weight markup syntax that also carries info about the 'spirit'
 of the tag (i.e. how it makes you feel:-). For example : @@TODO, !@ATTENTION, -@OMG, *@HACKED.


Adds syntax highlighting to MORE such words in comments and text in Atom :
  `CHANGED`°, `CONSIDER`++, `DEBUG`°, `FATAL`++, `FIXME`°, `IDEA`, `INFO`, `LOG`, `NB`, `NOTE`, `OPTIMIZE`, `OPTIMIZED`+, `PS`, `QUESTION`, `REFACTOR`, `REMOVE`, `REVIEW`,  `TASK`, `TBD`, `TODO`, `TO DO`, `UNDONE`,
  `CHGME`, `NOTREACHED`,
  `ATTENTION`, `ATTN`,`COMBAK`, `HACK`, `WARN`, `WARNING`, `TEMP`, `XXX`,
  `DEPRECATED`,
  `BROKEN`, `BUG`, `OMG`,  `ERR`, `ERROR`,`FIXME`, `OMFGRLY`, `WTF`,
  `ETHER`, `TABULO`,  TAU`,

Based on [language-todo]|(https://github.com/atom/language-todo), version 0.29.4 (forked on 2018-06-29),
  which already added syntax highlighting in comments and text in Atom to some words (which are still **preserved** here, as listed above):

  `TODO`, `FIXME`, `CHANGED`, `XXX`, `IDEA`, `HACK`, `NOTE`, `REVIEW`, `NB`, `BUG`, `QUESTION`, `COMBAK`, `TEMP`, `DEBUG`, `OPTIMIZE`, and `WARNING`

Originally [converted](http://flight-manual.atom.io/hacking-atom/sections/converting-from-textmate) from the [TODO TextMate bundle](https://github.com/textmate/todo.tmbundle).

Contributions are greatly appreciated. Please fork this repository and open a pull request to add snippets, make grammar tweaks, etc.
