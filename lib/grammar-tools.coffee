_ = require('./utils')

exports.Resolvable  = class Resolvable
  constructor:    ()                 ->
  ingredients:    ()                 -> _.without( _.allKeys(this), 'resolve', 'constructor', @?.constructor?.name)
  dependencies:   ()                 -> {}
  context:        ()                 -> _.defaults {}, arguments...
  resolve:        ()                 ->
    #_.dump _msg: "Resolving BEGINS : ...", data: {opts, this: this }
    o    = _.extend {}, arguments..., @context(arguments...)
    deps = @dependencies(arguments...)
    that = this
    res = {}; done={}
    for pass in [0 .. 2]
      for i in @ingredients()
        continue unless i?
        continue if done?[i]                   # Don't bother recomputing a value we already have
        preqs = deps?[i]
        continue if pass >  0 and !preqs?      # non-dependants are processed ONLY during pass 0
        continue if pass == 0 and  preqs?     #     dependants are processed ONLY after  pass 0
        continue if preqs and not _.every _.arrayify(preqs), (preq) => res?[preq]?

        #_.dump _msg: "Resolving ingredient : #{i} ..."

        item = @?[i + '_x' ] ? @[i]
        continue unless item?
        res[i] = _.resolve.call(that, item, o) #if _.isFunction(item) then item(o) else item
        done[i] = true

    return unless _.keys(res).length > 0
    return res

  writeOut:       ( o = {} )        ->
    data = @resolve(arguments...)
    _.writeOut _.defaults( {}, {data}, o )

# # generates patterns for lexicons/wordlists like those for [language-todo] and its derivatives
exports.GrammaticFragment  = class GrammaticFragment extends Resolvable
  defs:           ()                 -> {}
  vars:           ()                 -> {}
  isGrammatical:  ()                 -> true
  ingredients:    ()                 -> ['comment', 'name', 'patterns']
  dependencies:   ()                 -> {}
  constructor:    ( opts = {} )      ->
    super( arguments... )
    stashies = [ 'm',     'stash',  'vars'  ]
    scopies  = [ 'scopes', 'scope', 's'     ]
    specials =  _.union(stashies, scopies, ['defs'] )

    #_.dump _msg: 'Constructing lexicon.', data: {opts}
    defs = _.compact _.resolve( [@?.defs, opts?.defs])
    o = _.extend this, defs..., _.omit(opts, specials)

    stashes = []
    for obj in [ opts, this ]
      for k in stashies
        stashes.push _.resolve.call(obj, obj[k])
    stashes = _.compact(stashes)
    @stash = _.defaults {},  stashes...

    scopes = _.defaults  {},  opts?.scopes, opts?.scope, opts?.s, @stash?.scopes, @stash?.scope, @stash?.s
    delete @stash.scopes
    @stash.scopes = scopes if _.keys(scopes).length > 0

    name_lc    = String::toLowerCase(@?.name)
    @disabled ?= name_lc? and ( @?.disable?[name_lc] or  @stash?.disable?[name_lc] )  # determine if the entire grammar should be disabled.

  scopeDefs:      ()                ->
    {
      prefix: ''
      suffix: ''
      meta: 'meta'
      punc: 'punctuation'
      punk: 'punctuation.definition'
      poke: 'markup.other.poke'
      soft: 'markup.other.soft'
    }
  scopes:         ( opts = {} )     ->
    o = _.defaults {}, arguments..., @mstash?(arguments...), { scopes: {} }
    scopes = _.defaults {}, opts?.scopes

    #_.dump _msg: 'Scopes called upon ', data: {scopes, this: this}

    scopes = _.extend {}, @scopeDefs(), scopes
    for item in ['comment', 'constant', 'entity', 'invalid', 'keyword', 'markup', 'meta', 'punctuation', 'storage', 'string', 'support', 'variable']
      scopes[item] ?= item
    return scopes

  mstash:         ( opts = {} )       ->
    o = opts;
    zoo = _.defaults {}, o?.m, o?.stash, this?.m, this?.stash, @?.vars?() #, @?.defs?() #, _.omit(o, ['m', 'stash'])  #,  ( @?.container?.mstash?(arguments...) ? {} )
    return zoo
  context:        ()                  ->
    r = { }
    r.m = r.vars  = r.stash  = @mstash(arguments...)
    r.s = r.scope = r.scopes = @scopes(arguments...)
    return r

  recipe:         ( opts = {} )       -> this # %#DEPRECATED. For backwards compatibity.
  patterns_x:     ( opts = {} )       ->
    return if @?.disabled
    patterns = _.terse _.arrayify( _.resolve(@?.patterns, arguments...),
                                    @collate(items:_.resolve(@?.subrules, arguments...), arguments...)
                                 )
    fixPatterns(patterns, arguments... )

  collate:        ( opts = {} )       ->
    o = _.defaults {}, opts
    items = o?.items ? @?.subrules ? []
    return if @disabled || !( @enabled ? true )
    stash = @mstash(opts)

    r = []  # result
    for item in items
    #  _.dump _msg: 'collating...', data: {item}
      continue unless item?
      m = _.defaults {}, item?.stash ? {}, stash ? {}
      c = if (item?.isGrammatical?() ? false) then item else new this.constructor(_.extend({}, item, {m:m}) )
      r = r.concat c if c?

    r = _.compact(r)


