{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: 'NOTED'
  scopeName: 'text.noted'
  injectionSelector: 'comment, text.plain'


  macros:
    # for demonstartion purpose, how to use regexes as macros
    hexdigit: /[0-9a-fA-F]/
    radar_match:/<(ra?dar:/(?:[/](?:problems?|issues?|tickets?|bug-reports?|bugs?|reports?))/(?:[&0-9 \-.%\,;A-Aa-z_]+))>/
    en: "entity.name"
    pd: "punctuation.definition"
    ps: "punctuation.separator"
    ii: "invalid.illegal"

    notelet_match: /(?<!\w)(((([%_\-*!>+?:\,;&~#@])+)((?:[0-9])?))((([#@])(((?:\\w|[\-])+)))))\b/
    notelet_match2: /(?<!\w)(((([%_\-*!>+?:\,;&~#@])+)((?:[0-9])?))((([#@])(((?:\w|[\-])+|(?:[<]([^<>]*)[>]))))))\b/

  patterns: [
    '#notelet'
    '#radar'
  ]

  repository:
    notelet:
      match: notelet_match
      captures:
        1: name: 'meta.notelet.text.noted'
        2: name: 'punctuation.definition.notelet.spirit.term.text.noted'
        3: name: 'punctuation.definition.notelet.spirit.designator.text.noted'
        4: name: 'punctuation.definition.notelet.spirit.marker.text.noted'
        5: name: 'punctuation.definition.notelet.spirit.vigor.text.noted'
        6: name: 'meta.notelet.reference.text.noted'
        7: name: 'markup.standout.spirit-marker-${4:/downcase}.vigor-${5:/downcase}.text.noted'
        8: name: 'punctuation.definition.notelet.reftype.text.noted'
        9: name: 'meta.notelet.label.text.noted'
       10: name: 'entity.name.tag.notelet.text.noted'

    # For language-TODO emulation.
    radar: {
      match: radar_match
      name: 'storage.type.class.radar.spirit.pertinent.text.noted'
      captures:
        1: name: 'markup.underline.link.radar.standout.spirit-pertinent.text.noted'
    }


makeGrammar grammar, "CSON"
