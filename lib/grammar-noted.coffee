

{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: 'NOTED'
  scopeName: 'text.noted'
  injectionSelector: 'comment, text.plain'


  macros:
    # macro examples (direct from [atom-syntax-tools] )
    en: "entity.name"
    pd: "punctuation.definition"
    ps: "punctuation.separator"
    ii: "invalid.illegal"

  patterns: [
    '#notelet'
    '#radar'
  ]


#---------------------------------------------------------------------------------------
# Below are a bunch of tokens for a quick reference and also a brief visual test for [language-noted].
#
# ~@AUTHOR @@MENTION   #@HASHTAGGY :@EAGER ,@BLAND ;@DULL &@VERBOSE +@GOOD ?@QUESTION  >@PERTINENT !@ALERT *@FISHY -@BAD %@SHAKY _@SPOOKY @NONE
# ~#AUTHOR @#MENTIONNY ##HASHTAG   :#EAGER ,@BLAND ;@DULL &@VERBOSE +#GOOD ?#QUESTION  >#PERTINENT !#ALERT *#FISHY -#BAD %#SHAKY _#SPOOKY #NONE
#
# RADAR:  <radar://issue/124> (radar links are always rendered the same as >@PERTINENT)
#
# Quoted strings, either with +@"double quotes" or ;#'single quotes', as well as +@[bracket quoted] forms should also work:
# This includes quote-like usage of brackets and parenthehis, such as ,#<angle bracket> , #@[square bracket], and also ;#(parenthetic quotes).
#
# Backslash escaping ;@"should \"work\" as expected" for all the quote-like operators mentioned above.
#
# Note that, in this context, brackets and parenthesis act just like quotatation marks, except the fact that the end of the quotation is marked with a
# specific character which is distinct (yet still discernable) from the opening character. In particular,  balanced nesting of parens/brackets
# is not required and does not even make much sense in a quotation context.
#
# The careful reader might have noticed that curly braces '{}' and backticks have not been mentioned among the quote-like operators described above.
# This is intentional as those are %#reserved for the moment.
#---------------------------------------------------------------------------------------
  repository:
    notelet:                                                      # !@ATTENTION: The regex "comments" below are not properly reported as being comments by language-coffescript.
      match: ///                                                  # Therefore [language-noted] syntax-highliting won't work within these (as you can -#see)
        (?<!\w)                                                   # NOTELET is not allowed to be immediately preceded by word characters.
        (                                                         # < 1: < NOTELET-term             // The entire notelet expression that has matched
          (                                                       # < 2:  < SPIRIT-term             // Only the portion BEFORE the reftype character (#@)
            (                                                     # < 3:    < desginator
              (                                                   # < 4:      < marker              // The symbol that denotes the spirit. We are NOT really limited to 1-char; but it keeps things simpler.
                [%_\-*!>+?:\,;&~#@]                               # ####        # character-class   // for standard spirit marker symbols
              )+                                                  # > 4:      > marker
            )                                                     # > 3;    > desginator
            ((?:[0-9])?)                                          # . 5:    . vigor. UNDOCUMENTED for the moment.
          )                                                       # > 3:  > SPIRIT-term
          (                                                       # < 6:  < REFERENCE-term (standout)
            ([#@])                                                # . 7:    . reftype
            (                                                     # < 8:    < label

                (?: (  )  ( (?: [0-9A-Za-z\-._])+ )  (  )  \b)    # * 9, 10, 11. Regular BAREWORD label that also accepts dashes and periods
                                                                  # // Note the EMPTY capture groups.
                                                                  # // Also note that '\b' is employed just here, and not at the very end, and not with quoted expressions!

              | (?: ( ")  ( (?: [^"\\]|[\\].)*    )  ( ")    )    # * 9, 10, 11. "Doubled quoted" expression        // (with backslash escaping support)
              | (?: ( ')  ( (?: [^'\\]|[\\].)*    )  ( ')    )    # * 9, 10, 11. 'Single quoted' expression         // (with backslash escaping support)

              | (?: ( <)  ( (?: [^>\\]|[\\].)*    )  ( >)    )    # * 9, 10, 11. <Angle-bracket quoted>  expression // (with backslash escaping support)
              | (?: (\()  ( (?: [^)\\]|[\\].)*    )  (\))    )    # * 9, 10, 11. (Parenthesis quoted)    expression // (with backslash escaping support)
              | (?: (\[)  ( (?: [^\]\\]|[\\].)*   )  (\])    )    # * 9, 10, 11. (Square-bracket quoted) expression // (with backslash escaping support)

            )                                                     # > 8     > label
          )                                                       # > 6   > REFERENCE-term (standout)
        )                                                         # > 1 > NOTELET-TERM
       ///


      captures:
        1: name: 'meta.notelet.text.noted'
        2: name: 'punctuation.definition.notelet.spirit.term.text.noted'
        3: name: 'punctuation.definition.notelet.spirit.designator.text.noted'
        4: name: 'punctuation.definition.notelet.spirit.marker.text.noted'
        5: name: 'punctuation.definition.notelet.spirit.vigor.text.noted'
  #      6: name: 'meta.notelet.reference.text.noted'
        6: name: 'markup.standout.spirit-marker-${4:/downcase}.vigor-${5:/downcase}.text.noted'
        7: name: 'punctuation.definition.notelet.reftype.text.noted'
        # X: name: 'meta.notelet.label.text.noted'


    # For language-TODO emulation.
    radar: {
    #  match: '{radar_match}'
      match: /<(ra?dar:\/(?:[\/](?:problems?|issues?|tickets?|bug-reports?|bugs?|reports?))\/(?:[&0-9 .%;A-Aa-z_]+))>/
      name: 'storage.type.class.radar.spirit.pertinent.text.noted'
      captures:
        1: name: 'markup.underline.link.radar.standout.spirit-pertinent.text.noted'
    }


makeGrammar grammar, "CSON"
