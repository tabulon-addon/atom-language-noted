{makeGrammar, rule} = require('atom-syntax-tools')

grammar =
  name: "JSON"
  scopeName: "source.json"
  keyEquivalent: "^~J"
  fileTypes: [ "json" ]

  macros:
    # for demonstartion purpose, how to use regexes as macros
    hexdigit: /[0-9a-fA-F]/
    en: "entity.name"
    pd: "punctuation.definition"
    ps: "punctuation.separator"
    ii: "invalid.illegal"

  patterns: [
    "#value"
  ]

  repository:
    array:
      n: "meta.structure.array"
      b: /\[/
      c: "{pd}.array.begin"
      e: /\]/
      C: "{pd}.array.end"
      p: [
        "#value"

        rule
          m: /,/
          n: "{ps}.array"

        rule
          m: /[^\s\]]/
          n: "{ii}.expected-array-separator"

      ]
    constant:
      n: "constant.language"
      m: /\b(?:true|false|null)\b/
    number:
      # this comment is just for demonstration, you will rather use
      # normal coffee comments
      comment: "handles integer and decimal numbers"
      n: "constant.numeric"
      # This multiline match with be boiled down into a single linen regular
      # expression. See http://coffeescript.org
      m: ///
        -?        # an optional minus
        (?:
          0       # a zero
        |         # ...or...
          [1-9]   # a 1-9 character
          \d*     # followed by zero or more digits
        )
        (?:       # optional decimal portion
          (?:
            \.    # a period
            \d+   # followed by one or more digits
          )?
          (?:
            [eE]  # an e character
            [+-]? # followed by an optional +/-
            \d+   # followed by one of more digits
          )?      # make exponent optional
        )? ///

    object:
      # "a JSON object"
      n: "meta.structure.dictionary"
      b: /\{/
      c: "{pd}.dictionary.begin"
      e: /\}/
      C: "{pd}.dictionary.end"
      p: [
        "#string"   # JSON object key

        rule
          b: /:/
          c: "{ps}.dictionary.key-value"
          e: /(,)|(?=\})/
          C:
            1: "{ps}.dictionary.pair"
          n: "meta.structure.dictionary.value"
          p: [
            "#value" # JSON object value
            rule m: /[^\s,]/, n: "{ii}.expected-dictionary-separator"
          ]

        rule
          m: /[^\s\}]/
          n: "{ii}.expected-dictionary-separator"

      ]
    string:
      b: /"/
      c: "{pd}.string.begin"
      e: /"/
      C: "{pd}.definition.string.end"
      n: "string.quoted.double"
      p: [
        rule
          n: "constant.character.escape"
          m: ///
            \\               # literal backslash
            (?:              # ...followed by...
              ["\\/bfnrt]    # one of these characters
              |              # ...or...
              u              # a u
              {hexdigit}{4}  # and four hex digits
            ) ///
        rule
          m: /\\./
          n: "{ii}.unrecognized-string-escape"
      ]
    value: [     # the 'value' diagram at http://json.org
      "#constant"
      "#number"
      "#string"
      "#array"
      "#object"
    ]

makeGrammar grammar, "CSON"
