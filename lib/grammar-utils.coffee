{CompositeDisposable} = require 'atom'
noted = require './grammar-noted.coffee'


module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    g = grammar()
    gm = atom.grammars.createGrammar __filename, g
    #@subscriptions.add g
    @subscriptions.add atom.grammars.addGrammar gm

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
