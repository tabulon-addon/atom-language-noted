###
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
  #
  #---------------------------------------------------------------------------------------
+@NOTELET_ON_LINE_START
###

helper = require('./grammar-tools')
_ = require('./utils')

exports.run = run = () -> helper.writeGrammar grammar()                               #  generates a static CSON atom grammar and prints it on STDOUT
exports.grammar = grammar = (args... ) -> helper.makeGrammar proto.grammar(args...)    #  PRINCIPAL routine of interest. Returns a grammar object ready to be passed to atom.grammars.createGrammar
exports.stash = stash = (args...) -> _.stash(defaults(), args...)
exports.defaults = defaults = () -> {
    # Below are the defaults for the stash which is used to store macros and/or variables to be interpolated.
    # Fore example, assuming :
    #
    #   m = stash(defaults(), ...)  # (where the stash() function is just a fancy way of merging overrides.)
    #
    # Then, anywhere in proto rules, you can use regular Coffee style string interpolation
    #   ...
    #   captures :
    #     1 : example.#{m.noted}
    #   ...
    # The same thing may also use be written with macro expansion syntax provided by [atom-syntax-tools],
    #  (assuming grammar.macros = m; which should normally be the case)
    #   ...
    #   captures :
    #     1 : example.{noted}
    #   ...
    # !@NOTE: We are rarely using the macro mechanism provided by [atom-syntax-tools]
    # since we can achieve quite similar results with Coffee's string & regex interpolation.

    # for pun :-)
    noted : 'text.noted'                              # The SUFFIX that we append on all scopes we mark on our captures.
    poke  : 'markup.standout'                          # Our main scope PREFIX;
    punk  : 'punctution.definition.notelet.standout'   # Punction scope PREFIX
    link  : 'markup.underline.link'
    radar : "markup.radar.standout.spirit-pertinent"

    gladly : 'spirit-${4:/downcase}${5:/downcase}${6:/downcase}${7:/downcase}.vigor-${8:/downcase}'
    pertinently : "standout.spirit-pertinent"
  }



exports.proto = proto = { rules : {} }
rule = proto.rules  # sugar

proto.grammar = (args...) ->
  m = stash( args...)
  res = {
    name: 'Noted'
    scopeName: 'text.noted'
    injectionSelector: 'comment, text.plain'

    comment: helper.genericGrammarComment(__filename)
    autoAppendScopeName: false    # entry for [atom-syntax-tools]
    macros: _.simplify(m)         # entry for [atom-syntax-tools]. For interpolations using the {macro} syntax; something we try to abstain from, actually.

    patterns: [
      { include: '#notelet' },
      { include: '#radar'   }
    ]
    repository: _.resolve(m, proto.rules)
  }
  overrides = if m.grammar? then m.grammar else {}
  return _.combine( res, overrides)