# Class that enables easy dynamic generation of first-mate grammars (useful for Atom language packages)
exports.Grammar = class Grammar extends GrammaticFragment
  _props: [
    'comment',
    'name',       'scopeName',
    'fileTypes',  'firstLineMatch'
    'injections', 'injectionSelector',
    'patterns',   'repository'
    'foldingStartMarker', 'foldingStopMarker',
    'limitLineLength',     'maxLineLength',     'maxTokensPerLine'
  ]
  ingredients:    () -> _.union super(arguments...), @_props
  comment:        () -> genericGrammarRemarks(); "Yorum" # @FIXME: During DEBUGGING, we just return a short string.

  rules:          () -> { } # you may wish to override this!
  constructor:    () ->
    super(arguments...)
    @filename ?= arguments?.caller?.__filename
    @disabled  = if @name? then @stash?.disable?[@name.toLowerCase()] ? false else false  # determine if the entire grammar should be disabled.  # Generic constructor should suffice in most cases,

  # patterns:       ()   ->
  # repository:     ()   ->
  repository_x:   ()   ->
    repo  = _.resolve.call(this, @?.repository, arguments... ) ? {}
    rules = _.resolve.call(this, @?.rules, arguments... )      ? {}
    _.extend {}, repo, rules

  # atom releated routines.
  tmUpdate:       () -> @tmRetire arguments... ; @tmRegister arguments...
  tmRegister:     () -> atom?.grammars?.addGrammar @tmCreate arguments...
  tmCreate:       () -> atom?.grammars?.createGrammar @filename, @resolve( arguments... )
  tmRetire:       () -> atom?.grammars?.removeGrammarForScopeName @scopeName

exports.GrammaticRule  = class GrammaticRule extends GrammaticFragment
  constructor:    ()                  -> super(arguments...)
  ingredients:    ()                  -> _.union      super(arguments...), ['comment', 'name', 'patterns', 'include', 'match', 'captures', 'begin', 'beginCaptures', 'end', 'endCaptures', 'contentName']
  dependencies:   ()                  -> _.extend {}, super(arguments...), { captures: 'match', beginCaptures:'begin', endCaptures: 'end', contentName: 'begin' }

  match:          ()                  ->
  captures:       ()                  ->
  captures_x:     ()                  -> @buildCaptures(arguments...)

  # utilities
  buildRegexen:  ( props=[], args...  )   -> buildRegexen(this, props, args...) # call global utility routine
  buildCaptures: ( opts = {} )            -> o = _.extend {}, opts, { caps: @captures(opts) };  buildCaptures o    # call global helper routine

