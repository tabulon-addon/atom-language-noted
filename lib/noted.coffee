_        = require './utils'
atomized    = require './atomized'         # gives us atom-specific stuff
grammatics  = require './noted-grammar'
grammatics  = _.defaults grammatics, atomized.grammatics
settings    = require './noted-settings'   # gives us @cfg and @config (among other things)

_.extend exports, settings, {
  grammatics  : grammatics
  gcurrent : undefined

  activate:   (state) ->
    @cfg.watch( onRefreshed: () => @update(arguments...) )   # @update() will be triggered whenever the config changes (or is fetched)
        .fetch()                                          # This will also trigger an @update() because of the watch that we have set up.
  deactivate:         ->  @cfg?.dispose(); @?.gcurrent?.dispose()
  serialize:          ->
  update: ()          ->  # !#Note that, somehow, FAT arrow does -#NOT work here (contrary to what would be expected )
    #_.dump _msg: 'config refreshed. Updating grammar.'
    gpast = @?.gcurrent
    @?.gcurrent = @grammatics.tmgUpdate @grammatics.recipe(@cfg.stash), @cfg.stash
    gpast?.dispose()

} # exports
