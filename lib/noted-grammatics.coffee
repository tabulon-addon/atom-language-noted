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

helper = require('./grammatics')
_      = require('./thunderscore')

exports.rules         = rules  = rule = {} # for sugar & easy referral

exports.recipe        = recipe        = () -> new Grammar(arguments...)
exports.bake          = bake          = () -> g = recipe(arguments...); g.resolve(arguments...)
exports.writeOut      = writeOut      = () -> g = recipe(arguments...); g.writeOut(arguments...)
exports.run           = run           = () -> writeOut(arguments...)   #  generates a static CSON atom grammar and prints it on STDOUT


exports.spirits       = spirits       = () ->
  """
  alert, artisan, bad, bland, curious, default, deprecated,
  dull, eager, fishy, good, hashtaggy, neutral, mentionny,
  pertinent, shaky, spooky, verbose
  """.split(/(?:[\,]|\s)+/)
exports.spiritful     = spiritful     = (mood = 'neutral') ->  'spirit-' + mood
exports.scopeDefs     = scopeDefs     = () ->
  # Figure out the applicable mood (spirit) and related syntax scope
  mood          = this?.mood              ? 'neutral'
  gravy         = this?.spiritful?(mood)  ? spiritful(mood)

  {
    suffix: 'text.noted'
    noted : 'text.noted'                                # The SUFFIX that we append on all scopes we mark on our captures.
    meta  : 'meta.notelet'

    # for pun :-)
    note  : 'markup.notelet'                            # Our main scope PREFIX;
    poke  : 'markup.notelet.standout'                   # Our main scope PREFIX that is supposed to be highlighted
    punk  : 'punctuation.definition.notelet.standout'   # Punctuation scope PREFIX
    link  : 'markup.underline.link'
    radar : "markup.radar.standout.spirit-pertinent"

    gladly : 'spirit-${4:/downcase}${5:/downcase}${6:/downcase}${7:/downcase}.vigor-${8:/downcase}'
    pertinently : "standout.spirit-pertinent"
    gravy: gravy
  }
exports.scopes        = scopes        = () ->
  # Figure out the applicable mood (spirit) and related syntax scope
  mood          = this?.mood              ? 'neutral'
  gravy         = this?.spiritful?(mood)  ? spiritful(mood)

  _.defaulted  {mood, gravy}, scopeDefs()
exports.standouts     = standouts     = () ->
  so = {};
  so[i] = 'standout.' + spiritful(i) for i in spirits()
  return so

exports.Grammar       = class Grammar extends helper.Grammar
  constructor:          ()          -> super(arguments...)
  scopes:               ()          -> _.extended super(arguments...), scopes.call(this, arguments...)
  vars:                 ()          -> _.extended super(arguments...),  {
    # Defaults for the stash (usually named 'm' thoughout the code) that are used for variable interpolation (Coffee style)
    so: standouts()                # Hash
  }
  defs:                 ()          -> _.extended super(arguments...), {
    # Below are some defaults used for our grammar.
    name: 'Noted'
    scopeName: 'text.noted'
    injectionSelector: 'comment, text.plain'
  }
  patterns:             ()          ->  [ # adjusted elsewhere programmatically in order to eliminate patterns that are 'disabled'.
    { include: '#notelet'   }
    { include: '#radar'     }
    { include: '#todoMore'  }
  ]
  rules:                ()          ->
    _.extended super(arguments...), {
      notelet: () -> new Notelet arguments...
      radar: ()   -> new Radar   arguments...
    }
  lexiconClass:         ()          ->  Lexicon
  lexicons:             ()          -> {
    todoMore: { # todo-more-words
      subrules: [
        { mood: 'deprecated', re_body: /DEPRECATED/                                                     }
        { mood: 'bad',        re_body: /WTF|BUG|ERROR|OMG|ERR|OMFGRLY|BROKEN|REFACTOR/                  }
        { mood: 'fishy',      re_body: /WARNING|WARN|HACK/                                              }
        { mood: 'neutral',    re_body: /NOTE|INFO|IDEA|DEBUG|REMOVE|OPTIMIZE|REVIEW|UNDONE|TODO|TASK/   }
      ]
    }
  }

