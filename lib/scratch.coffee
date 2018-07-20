#
# This script is used as a scratch-board during development
# It has no direct use for the normal functioning of this package.
#
gNoted = require './grammar-noted.coffee'
_ = require './utils.coffee'

_.dump data : {greetings: 'Hello World!', __filename: __filename}
stash = { enable: { NoteletSyntax: true}, injectionSelector: 'text.plain'}
#grammar = gNoted.grammar( stash )
_.dump data : { grammar : gNoted.grammar( stash ) }

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

#_.dump data: {defaults : gNoted.defaults(), simplified: _.simplify gNoted.defaults() }
