_          = require './thunderscore'
atomized   = require './atomized'                             # gives us atom-specific stuff
grammatics = require './noted-grammatics'                     # gives us stuff specific to our language
grammatics = _.defaults {}, grammatics, atomized?.grammatics  # combines the two

module.exports = exports = grammatics
