{CompositeDisposable} = require 'atom'
_      = require('./utils')
atomic = require './atomic'
noted  = require './grammar-noted'


module.exports = {
  scopeName    : 'text.noted'  # constant.
  configPrefix : 'noted.'      # constant. See below for stuff related to +#<package CONFIGURATION>
  activate:   (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add @cfg = new atomic.PkgConfig(prefix: @configPrefix, schema: @config, watch: @onConfigChanged )  # Utility class that deals with configuration settings for our atom package
    @cfg.fetch() and @cfg.watch()
    @updateGrammar()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  onConfigChanged   :  ()         => @updateGrammar() # Note the FAT arrow
  recompute         :  ()         ->  # !#always +#'apply' this routine to a stash or configuration hash (@cfg.hash)
    a = @injectionSelectors || []
    @injectionSelector = a.join(', ')
    return this
  updateGrammar     :  ()         -> @recompute.apply(@cfg.hash); @removeGrammar(); @addGrammar()
  removeGrammar     :  ()         -> atom.grammars.removeGrammarForScopeName @scopeName
  addGrammar        :  ()         -> @subscriptions.add atom.grammars.addGrammar( atom.grammars.createGrammar  __filename, noted.grammar({enableNoteletSyntax: false}) )

}

module.exports.config =  configSchema = {               # Atom schema for our config settings.
  enableNotedGrammar:
    order: 10, type: 'boolean', default: true
    description: 'default : `enabled`<br/>\
    **For ADVANCED USERS ONLY!** You may use this to **disable** the grammar while preserving the rest of the resources provided by this package (such as **stylesheets** that do basic highlighting for scopes normally marked by `[language-noted]`). <br/><br/>\
    Note that disabling the **grammar** does NOT result in disabling the [language-noted] package (unless you disable the whole package through atom)<br/><br/>\
    Naturally, for this to be of _any_ use _(compared to disabling the package althogether)_, you would probably need **another** _language package_ (perhaps yours?) that marks syntax scopes in a way that is compatible with `[language-noted]`. '

  injectionSelectors: # the string version (+#injectionSelector) is calculated by the !@recompute() method :
                      # that one is naturally more suitable for ##<variable intrapolation> and/or ;#<macro expansion>,
    order: 15, type: 'array',  default: ['comment', 'text.plain']
    description: 'A comma separated list of **atom syntax scopes** where this grammar will `inject` (and hence activate) itself.  <br/><br/> \
    Normally, the default value should be just fine in most cases. <br/><br/> \
    The `comment` scope should simply work with any source language that correctly marks comment regions as such, be it `line` or `block` comments, it does not matter. <br/><br/>\
    `text.plain`, on the other hand, may or may want be suitable for your needs or wishes (depending on your usage patterns and annoyance levels). If it does not work for you, then just remove it from the list. '

    items:
      type: 'string', enum: ['comment', 'text.plain']

  enableNoteletSyntax:
    order:20, type: 'boolean', default: true
    description: 'default : `enabled`<br/>\
    Enable/disable the `notelet` syntax (e.g. !@HACK ) which lets you jot down any annotation along with a `spirit` in which it will be highlighted.'

  enableRadarSyntax:
    order:25, type: 'boolean', default: true
    description: 'default : `enabled`<br/>\
    Enable/disable the `radar` syntax (e.g. <radar://issue/143> ), supported by several language packages, including [language-todo] and its derivatives. The `radar` syntax may come quite handy for relating issues/bug reports to an actual text region in the source.'

  mimicTodoMoreWords:
    order: 30, type: 'boolean', default: true
    title: 'Mimic [language-todo-more-words]'
    description: 'Try to mimic [language-todo-more-words](<https://github.com/jameelmoses/atom-language-todo-more-words>), using its word-list'
}
