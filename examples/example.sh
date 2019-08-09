#!/bin/env bash

# [language-noted] is a grammar package which helps highligting specially marked up stuff in ;#comments.
# It has the same purpose (but not the same approach) as [language-TODO] and its derivatives.
#
# Those packages employ a ;#hard-coded list of words to highlight.
#
# [language-noted] takes a different approach, letting the comment author choose the 'spirit' in which
# that particlar word will be +@styled, thanks to a very +#simple twitter-style ;#syntax as shown below.

# ~@AUTHOR @@MENTION   #@HASHTAGGY :@EAGER ,@BLAND ;@DULL &@VERBOSE +@GOOD ?@QUESTION  >@PERTINENT !@ALERT *@FISHY -@BAD %@SHAKY _@SPOOKY @NONE
# ~#AUTHOR @#MENTIONNY ##HASHTAG   :#EAGER ,@BLAND ;@DULL &@VERBOSE +#GOOD ?#QUESTION  >#PERTINENT !#ALERT *#FISHY -#BAD %#SHAKY _#SPOOKY #NONE
#
# RADAR:  <radar://issue/124> (radar links are always rendered the same as >@PERTINENT)

echo "Hello World!"
