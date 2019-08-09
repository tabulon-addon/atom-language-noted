#
# This script is used as a scratch-board during development
# It has no direct use for the normal functioning of this package.
#
_ = require './thunderscore.coffee'

_.dump _msg: 'Hello World!', data: {__filename}

#####################################################
o = { name: 'John', age: '42', gender: 'M', profession: 'carpenter' }
o2 = { name: 'Vanessa', age: '40', gender: 'F', profession: 'carpenter', hairColor: 'blond' }

pickers = ['eyeColor', 'name', 'age', 'hairColor']
picked  = _.pick(o, pickers)
finds   = _.lookups pickers, o, o2
found   = _.lookup  pickers, o, o2
_.dump data: { o, o2, picked, pickers, finds, found }

#####################################################
rex = /(?<!\w)(NOTELET_TEST_NOTED)\b/
src = String(rex.source)
renew= new RegExp src
_.dump data: { regex: String(rex), source: rex.source, src: src, renew: String(renew) }

for r in [ {name: 'rex', regex: rex}, {name: 'renew', regex: renew}]
  console.log "Now trying with regex '#{r.name}'"
  regex = r.regex
  for s in ['Hello', 'World', 'NOTELET_TEST_NOTED']
    matched = regex.test(s)
    console.log "  Match   OK: #{s}"  if matched
    console.log "  Match  NOK: #{s}"  unless matched

#####################################################
o = {}
console.log "allKeys(o), where 'o' is an empty object : #{_.allKeys(o)}"