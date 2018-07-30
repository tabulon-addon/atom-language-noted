_      = require('./thunderscore')
atomized = require './atomized'

settings = exports
settings.pkgName = pkgName = 'language-noted'
settings.PkgConfig = class PkgConfig extends atomized.PkgConfig
  defaults: () -> _.extended super(), _.pick(settings, ['pkgName', 'config'] )
  recompute: ( h = @stash ) ->    # Normmaly,  this routine is +#'applied' to a stash or configuration stash (@stash)

    super (h)

    #_.dump data: {stash:h}
    _.mapProps  {
                  obj: h
                  transform: (val) -> String(val)
                  mappings:  { injectionSelector: 'injectionSelectors' }
                }


    # Parts of the code works with @disable flags (instead of @enable); so we make an 'inverted' version of some sorts...
    h.disable = _.mapProps  {
                              src: h?.enable ? {}
                              transform: (val) -> if _.isObject(val) then undefined else not Boolean(val ? true)
                            }
    #_.dump _msg: 'recomputed CONFIG stash', data: {stash: h}
    return h
settings.config =  schema = {              # Atom schema for our config settings.

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
        title: "Enable mimicing 'todo-more-words'"
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
} for order in [10]

settings.cfg = new PkgConfig()  # This must come at the end, since the constructor call will use various properties of 'settings'
