#---------------------------------------------------------------------------------------
# Below are a bunch of tokens for a quick reference and also a brief visual test for [language-noted].
#
# ~@AUTHOR @@MENTION   #@HASHTAGGY :@EAGER ,@BLAND ;@DULL &@VERBOSE +@GOOD ?@QUESTION  >@PERTINENT !@ALERT *@FISHY -@BAD %@SHAKY _@SPOOKY @NONE
# ~#AUTHOR @#MENTIONNY ##HASHTAG   :#EAGER ,@BLAND ;@DULL &@VERBOSE +#GOOD ?#QUESTION  >#PERTINENT !#ALERT *#FISHY -#BAD %#SHAKY _#SPOOKY #NONE
#
# Angle bracketed strings, like +@<this one> should also be supported.
#
# RADAR:  <radar://issue/124> (radar links are always rendered the same as >@PERTINENT)
#---------------------------------------------------------------------------------------

{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: 'NOTED'
  scopeName: 'text.noted'
  injectionSelector: 'comment, text.plain'


  macros:
    # for demonstartion purpose, how to use regexes as macros
    hexdigit: /[0-9a-fA-F]/
    radar_match:/<(ra?dar:\/(?:[\/](?:problems?|issues?|tickets?|bug-reports?|bugs?|reports?))\/(?:[&0-9 .%;A-Aa-z_]+))>/
    en: "entity.name"
    pd: "punctuation.definition"
    ps: "punctuation.separator"
    ii: "invalid.illegal"

    #notelet_match_NOK:       ///(?<!\w)(((([%_\-*!>+?:\,;&~#@])+)((?:[0-9])?))((([#@])(((?:\w|[\-])+|(?:[<]([^<>]*)[>]))))))\b///
    #notelet_match_OK: /(?<!\w)(((([%_\-*!>+?:\,;&~#@])+)((?:[0-9])?))((([#@])(((?:\w|[\-])+)))))\b/

    spiritc: /[%_\-*!>+?:\,;&~#@]/
    notelet_match: /(?<!\w)(((({spiritc})+)((?:[0-9])?))((([#@])(((?:\w|[\-])+)))))\b/

  patterns: [
    '#notelet'
    '#radar'
  ]

  repository:
    notelet:
      match: ///
              (?<!\w)
              (                               # 1: The entire notelet expression that has matched
                (                             # 2: ( spirit-term : Only the portion BEFORE the reftype character (#@)
                  (                           # 3:  ( spirit designator :  (may be one or more characters)
                    ([%_\-*!>+?:\,;&~#@])+    # 4:     . spirit marker     : normally just the single char symbol that denotes the spirit. We are NOT really limited to 1-char; but it keeps things simpler.
                  )                           # 5:  ) spirit designator
                  ((?:[0-9])?)                # 6:  . spirit-Vigor. UNDOCUMENTED for the moment.
                )                             # 1: ) spirit-term
                (
                  ([#@])
                  (
                    (?:\w|[\-])+
                  )
                )
              )
              \b
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
        8: name: 'meta.notelet.label.text.noted'


    # For language-TODO emulation.
    radar: {
      match: '{radar_match}'
      name: 'storage.type.class.radar.spirit.pertinent.text.noted'
      captures:
        1: name: 'markup.underline.link.radar.standout.spirit-pertinent.text.noted'
    }


makeGrammar grammar, "CSON"
