{CompositeDisposable} = require 'atom'
gNoted = require './grammar-noted.coffee'


module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @registerGrammar()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  registerGrammar: () ->
    @subscriptions.add atom.grammars.addGrammar ( atom.grammars.createGrammar  __filename, gNoted.grammar() )
