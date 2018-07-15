
gNoted = require './grammar-noted.coffee'

logDump = (data) ->
  indentation = 2
  console.log JSON.stringify(data, null, indentation)

logDump (greetings: 'Hello World!', __filename: __filename)
logDump (gNoted.grammar())

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
