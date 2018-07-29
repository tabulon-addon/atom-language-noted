#
# This script is used as a scratch-board during development
# It has no direct use for the normal functioning of this package.
#
_ = require './utils.coffee'

_.dump _msg: 'Hello World!', data: {__filename}

o = { name: 'John', age: '42', gender: 'M', profession: 'carpenter' }
o2 = { name: 'Vanessa', age: '40', gender: 'F', profession: 'carpenter', hairColor: 'blond' }

pickers = ['eyeColor', 'name', 'age', 'hairColor']
picked  = _.pick(o, pickers)
finds   = _.lookups pickers, o, o2
found   = _.lookup  pickers, o, o2
_.dump data: { o, o2, picked, pickers, finds, found }
