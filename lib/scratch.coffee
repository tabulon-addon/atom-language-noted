#
# This script is used as a scratch-board during development
# It has no direct use for the normal functioning of this package.
#
grammar = require './noted-grammar.coffee'
_ = require './utils.coffee'

_.dump _msg: 'Hello World!', data: { __filename }
opts = { enable: { NoteletSyntax: true}, injectionSelector: 'text.plain'}
g = new grammar.Grammar(opts)
#_.dump _msg: 'Created grammar', data: g

gbaked = g.resolve( opts )
_.dump _msg: 'Baked grammar', data: gbaked


# lexer = {
#   todoMore: {
#     disabled: false
#     #head: { mode:1, cc:/[@#]/.source }    # 1: Accepted but NOT required. 2 & 3: required. 4. Forbidden
#     subrules: [
#       { mood: 'deprecated', re_body: /DEPRECATED/                                                     }
#       { mood: 'bad',        re_body: /WTF|BUG|ERROR|OMG|ERR|OMFGRLY|BROKEN|REFACTOR/                  }
#       { mood: 'fishy',      re_body: /WARNING|WARN|HACK/                                              }
#       { mood: 'neutral',    re_body: /NOTE|INFO|IDEA|DEBUG|REMOVE|OPTIMIZE|REVIEW|UNDONE|TODO|TASK/   }
#     ]
#   }
# }
#
# _.dump _msg: "Creating lexicon:", data: lexer
# lex = new grammar.Lexicon(lexer)
# _.dump _msg: "Created lexicon:", data: lex
#
# _.dump _msg: "Resolving lexicon..."
# lexed = _.resolve lex, stash
# _.dump _msg: "Resolved lexicon...", data: lexed

re = /(?<!\w)(NOTELET_TEST_NOTED)\b/
src = String(re.source)
renew= new RegExp src
_.dump data: { regex: String(re), source: re.source, src: src, renew: String(renew) }

for r in [ {name: 're', regex: re}, {name: 'renew', regex: renew}]
  console.log "Now trying with regex '#{r.name}'"
  regex = r.regex
  for s in ['Hello', 'World', 'NOTELET_TEST_NOTED']
    matched = regex.test(s)
    console.log "  Match   OK: #{s}"  if matched
    console.log "  Match  NOK: #{s}"  unless matched
