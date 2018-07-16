_ = require('underscore')

# Start out by re-exporting our helper's stuff.   This helps encapsulate things.
module.exports = exports = Object.assign(_)

exports.combine       = combine       = ( sources... )              -> _.extend({}, sources...)
exports.stash         = stash         = ( defaultz = {}, args... )  -> _.extend({}, defaultz, _.object(args...))
exports.simpleValue   = simpleValue   = ( val )                     -> return (if _.isRegExp(val) || not _.isObject(val) then val else JSON.stringify(val) )
exports.simplify      = simplify      = ( obj = {} )                -> _.mapObject(obj, simpleValue)
exports.resolve       = resolve       = ( m = stash(), it )         ->
  switch
    when _.isFunction(it) then return it(m)
    when _.isArray(it)    then return ( it.map (item) -> resolve(m, item) )
    when _.isObject(it)
      res = {}
      res[k] = resolve(m, v) for k,v of it
      return res

    else return it
