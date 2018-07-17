#
# This script is used as a scratch-board during development
# It has no direct use for the normal functioning of this package.
# 
gNoted = require './grammar-noted.coffee'
_ = require './utils.coffee'

logDump = (data) ->
  indentation = 2
  transform = (k, v) -> return (if _.isRegExp(v) then '/' + v.source + '/' else v)
  console.log JSON.stringify(data, transform, indentation)

logDump (greetings: 'Hello World!', __filename: __filename)
logDump (proto_grammar: gNoted.proto.grammar(), grammar : gNoted.grammar())

re = /(?<!\w)(NOTELET_TEST_NOTED)\b/
src = String(re.source)
renew= new RegExp src
logDump(regex: String(re), source: re.source, src: src, renew: String(renew))

for r in [ {name: 're', regex: re}, {name: 'renew', regex: renew}]
  console.log "Now trying with regex '#{r.name}'"
  regex = r.regex
  for s in ['Hello', 'World', 'NOTELET_TEST_NOTED']
    matched = regex.test(s)
    console.log "  Match   OK: #{s}"  if matched
    console.log "  Match  NOK: #{s}"  unless matched

logDump defaults : gNoted.defaults(), simplified: _.simplify(gNoted.defaults())
