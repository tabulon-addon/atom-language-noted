//
// !@NOTE: As you can see, the hash signs below are insignificant for the [language-noted] grammar.
// All that matters is what the source language considers as a valid comment.
//
// # Below are a bunch of tokens for a quick reference and also a brief visual test for [language-noted].
//
// # "language-noted" is a grammar package which helps highligting specially marked up stuff in comments.
// # It has the same purpose (but not the same approach) as [language-TODO] and its derivatives that employ
// # a hard coded list of words to highlight.
// #
// # "language-noted", on the other hand, takes a different approach
// # by letting the comment author choose the 'spirit' in which that particlar word will be styled, with the help
// # of an extremely simple markup syntax as shown below:
// #
// #   @NONE ~@AUTHOR @@NEUTRAL :@EAGER ,@BLAND ;@DULL &@VERBOSE +@GOOD ?@QUESTION  >@PERTINENT !@ALERT *@FISHY -@BAD %@SHAKY _@SPOOKY
// #   #NONE ~#AUTHOR ##NEUTRAL :@EAGER ,@BLAND ;@DULL &@VERBOSE +#GOOD ?#QUESTION  >#PERTINENT !#ALERT *#FISHY -#BAD %#SHAKY _#SPOOKY
// #   RADAR:  <radar://issue/124> (radar links are always rendered the same as >@PERTINENT)
// #   And !@"quoted"  
//

include <stdio.h>;

main {
  printf "%s\n" "Hello World!";
}