# # generates patterns for lexicons/wordlists like those for [language-todo] and its derivatives
exports.GrammaticRuleEasy  = class GrammaticRuleEasy extends GrammaticRule
  constructor:    ()       -> super(arguments...)
  match:          ()       ->
    re = @buildRegexen?(['anterior', 'intro', 'head', 'body', 'tail', 'conclusion', 'posterior'], arguments...)
    return unless re?.body? and not _.isEmpty(re?.body)

    ///
    #{re.anterior}
    (                                                         # $1  - full term
      (#{re.intro})                                           # $2
      (                                                       # $3  - term
        (#{re.head})                                          # $4
        (#{re.body})                                          # $5
        (#{re.tail})                                          # $6
      )
        (#{re.conclusion})                                    # $7
    )
    #{re.posterior}
    ///
  captures:       ()       ->
    { m, s } = @context(arguments...)
    {
      1:  name: tidyScope "#{s.meta}.term.#{s.suffix}"
      2:  name: tidyScope "#{s.soft}.intro.#{s.gravy}.#{s.suffix}"
      3:  name: tidyScope "#{s.poke}.term.#{s.gravy}.#{s.suffix}"
      4:  name: tidyScope "#{s.poke}.head.#{s.gravy}.#{s.suffix}"
      5:
        name: tidyScope "#{s.poke}.body.#{s.gravy}.#{s.suffix}"
        patterns : [{
          match: /^.*$/.source
          name: tidyScope "#{s.poke}.marrow.#{s.gravy}.#{s.suffix}"
        }]
      6:  name: tidyScope "#{s.poke}.tail.#{s.gravy}.#{s.suffix}"
      7:  name: tidyScope "#{s.soft}.conclusion.#{s.gravy}.#{s.suffix}"
    }

# # generates patterns for lexicons/wordlists like those for [language-todo] and its derivatives
exports.Lexicon  = class Lexicon extends GrammaticRuleEasy
  constructor:    ()      -> super(arguments...)
  defs:           ()      -> _.extend {}, super(arguments...), { re_anterior:/(?:^|\s|\W)/, re_head: /[@#]?/, re_posterior:/\b/ }
  scopeDefs:      ()      ->
    _.defaults {}, {
      suffix: 'text.lexicon'
      punc: 'punctuation.lexicon'
      punk: 'punctuation.definition.lexicon'
      poke: 'markup.lexicon'
    },  super(arguments...)


# UTILITY FUNCTIONS
exports.tidyScope     = tidyScope     = ( scope )               ->
  return unless scope?
  scope = scope.replace(/[.]+/g, '.') # multiple consequitive dots replace by a unique occurence
  scope = scope.replace(/^[.]/g, '' ) # leading dot suppressed
  scope = scope.replace(/[.]$/g, '' ) # trailing dot suppressed
exports.buildRegexen  = buildRegexen  = (o, props)              ->
  # build regexes from a bunch of properties (whose names are given by the srcProps array) of a given objet (src)
  return unless o?
  re = {}
  for k in props
    v = o?[k];
    re[k]  ?= o?.re?[k] ? o?['re_' + k] ? if v? then _.re_build(v) else ''
    re[k]  = re[k].source if _.isRegExp(re[k])
  return re
exports.buildCaptures = buildCaptures = ( opts = {} )           ->
  {caps} = o = _.defaults {}, opts, { caps: [] }
  return caps unless _.isArray(caps)

  # caps  = caps.map (item) -> if _.isString(item) then { name: item } else item
  captures = {}
  for i in [0 ... caps.length ]
    v = caps[i]
    switch
      when _.isString(v) then v =  { name: v }

    idx = v?.index ? v?.idx ? v?.i ? i
    # !@NOTE that the left-hand-side is an object with numeric keys (but not an ARRAY). That's why we need the loop.
    captures[ idx ] =  v unless _.isUndefined(v)
  return captures
exports.fixPatterns   = fixPatterns   = ( patterns = [], m = {}, args... ) ->
    return unless patterns
    res = []
    for p in patterns
      pattern = fixPattern p, m, args...
      continue if _.isUndefined(pattern)
      res.push pattern
    return res
exports.fixPattern    = fixPattern    = ( pattern, m, args... ) ->
    pattern = _.resolve(pattern, m, args...) unless _.isUndefined(pattern)
    # return pattern # @@DEBUG. -@FIXME. Just remove this line when things settle.
    switch
      when _.isUndefined(pattern) then return pattern
      when _.isObject(pattern)
        return pattern unless pattern.include?
        ref = String(pattern.include)
      else
        ref = String(pattern)
        pattern = new Object()

    ruleName = ref.replace(/^[#]/, '')
    return undefined if (m?.disable?[ruleName] ? false ) or (m?.disable?[ '#' + ruleName] ? false )

    pattern.include = '#' + "#{ruleName}"
    return  pattern
exports.genericGrammarRemarks = genericGrammarRemarks = ()      ->
    [
      "# ----------------------------------------------------------------------"
      "# ATTENTION!  If you are reading this from :"
      "#"
      "#    (a) A CoffeeScript source"
      "#"
      "#     => OK, you are in the RIGHT place. Just SKIP this comment."
      "#"
      "#    (b) any other place, such as: "
      "#          - an atom grammar definition file in CSON"
      "#          - or a dump of some sorts (that spewed oout the generated atom grammar object)"
      "#"
      "#     => STOP! You are in te WRONG place (which is an autogenerated ugly file)."
      "#        Just read the rest this comment and then go find the original"
      "#        CoffeScript source mentioned above."
      "#        It is much more pleasent to look at, I assure you. :-)"
      "#"
      "# PS: I hope you were not really thinking I was clever and crazy enough to write"
      "# that damned regex in one huge line without free-spacing :)"
      "# ----------------------------------------------------------------------"
    ]