rule.notelet = ( m = stash() ) ->
                                                              # !@ATTENTION: Regex "comments" are not reported as being comments by [language-coffescript.]
                                                              # Therefore [language-noted] syntax-highliting won't work within these
  m.re_notelet ?= ///
    (?:\s|^)                                                  # NOTELET is required to be immediately preceded by whitespace or else start on a newline.
    # <<<<<<< BEGIN: notelet-term
    (                                                         # < 1: NOTELET-term             // The entire notelet expression that has matched
      {re_notelet_spirit_term}
      {re_notelet_standout_term}
    )                                                         # > 1: NOTELET-term
    # >>>>>>> END: notelet-term
  ///

  m.re_notelet_spirit_term ?= ///
      # <<<<<<< BEGIN: spirit-term
      (                                                       # < 2:  < SPIRIT-term             // Only the portion BEFORE the reftype character (#@)
        (                                                     # < 3:    < desginator

          (?:                                                 # !!!!    A branch reset (:| ... ) needed here, but NOT supported by JS, as explained in NOTES.
              (?: [<]?   ([%_\-*!>+?:\,;&~#@])+?   [>]?  )    #           $4
           |  (?: \(        ([0-9A-Za-z\-_]+)       \)   )    #           $5
           |  (?: \[        ([0-9A-Za-z\-_]+)       \]   )    #           $6
           |  (?: \{        ([0-9A-Za-z\-_]+)       \}   )    #           $7
          )                                                   # ) alternation
        )                                                     # > 3;    > desginator
        ((?:[0-9])?)                                          # . 8:    . vigor. UNDOCUMENTED for the moment.
      )                                                       # > 2:  > SPIRIT-term
      # >>>>>>> END: spirit-term=
  ///

  m.re_notelet_standout_term = ///
      # <<<<<<< BEGIN: standout-term
      (                                                       # < 9:  < standout-rem
        ([#@])                                                # . 10:    . head
        (                                                     # < 11:    < body

          (?:                                                 # !!!!    A branch reset (:| ... ) needed here, but NOT supported by JS, as explained in NOTES.
                                                              # As a consequence, all of the following captures are programattically marked the same in
                                                              # consequitive triplets ('core.start' 'core' 'core.end').

              (?: (  )  ( [0-9A-Za-z\-._]+ )      (  )  \b)   # * 12, 13, 14: BAREWORD label that also accepts dashes and periods
                                                              # // Note the EMPTY capture groups.
                                                              # // Also note that '\b' is employed just here, and not at the very end nor with quoted expressions!
                                                              # ============: Quote-like expressions with backslash escaping support
            | (?: ( ')  ( (?: [^'\\]|[\\]. )*  )  ( ')   )    # * 15, 16, 17: 'Single quoted' expression
            | (?: ( ")  ( (?: [^"\\]|[\\]. )*  )  ( ")   )    # * 18, 19, 20: "Doubled quoted" expression

            | (?: ( <)  ( (?: [^>\\]|[\\]. )*  )  ( >)   )    # * 21, 22, 23: <Angle-bracket quoted>  expression
            | (?: (\()  ( (?: [^)\\]|[\\]. )*  )  (\))   )    # * 24, 25, 26: (Parenthesis quoted)    expression
            | (?: (\[)  ( (?: [^\]\\]|[\\].)*  )  (\])   )    # * 27, 28, 29: (Square-bracket quoted) expression
          )                                                   # ) ALTERNATION
        )                                                     # > 11     > body
      )                                                       # > 9   > standout-term
      # >>>>>>> END: standout-term
  ///

  #  caps = graw.repository['notelet']['captures']
  caps = {
      1: name:  "meta.notelet.term.#{m.noted}"
      2: name:  "#{m.punk}.spirit.term.#{m.noted}"
      3: name:  "#{m.punk}.spirit.designation.#{m.noted}"   # similar to 'marker' below, but includes the whole string in case of delimited (or repeated) marker (symbol.)
      4: name:  "#{m.punk}.spirit.marker.#{m.noted}"
      5: name:  "#{m.punk}.spirit.marker.#{m.noted}"
      6: name:  "#{m.punk}.spirit.marker.#{m.noted}"
      7: name:  "#{m.punk}.spirit.marker.#{m.noted}"
      8: name:  "#{m.punk}.spirit.vigor.#{m.noted}"
      9: name:  "#{m.poke}.term.#{m.gladly}.#{m.noted}"
      10: name: "#{m.poke}.head.#{m.gladly}.#{m.noted}"
      11: name: "#{m.poke}.body.#{m.gladly}.#{m.noted}"
      # 12: ...
      # !@NOTE that, to keep things DRY. the rest of the captures are set actually set ,@programmatically below;
      # since we have a gzillian of them due to lack of support for branch resets
  }

  # The following is done for the sake of DRY. It makes for more lines of code (but hop.termy more maintainable)
  # note that macros below are expanded by makeGrammar, just like the other macros elsewhere.
  core_quoted_forms = [ 'single', 'double', 'angle_bracket', 'square_bracket', 'parens' ]
  core_caps_std = [
    { name: "#{m.punk}.core.start.#{m.noted}"     },
    { name: "#{m.poke}.core.#{m.gladly}.#{m.noted}"  },
    { name: "#{m.punk}.core.end.#{m.noted}"       }
  ]
  core_caps = []
  for i in [0 ... core_quoted_forms.length + 1 ]   # + 1 for the regular bareword form.
    core_caps = core_caps.concat core_caps_std

  core_caps_start= 1 + Math.max (key for key of caps)...  # we count on the fact that the keys of the 'captures' object are always numbers.
  for i in [0 ... core_caps.length]
    caps[ i + core_caps_start ] = core_caps[i]  # !@NOTE that the left-hand-side is an object (not an ARRAY. That's why we need the loop instead of 'concat')

  return {
    match: m.re_notelet
    captures: caps
  }


rule.radar = ( m = stash() ) ->
  { # For language-TODO emulation.
    match: /((<)((ra?dar:\/(?:[\/](problems?|issues?|tickets?|bug-reports?|bugs?|reports?))\/([&0-9 .%;A-Aa-z_]+)))(>))/.source
    #match: '(RADAR_TEST_NOTED)'
    name: "storage.type.class.radar.#{m.pertinently}.#{m.noted}"   # This one is for language-todo/-more-words compatibility
    captures:
      1: name: "meta.radar.#{m.noted}"
      2: name: "#{m.punk}.radar.start.#{m.noted}"
      3: name: "#{m.link}.radar.body.#{m.pertinently}.#{m.noted}"  # radar.body is marked twice. This one is for language-todo/-more-words compatibility
      4: name: "#{m.radar}.body.#{m.noted}"                    #                             And this one is in our own way.
      5: name: "#{m.radar}.type.#{m.noted}"
      6: name: "#{m.radar}.core.#{m.noted}"
      7: name: "#{m.punk}.radar.end.#{m.noted}"
  } # END: radar

#run()   # # print out a CSON version on STDOUT - (needed only when the grammar generation happens during a build)
