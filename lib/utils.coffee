_ = require('underscore')

# Start out by re-exporting our helper's stuff.   This helps encapsulate things.
module.exports = exports = Object.assign(_)

exports.combine       = combine       = ( sources... )              -> _.extend({}, sources...)
exports.stash         = stash         = ( defaultz = {}, args... )  -> _.extend({}, defaultz, _.object(args...))
exports.maxNumKey     = maxNumKey     = ( obj )                     -> 1 + Math.max (key for key of obj)...
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

# Strings
exports.surround            = surround = ( o = {} )                 ->    # o = options
  o.ignoreBlank   ?= true
  o.content       ?= ''
  return '' if o.ignoreBlank and ( _.isUndefined(o.content) || _.isNull(o.content) || _.isEmpty(o.content) )
  o.n             ?= 0    # by default, surround with nothing.
  return o.content if surround.
  o.with          ?= ''
  o.opener        ?= o.with
  o.closer        ?= o.with

  o.open          ?= o.opener.repeat(o.n)
  o.close         ?= o.closer.repeat(o.n)
  o.prefix        ?= ''
  o.suffix        ?= ''
  return "#{o.prefix}#{o.open}" + o.content + "#{o.close}#{o.suffix}"     #  explicit concatination for o.content, just in case it's a RegExp or something.

# RegExp
exports.re_escape_cc_char   = re_escape_cc_char  = ( c )            -> return (if contains [']', '-', '^', ',', '\\'], c then "\\" + c else c)
exports.re_surround         = re_surround     = ( args... )         -> RegExp surround(args...)
exports.re_group            = re_group        = ( o = {} )          -> re_surround _.defaults( o, {opener: '()', closer: ')'} )
exports.re_cook_quote       = re_cook_quote   = ( o = {} )          ->    # o = options. -#<NOT yet tested!>
  o.marker        ?= {}
  o.start         ?= {}
  o.end           ?= {}
  o.content       ?= {}
  o.marker         = _.defaults o.marker, { char: "'", capture: 0 }  # By default, it's a single quote
  o.start          = _.defaults o.start,  o.marker

  for k in ['start', 'end']
    o[k]            = _.defaults o[k],    o.marker
    c = o[k].c     ?= re_escape_cc_char o[k].char
    o[k].regex     ?= re_group n: o[k].capture, content: ///[#{c}]///

  o.content        = _.defaults o.content, { capture: 1 }
  c                = re_escape_cc_char( o.end.char )
  o.content.regex ?= re_group n: o.content.capture, content: ///(?:[^#{c}\\]|[\\].)*///
  regex            = ///#{o.start.regex}#{o.content.regex}#{o.end.regex}///
  return regex

# Console
exports.dump = (data) ->
  indentation = 2
  transform = (k, v) -> return (if _.isRegExp(v) then '/' + v.source + '/' else v)
  console.warn JSON.stringify(data, transform, indentation)
