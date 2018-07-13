

{makeGrammar, rule} = require('atom-syntax-tools')

grammar = {

  name: 'NOTED'
  scopeName: 'text.noted'
  injectionSelector: 'comment, text.plain'

  macros:
    # macro support is given by [atom-syntax-tools]
    # Here are some examples (direct from [atom-syntax-tools] )
    en: "entity.name"
    pd: "punctuation.definition"
    ps: "punctuation.separator"
    ii: "invalid.illegal"

    # And here's our own macros

    # If we ever decided to adopt delimeters for the whole notelet term/expression
    re_notelet_prefix: ''
    re_notelet_suffix: ''

    # Regex character classes
    cc_bareword:      /[0-9A-Za-z\-._]/       # Char class for bareword (unquoted) standouts. !@Note the extra dash (-) and period (.) in addition to the usual suspects.
    cc_spirit_name:   /[0-9A-Za-z_]/          # Char class for spirit names such as : alert, good, bad, ...
    cc_spirit_symbol: /[%_\-*!>+?:\,;&~#@]/   # Char class for spirit marker symbols (for shorthand notation)

    # for pun :-)
    noted:'text.noted'                              # The SUFFIX that we append on all scopes we mark on our captures.
    mark:'markup.standout'                          # Our main scope PREFIX;
    punk:'punctution.definition.notelet.standout'   # Punction scope PREFIX

    gladly: 'spirit-${4:/downcase}${5:/downcase}${6:/downcase}${7:/downcase}.vigor-${8:/downcase}'
    pertinently: 'standout.spirit-pertinent'

    mark_link: 'markup.underline.link'
    mark_radar: 'markup.radar.{pertinently}'
#    mark_radar: 'markup.radar.standout.spirit-pertinent'
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
# Quoted strings, either with +@"double quotes" or ;#'single quotes', as well as .+@[bracket quoted] forms should also work:
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
  repository: {

    radar: { # For language-TODO emulation.
      match: /((<)((ra?dar:\/(?:[\/](problems?|issues?|tickets?|bug-reports?|bugs?|reports?))\/([&0-9 .%;A-Aa-z_]+)))(>))/
      name: 'storage.type.class.radar.{pertinently}.{noted}'   # This one is for language-todo/-more-words compatibility
      captures:
        1: name: 'meta.radar.{noted}'
        2: name: '{punk}.radar.start.{noted}'
        3: name: '{mark_link}.radar.body.{pertinently}.{noted}'  # radar.body is marked twice. This one is for language-todo/-more-words compatibility
        4: name: '{mark_radar}.body.{noted}'                    #                             And this one is in our own way.
        5: name: '{mark_radar}.type.{noted}'
        6: name: '{mark_radar}.core.{noted}'
        7: name: '{punk}.radar.end.{noted}'
    }


    notelet: {
        # It should have been possible to use a branch reset  (:| ... ) here, but JavaScript doesn't support it.
        # Hence the hack below which involves concatenting separately numbered capture groups from different alternatives,
        # (relying on the fact that only one of them will be non-empty for any given match)

                                                                  # !@ATTENTION: Regex "comments" are not reported as being comments by [language-coffescript.]
      match: ///                                                  # Therefore [language-noted] syntax-highliting won't work within these (as you can -#see)

        (?<!\w)                                                   # NOTELET is not allowed to be immediately preceded by word characters.
        (                                                         # < 1: < NOTELET-term             // The entire notelet expression that has matched
        {re_notelet_prefix}
          (                                                       # < 2:  < SPIRIT-term             // Only the portion BEFORE the reftype character (#@)
            (                                                     # < 3:    < desginator
              (?:   # A branch reset (:| ... ) needed here, but NOT supported by JS, as explained above. So we end up with a gziliian capture groups.
                    # Therefore "spirit marker" is later expressed as a fake concatination like below:
                    #       ${4:/downcase}${5:/downcase}${6:/downcase}${7:/downcase}
                   (?: [\[({]?   ({cc_spirit_symbol})+?   [\])}]? )  #           \4
                |  (?: \(        ({cc_spirit_name}+)       \)     )  #           \5
                |  (?: \[        ({cc_spirit_name}+)       \]     )  #           \6
                |  (?: \{        ({cc_spirit_name}+)       \}     )  #           \7
              )
            )                                                     # > 3;    > desginator
            ((?:[0-9])?)                                          # . 8:    . vigor. UNDOCUMENTED for the moment.
          )                                                       # > 2:  > SPIRIT-term
          (                                                       # < 9:  < standout
            ([#@])                                                # . 10:    . head
            (                                                     # < 11:    < body

              (?:   # A branch reset (:| ... ) needed here, but NOT supported by JS, as explained above. So, we end up with a gziliian capture groups.
                    # As a consequence, all of the following captures are programattically marked the same in consquetive triplets ('core.start' 'core' 'core.end').

                  (?: (  )  ( {cc_bareword}+ )      (  )  \b)       # * 12, 13, 14: BAREWORD label that also accepts dashes and periods
                                                                      # // Note the EMPTY capture groups.
                                                                      # // Also note that '\b' is employed just here, and not at the very end nor with quoted expressions!

                                                                      # Quote-like expressions with backslash escaping support
                | (?: ( ')  ( (?: [^'\\]|[\\].)*   )  ( ')   )        # * 15, 16, 17: 'Single quoted' expression
                | (?: ( ")  ( (?: [^"\\]|[\\].)*   )  ( ")   )        # * 18, 19, 20: "Doubled quoted" expression

                | (?: ( <)  ( (?: [^>\\]|[\\].)*   )  ( >)   )        # * 21, 22, 23: <Angle-bracket quoted>  expression
                | (?: (\()  ( (?: [^)\\]|[\\].)*   )  (\))   )        # * 24, 25, 26: (Parenthesis quoted)    expression
                | (?: (\[)  ( (?: [^\]\\]|[\\].)*  )  (\])   )        # * 27, 28, 29: (Square-bracket quoted) expression
              )
            )                                                     # > 11     > body
          )                                                       # > 10   > standout
          {re_notelet_suffix}
        )                                                         # > 1 > NOTELET-TERM
       ///

      captures:
        1: name: 'meta.notelet.{noted}'
        2: name: '{punk}.spirit.term.{noted}'
        3: name: '{punk}.spirit.designation.{noted}'   # similar to 'marker' below, but includes the whole string in case of delimited (or repeated) marker (symbol.)
        4: name: '{punk}.spirit.marker.{noted}'
        5: name: '{punk}.spirit.marker.{noted}'
        6: name: '{punk}.spirit.marker.{noted}'
        7: name: '{punk}.spirit.marker.{noted}'
        8: name: '{punk}.spirit.vigor.{noted}'
        9: name:  '{mark}.full.{gladly}.{noted}'
        10: name: '{mark}.head.{gladly}.{noted}'
        11: name: '{mark}.body.{gladly}.{noted}'

        # !@NOTE that the following (and bunch of other captures) are set actually set programmatically below, trying to keep things DRY.
        # Captures for 'core' have to be given multiple times in a row for each separate capture-group generated by aalternation (|)
        # bewteen various forms of quote-like constructs (as explained in the margins of regex comments above).
        # This is all because of the absence of regex branch resets /(:| ... )/ in Javascript regexen.
        12: name: '{punk}.core.start.{noted}'
        13: name: '{mark}.core.{gladly}.{noted}'
        14: name: '{punk}.core.end.{noted}'

    } # END: notelet
  } # END: repository
} # END: grammar

# The following is done for the sake of DRY. It makes for more lines of code (but hopefully more maintainable)
# note that macros below are expanded by makeGrammar, just like the other macros elsewhere.

core_caps = [
  { name: '{punk}.core.start.{noted}' },
  { name: '{mark}.core.{gladly}.{noted}' },
  { name: '{punk}.core.end.{noted}' }
]

# the following two lines are not strictly necesasry, as they are just used to get the number of such cases (core_forms.length)
# But it helps to better see what is going on.
quote_like = [ 'single', 'double', 'angle_bracket', 'square_bracket', 'parens' ]
core_forms = quote_like.concat ['bareword']


core_caps_start=12
caps = grammar.repository['notelet']['captures']

for i in [0 ... core_forms.length]
  for j in [0 ... core_caps.length]
    c = j + core_caps_start + ( i * core_caps.length)
    caps[c] = core_caps[j]

# Let [atom-syntax-tools] work its magic and return a CSON grammer as Atom itself expects it.
makeGrammar grammar, "CSON"
