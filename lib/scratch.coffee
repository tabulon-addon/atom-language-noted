#
# This script is used as a scratch-board during development
# It has no direct use for the normal functioning of this package.
#
grammar = require './noted-grammatics.coffee'
_ = require './thunderscore.coffee'

_.dump _msg: 'Hello World!', data: { __filename }
opts = enable: { noted:true,  notelet:true}, injectionSelector: 'text.plain'
g = new grammar.Grammar(opts)
#_.dump _msg: 'Created grammar', data: g

gbaked = g.resolve( opts )
#_.dump _msg: 'Baked grammar', data: gbaked