rule.Notelet  = class Notelet extends helper.GrammaticRule
  constructor:  () -> super(arguments...)
  scopes:       () -> _.extended super(arguments...), scopes.call(this, arguments...)
  match:        () ->
    {m, s} =  @context(arguments...)
    re_notelet_term           = () ->
      # see below for the definitions of these
      re_spirit_term   = re_notelet_spirit_term().source
      re_standout_term = re_notelet_standout_term().source

      # !@NOTE: Regex "comments" are not reported as being in "comment" scope by [language-coffescript.]
      # Therefore [language-noted] syntax-highlighting won't work within those.

      ///
      (?:^|\s|\W)                                               # NOTELET is required to be immediately preceded by whitespace or a non-word character, or else start on a newline.
      # <<<<<<< BEGIN: notelet-term
      (                                                         # < 1: NOTELET-term             // The entire notelet expression that has matched
        #{re_spirit_term}
        #{re_standout_term}
      )                                                         # > 1: NOTELET-term
      # >>>>>>> END: notelet-term
      ///
    re_notelet_spirit_term    = () => ///
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
    re_notelet_standout_term  = () => ///
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

    result = re_notelet_term()
  captures:     () ->
    # !@NOTE that, to keep things DRY, the captures are actually set ,@programmatically below;
    # ( since we have a gzillian of them due to lack of support for branch resets )
    {m, s} =  @context(arguments...);
    caps = [  # !#ARRAY
      undefined                                   # we do NOT do anything with $0.
      "#{s.meta}.term.#{s.suffix}"
      "#{s.punk}.spirit.term.#{s.suffix}"
      "#{s.punk}.spirit.designation.#{s.suffix}"   # similar to 'marker' below, but includes the whole string in case of delimited (or repeated) marker (symbol.)
      "#{s.punk}.spirit.marker.#{s.suffix}"
      "#{s.punk}.spirit.marker.#{s.suffix}"
      "#{s.punk}.spirit.marker.#{s.suffix}"
      "#{s.punk}.spirit.marker.#{s.suffix}"
      "#{s.punk}.spirit.vigor.#{s.suffix}"
      "#{s.poke}.term.#{s.gladly}.#{s.suffix}"
      "#{s.poke}.head.#{s.gladly}.#{s.suffix}"
      "#{s.poke}.body.#{s.gladly}.#{s.suffix}"
    ]

    # The following is done for the sake of DRY. It makes for more lines of code (but hopefully more maintainable)
    marrow_quoted_forms = [ 'single', 'double', 'angle_bracket', 'square_bracket', 'parens' ]
    marrow_caps_std = [
      "#{s.punk}.marrow.start.#{s.suffix}"
      "#{s.poke}.marrow.#{s.gladly}.#{s.suffix}"
      "#{s.punk}.marrow.end.#{s.suffix}"
    ]
    caps      = caps.concat _.flatten(_.times(marrow_quoted_forms.length + 1, () -> marrow_caps_std))
    return caps

rule.Radar    = class Radar   extends helper.GrammaticRule
  constructor:  () -> super(arguments...)
  scopes:       () -> _.extended super(arguments...), scopes.call(this, arguments...)
  match:        () -> /((<)((ra?dar:\/(?:[\/](problems?|issues?|tickets?|bug-reports?|bugs?|reports?))\/([&0-9 .%;A-Aa-z_]+)))(>))/.source
  name:         () ->
    {m, s} =  @context(arguments...);
    "storage.type.class.radar.#{s.pertinently}.#{s.suffix}"
  captures:     () ->
    {m, s} = @context(arguments...);
    {
      1: name: "#{s.meta}.radar.#{s.suffix}"
      2: name: "#{s.punk}.radar.start.#{s.suffix}"
      3: name: "#{s.link}.radar.body.#{s.pertinently}.#{s.suffix}"  # radar.body is marked twice. This one is for language-todo/-more-words compatibility
      4: name: "#{s.radar}.body.#{s.suffix}"                        #                             And this one is in our own way.
      5: name: "#{s.radar}.type.#{s.suffix}"
      6: name: "#{s.radar}.marrow.#{s.suffix}"
      7: name: "#{s.punk}.radar.end.#{s.suffix}"
    } # END: radar captures

rule.Lexicon  = class Lexicon extends helper.Lexicon
  constructor:  () -> super(arguments...)
  scopes:       () -> _.extended super(arguments...), scopes.call(this, arguments...)




#run()   # # print out a CSON version on STDOUT - (needed only when the grammar generation happens during a build)
