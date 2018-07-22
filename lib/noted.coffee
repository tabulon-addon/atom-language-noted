_      = require('./utils')
atomized = require './atomized'         # gives us atom-specific stuff
grammar  = require './noted-grammar'
grammar  = _.defaults grammar, atomized.grammar
settings = require './noted-settings'   # gives us @cfg and @config (among other things)

lingo = exports
_.extend exports, settings, {
  grammar : grammar
  activate:   (state) ->
    @cfg.watch( onRefreshed: () => @update(arguments) )   # @update() will be triggered whenever the config changes (or is fetched)
        .fetch()                                          # This will also trigger an @update() because of the watch that we have set up.
  deactivate:         ->  @cfg.dispose()
  serialize:          ->
  update: ()          ->  # !#Note that, somehow, FAT arrow does -#NOT work here (contrary to what would be expected )
    #_.dump data: {_msg: 'config refreshed. Updating grammar.'}
    @grammar.tmgUpdate @grammar.recipe(@cfg.stash)
} # exports
