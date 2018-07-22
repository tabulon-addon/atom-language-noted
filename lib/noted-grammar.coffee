###
  #---------------------------------------------------------------------------------------
  # Below are a bunch of tokens for a quick reference and also a brief visual test for [language-noted].
  #
  # ~@AUTHOR @@MENTION   #@HASHTAGGY :@EAGER ,@BLAND ;@DULL &@VERBOSE +@GOOD ?@QUESTION  >@PERTINENT !@ALERT *@FISHY -@BAD %@SHAKY _@SPOOKY
  # ~#AUTHOR @#MENTIONNY ##HASHTAG   :#EAGER ,@BLAND ;@DULL &@VERBOSE +#GOOD ?#QUESTION  >#PERTINENT !#ALERT *#FISHY -#BAD %#SHAKY _#SPOOKY #NONE
  #
  # RADAR:  <radar://issue/124> (radar links are always rendered the same as >@PERTINENT)
  #
  # Quoted strings, either with +@"double quotes" or ;#'single quotes', as well as .+@[bracket quoted] forms should also work:
  # This includes quote-like usage of brackets and parenthehis, such as ,#<angle bracket> , #@[square bracket], and also ;#(parenthetic quotes).
  #
  # Backslash escaping ;#"should \"work\" as expected" for all the quote-like operators mentioned above.
  #
  # Note that, in this context, brackets and parenthesis act just like quotatation marks, except the fact that the end of the quotation is marked with a
  # specific character which is distinct (yet still discernable) from the opening character. In particular,  balanced nesting of parens/brackets
  # is not required and does not even make much sense in a quotation context.
  #
  # The careful reader might have noticed that curly braces '{}' and backticks have not been mentioned among the quote-like operators described above.
  # This is intentional as those are %#reserved for the moment.
  #
  # As an added bonus, wordlists from [language-todo-more-words] are honored by default (can be disabled via atom package preferences).
  # Here's how those words loo, like (with and without head characters)
  #
  #   DEPRECATED -   WTF| BUG| ERROR| OMG| ERR| OMFGRLY| BROKEN| REFACTOR -  WARNING| WARN| HACK -  NOTE| INFO| IDEA| DEBUG| REMOVE| OPTIMIZE| REVIEW| UNDONE| TODO| TASK
  #  @DEPRECATED -  @WTF|@BUG|@ERROR|@OMG|@ERR|@OMFGRLY|@BROKEN|@REFACTOR - @WARNING|@WARN|@HACK - @NOTE|@INFO|@IDEA|@DEBUG|@REMOVE|@OPTIMIZE|@REVIEW|@UNDONE|@TODO|@TASK
  #  #DEPRECATED -  #WTF|#BUG|#ERROR|#OMG|#ERR|#OMFGRLY|#BROKEN|#REFACTOR - #WARNING|#WARN|#HACK - #NOTE|#INFO|#IDEA|#DEBUG|#REMOVE|#OPTIMIZE|#REVIEW|#UNDONE|#TODO|#TASK
  #---------------------------------------------------------------------------------------
+@NOTELET_ON_LINE_START
###

#{GrammarRecipe} = require('./grammar-tools')
helper          = require('./grammar-tools')
_ = require('./utils')

#exports.run = run = (args...) -> helper.writeGrammar grammar(args...)   #  generates a static CSON atom grammar and prints it on STDOUT
exports.makers  = exports.maker = makers = maker = {} # for sugar & easy referral

