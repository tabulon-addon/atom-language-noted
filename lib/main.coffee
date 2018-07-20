{CompositeDisposable} = require 'atom'
_      = require('./utils')
atomic = require './atomic'
noted  = require './grammar-noted'


module.exports = {
  scopeName    : 'text.noted'  # constant.
  pkgName      : 'language-noted'      # constant. See below for stuff related to +#<package CONFIGURATION>
  cfg          : undefined
  activate:   (state) ->
    @subscriptions = new CompositeDisposable
    # PkgConfig: Utility class that deals with configuration settings for our atom package
    @cfg = new atomic.PkgConfig(prefix: @pkgName + '.', schema: @config )
    @cfg.fetch()
    @reactToChange()
    @cfg.watch( onRefreshed: (args...) => @reactToChange(args...) )

  deactivate: ->
    # @cfg.dispose()
    @subscriptions.dispose()

  serialize: ->

  reactToChange: ( args... )        ->  # Note the FAT arrow
    _.dump data: {_msg: 'config refreshed. Updating grammar.'}
    @updateGrammar()

  recompute         :  ( h = {} ) ->  # !#always +#'apply' this routine to a stash or configuration stash (@cfg.stash)
    _.dump(data:h)
    _.mapProps  {
                  obj: h
                  transform: (val) -> String(val)
                  mappings:  { injectionSelector: 'injectionSelectors' }
                }


    # Parts of the code works with @disable flags (instead of @enable); so we make an 'inverted' version of some sorts...
    h.disable = _.mapProps  {
                              src: h?.enable ? {}
                              transform: (val) -> if _.isObject(val) then undefined else not Boolean(val ? true)
                              # transform: (val) -> true # not ( Boolean(val ? true) ? true )
                              dump: true  # debug
                            }
    _.dump data: { _msg: 'recomputed config stash', stash: h }
    return h

  updateGrammar     :  ()         -> @removeGrammar(); @registerGrammar()     # maybe @removeGrammar() first
  removeGrammar     :  ()         -> atom.grammars.removeGrammarForScopeName @scopeName
  registerGrammar   :  ()         -> ags = atom.grammars; @subscriptions.add ags.addGrammar ags.createGrammar( __filename, noted.grammar( @recompute(@cfg.stash) ) )
} # module.exports

module.exports
order = 10
module.exports.config =  configSchema = {              # Atom schema for our config settings.
  intro:
    order: order++, type: 'object', default: {}
    description: [
      "**ATTENTION**: You must **restart Atom** or at least **reload the window** after changing any of the settings below. ",
      #
      """
      This is because the grammar for [language-noted] is dynamically [re-]generated based on configuration seetings herein.
      As it seems, Atom simply expects and assumes language grammars to be non-dynamic entities defined in static CSON files .
      """,
    ].join('<br/><br/>')
  injectionSelectors: # the string version (+#injectionSelector) is calculated by the !@recompute() method :
                      # that one is naturally more suitable for ##<variable intrapolation> and/or ;#<macro expansion>,
    order: order++, type: 'array',  default: ['comment', 'text.plain']
    items:
      type: 'string'   #, enum: ['comment', 'text.plain']
    description: [
      "A comma separated list of **atom syntax scopes** where this grammar will `inject` (and hence activate) itself.",
      #
      """
      Normally, the default value should be just fine in most cases. In particular, the `comment` scope should simply work with any source language that
      correctly marks comment regions as such.
      """,
      #
      """
      `text.plain`, on the other hand, is really a matter of taste and usage patterns. If you do not want your plain texts files to be highlighted at all,
      then just remove it from the list.
      """
    ].join('<br/><br/>')
  enable:
    order: order++, type: 'object'
    properties:
      todoMore:
        order: order++, type: 'boolean', default: true
        title: "Mimic 'todo-more-words'"
        description:  [
          "default : `enabled`",
          #
          "Try to mimic [language-todo-more-words](<https://github.com/jameelmoses/atom-language-todo-more-words>), using its word-list."
        ].join('<br/><br/>')

      radar:
        order: order++, type: 'boolean', default: true
        description:  [
          "default : `enabled`",
          #
          """
          The `radar` syntax (e.g. <radar://issue/143> ) is supported by several language packages, including [language-todo] and its derivatives.
          It may come quite handy for relating issues/bug reports to an actual text region in the source.
          """
        ].join('<br/><br/>')

      notelet:
        order: order++, type: 'boolean', default: true
        description: [
          "default : `enabled`",
          #
          """
          The `notelet` syntax (e.g. !@HACK) is normally provided by [language-notelet].
          It lets you jot down any annotation along with a `spirit` in which it will be highlighted.
          """
        ].join('<br/><br/>')

      noted:
        order: order++, type: 'boolean', default: true
        description: [
          "default : `enabled`",
          #
          """
          If you really wanted to, you may use this to _disable_ the **grammar** while preserving the rest of the resources provided by this package
          (such as **stylesheets** that do basic highlighting for scopes normally marked by `[language-noted]`).
          """,
          #
          """
          Naturally, for this to be of _any_ use _(compared to disabling the package althogether)_, you would probably need **another** _language package_
          (perhaps yours?) that marks syntax scopes in a way that is compatible with `[language-noted]`.
          """
        ].join('<br/><br/>')
}
