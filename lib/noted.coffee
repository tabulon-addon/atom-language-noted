_          = require './thunderscore'
grammatics = require './noted-grammatics-atomized'
settings   = require './noted-settings'   # gives us @cfg and @config (among other things)

_.extend exports, settings, {
  grammatics  : grammatics
  current     : undefined

  activate:   (state) ->
    @cfg.watch( onRefreshed: () => @update(arguments...) )   # @update() will be triggered whenever the config changes (or is fetched)
        .fetch()                                          # This will also trigger an @update() because of the watch that we have set up.
  deactivate:         ->  @cfg?.dispose(); @?.gcurrent?.dispose()
  serialize:          ->
  update: ()          ->  # !#Note that, somehow, FAT arrow does -#NOT work here (contrary to what would be expected )
    #_.dump _msg: 'config refreshed. Updating grammar.'
    past = @?.current
    @current = @grammatics.tmgUpdate @grammatics.recipe(@cfg.stash), @cfg.stash
    past?.dispose()

} # exports
