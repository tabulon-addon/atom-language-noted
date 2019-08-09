#!/bin/env perl

# Below are a bunch of tokens for a quick reference and also a brief visual test for [language-noted].
# --------------------------------
# "language-noted" is a grammar package which helps highligting specially marked up stuff in comments.
# It has the same purpose (but not the same approach) as [language-TODO] and its derivatives that employ
# a hard coded list of words to highlight.
#
# "language-noted", on the other hand, takes a different approach
# by letting the comment author choose the 'spirit' in which that particlar word will be styled, with the help
# of an extremely simple markup syntax as shown below:
#
#   @NONE ~@AUTHOR @@NEUTRAL :@EAGER ,@BLAND ;@DULL &@VERBOSE +@GOOD ?@QUESTION  >@PERTINENT !@ALERT *@FISHY -@BAD %@SHAKY _@SPOOKY
#   #NONE ~#AUTHOR ##NEUTRAL :@EAGER ,@BLAND ;@DULL &@VERBOSE +#GOOD ?#QUESTION  >#PERTINENT !#ALERT *#FISHY -#BAD %#SHAKY _#SPOOKY
#   RADAR:  <radar://issue/124> (radar links are always rendered the same as >@PERTINENT)

@TODO=[ "@THIS should not be highlighted here by [language-noted], since it is not in a comment region.",
        "It may still be highlighted because of the source language though (if it is a valid construct in that language, as it is here).",
      ];

print "Hello World!\n";