exports.recipe  = recipe  =  ( args... ) -> new GrammarRecipe(args...)
exports.bake    = bake    =  ( args... ) -> g = recipe( args... ); g.bake(args...)
exports.GrammarRecipe  = class GrammarRecipe extends helper.GrammarRecipe
  defs: () -> _.extend {}, super(), {
    # Below are some defaults used for our grammar.
    name: 'Noted'
    scopeName: 'text.noted'
    injectionSelector: 'comment, text.plain'

    patterns: [ # adjusted elsewhere programmatically in order to eliminate patterns that are 'disabled'.
      { include: '#notelet'   }
      { include: '#radar'     }
      { include: '#todoMore'  }
    ]
  }
  vars: () ->
    spirit  = {}; so = {}
    spirits = "alert, artisan, bad, bland, curious, default, deprecated, dull, eager, fishy, good, hashtaggy, neutral, mentionny, pertinent, shaky, spooky, verbose".split(/(?:[\,]|\s)+/)

    for i in spirits
      spirit[i] = 'spirit-' + i
      so[i] = 'standout.' + spirit[i]

    return _.extend {}, super(),  {
      # Defaults for the stash (usually named 'm' thoughout the code) that are used for variable interpolation (Coffee style)
      #   ...
      #   captures :
      #     1 : example.#{m.noted}
      #   ...

      # cc_spirit_symbol  : /[%_\-*!>+?:\,;&~#@]/
      # cc_spirit_name    : /[0-9A-Za-z\-_]/
      # cc_bareword_x     : /[0-9A-Za-z\-._]/
      spirits: spirits
      spirit: spirit
      s: spirit
      so: so

      # for pun :-)
      gladly : 'spirit-${4:/downcase}${5:/downcase}${6:/downcase}${7:/downcase}.vigor-${8:/downcase}'
      pertinently : "standout.spirit-pertinent"

      noted : 'text.noted'                                # The SUFFIX that we append on all scopes we mark on our captures.
      poke  : 'markup.standout'                           # Our main scope PREFIX;
      punk  : 'punctuation.definition.notelet.standout'   # Punctuation scope PREFIX
      link  : 'markup.underline.link'
      radar : "markup.radar.standout.spirit-pertinent"

      # more words
      todoMore: {
        disabled: false
        prefix: {mode:1, cc:/[@$]/.source }    # 1: Accepted but NOT required. 3: required. 4. Forbidden
        words: {
          deprecated:   { rewords: /DEPRECATED/.source                                                    }
          bad:          { rewords: /WTF|BUG|ERROR|OMG|ERR|OMFGRLY|BROKEN|REFACTOR/.source                 }
          fishy:        { rewords: /WARNING|WARN|HACK/.source                                             }
          neutral:      { rewords: /NOTE|INFO|IDEA|DEBUG|REMOVE|OPTIMIZE|REVIEW|UNDONE|TODO|TASK/.source  }
        }
      }

    }

  rule = {};
  rules: () -> _.extend {}, super(), rule

  rule.notelet = ( m = {}, re = {} ) ->
    re.notelet_term           ?= ( m = {} ) ->
      # see below for the definitions of these
      re_notelet_spirit_term   = re.notelet_spirit_term(m).source
      re_notelet_standout_term = re.notelet_standout_term(m).source

      # !@NOTE: Regex "comments" are not reported as being in "comment" scope by [language-coffescript.]
      # Therefore [language-noted] syntax-highliting won't work within those.

      ///
      (?:^|\s|\W)                                               # NOTELET is required to be immediately preceded by whitespace or a non-word character, or else start on a newline.
      # <<<<<<< BEGIN: notelet-term
      (                                                         # < 1: NOTELET-term             // The entire notelet expression that has matched
        #{re_notelet_spirit_term}
        #{re_notelet_standout_term}
      )                                                         # > 1: NOTELET-term
      # >>>>>>> END: notelet-term
      ///
    re.notelet_spirit_term    ?= ( m = {} ) -> ///
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
    re.notelet_standout_term  ?= ( m = {} ) -> ///
      # <<<<<<< BEGIN: standout-term
      (                                                       # < 9:  < standout-rem
        ([#@])                                                # . 10:    . head
        (                                                     # < 11:    < body

          (?:                                                 # !!!!    A branch reset (:| ... ) needed here, but NOT supported by JS, as explained in NOTES.
                                                              # As a consequence, all of the following captures are programattically marked the same in
                                                              # consequitive triplets ('marrow.start' 'marrow' 'marrow.end').

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

    match = _.resolve re.notelet_term(m), m

    # !@NOTE that, to keep things DRY. the rest of the captures are set actually set ,@programmatically below;
    # ( since we have a gzillian of them due to lack of support for branch resets )
    caps = [  # !#ARRAY
      undefined                                   # we do NOT do anything with $0.
      "meta.notelet.term.#{m.noted}"
      "#{m.punk}.spirit.term.#{m.noted}"
      "#{m.punk}.spirit.designation.#{m.noted}"   # similar to 'marker' below, but includes the whole string in case of delimited (or repeated) marker (symbol.)
      "#{m.punk}.spirit.marker.#{m.noted}"
      "#{m.punk}.spirit.marker.#{m.noted}"
      "#{m.punk}.spirit.marker.#{m.noted}"
      "#{m.punk}.spirit.marker.#{m.noted}"
      "#{m.punk}.spirit.vigor.#{m.noted}"
      "#{m.poke}.term.#{m.gladly}.#{m.noted}"
      "#{m.poke}.head.#{m.gladly}.#{m.noted}"
      "#{m.poke}.body.#{m.gladly}.#{m.noted}"
    ]

    # The following is done for the sake of DRY. It makes for more lines of code (but hop.termy more maintainable)
    # note that macros below are expanded by makeGrammar, just like the other macros elsewhere.
    marrow_quoted_forms = [ 'single', 'double', 'angle_bracket', 'square_bracket', 'parens' ]
    marrow_caps_std = [
      "#{m.punk}.marrow.start.#{m.noted}"
      "#{m.poke}.marrow.#{m.gladly}.#{m.noted}"
      "#{m.punk}.marrow.end.#{m.noted}"
    ]
    caps      = caps.concat _.flatten(_.times(marrow_quoted_forms.length + 1, () -> marrow_caps_std))

    return {
      match: match
      captures: helper.buildCaptures(caps...) # !@OBJECT with numeric keys; plain string items turned into { name : <item> }
    }
  rule.radar   = ( m = {} ) ->
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
        6: name: "#{m.radar}.marrow.#{m.noted}"
        7: name: "#{m.punk}.radar.end.#{m.noted}"
    } # END: radar
  rule.todoMore = ( m = {}, re = {} ) ->
    return unless schema = m?.todoMore
    helper.prescribe.wordlists m, re, schema

    # return maker.wordlist( m,
    #                         _.extend( {}, re, { words: /WTF|BUG|ERROR|OMG|ERR|OMFGRLY|BROKEN|REFACTOR/.source } ),
    #                         m?.so?.bad
    #                       )


#run()   # # print out a CSON version on STDOUT - (needed only when the grammar generation happens during a build)
