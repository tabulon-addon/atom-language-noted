_ = require('./utils')

exports.Resolvable  = class Resolvable
  constructor:   ()                 ->
  ingredients:   ()                 ->
    # By default, we exclude properties that are functions (to avoid accidental side-effects), but they too can be included.
    res = _.allKeys(this)
    _.compact res.map (item) -> if _.isFunction(item) then undefined else item
  dependencies:  ()                 -> {}
  resolveOpts:   ()                 -> _.defaults {}, arguments...
  resolvers:     ( key )            -> [key]
  resolver:      ( key )            ->
    return unless key?
    return unless resolvers = @resolvers(key)
    resolvers = [resolvers] unless _.isArray(resolvers)
    resolvers = _.compact resolvers
    for r in resolvers
      return r if _.isFunction(r) or _.isObject(r)
      res = this?[r]
      return res if res?
    return
  resolve:       ()                 ->
    #_.dump _msg: "Resolving BEGINS : ...", data: {opts, this: this }
    #name_lc       = String( _.resolve.call(this, @name, arguments...)).toLowerCase()
    #_.dump _msg: "Resolving BEGINS for '#{name_lc}' ..."

    o    = _.extend {}, arguments..., @resolveOpts(arguments...)
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

        item = @resolver(i)   # @?[i + '_x' ] ? @?[i]
        continue unless item?
        v = _.resolve.call(that, item, o)
        res[i]  = v unless _.isUndefined(v)

        done[i] = true


    name_lc       = String( _.resolve.call(this, @name, arguments...)).toLowerCase()
    _.dump _msg: "Just resolved '#{name_lc}' : ", data:res  if name_lc == 'noted'

    return unless _.keys(res).length > 0
    return res

  writeOut:       ( o = {} )        ->
    data = @resolve(arguments...)
    _.writeOut _.defaults( {}, {data}, arguments...)

# # generates patterns for lexicons/wordlists like those for [language-todo] and its derivatives
exports.GrammaticFragment  = class GrammaticFragment extends Resolvable
  defs:           ()                 -> {}
  vars:           ()                 -> {}
  isGrammatical:  ()                 -> true
  ingredients:    ()                 -> ['comment', 'name', 'patterns']
  dependencies:   ()                 -> {}
  resolveOpts:    ()                 -> @context(arguments...)
  resolvers:      ( key )            -> [ String(key) + '_x', key ] if key?
  constructor:    ( opts )           ->
    opts ?= {}
    opts  = { include: opts } unless _.isObject(opts)

    super()

    stashies = [ 'm',     'stash',  'vars'  ]
    scopies  = [ 'scopes', 'scope', 's'     ]
    specials =  _.union(stashies, scopies, ['defs'] )

    #_.dump _msg: 'Constructing lexicon.', data: {opts}
    defs = _.compact _.resolve.call(this, [@?.defs, opts?.defs])
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

  isDisabled:     ( opts = {} )      ->
    return  @disabled unless _.isUndefined(@?.disabled)
    return !@enabled  unless _.isUndefined(@?.enabled)

    {ref}    = opts
    m        = @mstash(opts) ? {}
    for n in [ref, @include, @name ]
      continue if  _.isUndefined(n)
      name      = String(_.resolve.call(this, n, opts))
      continue if  _.isUndefined(name)
      nlc       = name.toLowerCase().replace(/^[#]/, '')
      #console.warn "..... checking isDisabled(). nlc: #{nlc}, comment: #{@comment}"

      disabled   = @?.disable?[nlc] ?  m?.disable?[nlc]
      enabled    = @?.enable?[nlc]  ?  m?.enable?[nlc]

      #console.warn "..... checking isDisabled(). nlc: #{nlc}, enabled:#{enabled}, disabled: #{disabled}, comment: #{@comment}"

      return  disabled unless _.isUndefined(disabled)
      return !enabled  unless _.isUndefined(enabled)

    return false

  scopeDefs:      ()                 ->
    {
      prefix: ''
      suffix: ''
      meta: 'meta'
      punc: 'punctuation'
      punk: 'punctuation.definition'
      poke: 'markup.other.poke'
      soft: 'markup.other.soft'
    }
  scopes:         ( opts = {} )      ->
    o = _.defaults {}, arguments..., @mstash?(arguments...), { scopes: {} }
    scopes = _.defaults {}, opts?.scopes

    #_.dump _msg: 'Scopes called upon ', data: {scopes, this: this}

    scopes = _.extend {}, @scopeDefs(), scopes
    for item in ['comment', 'constant', 'entity', 'invalid', 'keyword', 'markup', 'meta', 'punctuation', 'storage', 'string', 'support', 'variable']
      scopes[item] ?= item
    return scopes

  mstash:         ( opts = {} )      ->
    o = opts;
    zoo = _.defaults {}, o?.m, o?.stash, this?.m, this?.stash, @?.vars?()
    return zoo
  context:        ()                 ->
    r = { }
    r.m = r.vars  = r.stash  = @mstash(arguments...)
    r.s = r.scope = r.scopes = @scopes(arguments...)
    return r

  recipe:         ( opts = {} )      -> this # %#DEPRECATED. For backwards compatibity.
  name_x:         ()                 -> tidyScope _.resolve.call(this, @?.name, arguments...)
  patterns_x:     ( args... )        ->
    # name_lc       = String( _.resolve.call(this, @name, arguments...)).toLowerCase()
    # _.dump _msg: "patterns_x() BEGINS for '#{name_lc}' ..."

    return if @isDisabled(args...)
    p = []
    p = _.compact p.concat _.resolve.call(this, @patterns, args...)                           if @?.patterns?
    p = _.compact p.concat _.resolve.call(this, @collate( items:@subrules, args...), args...) if @?.subrules?

    fixRules.call(this, p, args... )

  collate:        ( o = {}  )        ->
    items = o?.items ? @?.subrules ? []
    items = _.resolve.call(this, items, arguments...)
    stash = @mstash(arguments...)

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
  constructor:    () ->
    super(arguments...)
    @filename ?= arguments?.caller?.__filename

  rules:          () -> {} # you may wish to override this!
  lexicons:       () -> {}
  lexiconClass:   () -> Lexicon
  repository_x:   () ->
    return if @isDisabled(arguments...)
    repos = {
      lexicons: { ruleClass: @lexiconClass() }
    }
    repo = {}
    for k in _.union( ['repository', 'rules'], _.keys(repos) )
      console.warn "Repo key: #{k}"
      continue if _.isUndefined v = @?[k]
      r = _.resolve.call this, v, arguments...
      r = fixRules r,  _.extend( {}, arguments..., repos?[k] )
      repo = _.defaults repo, r

    return repo


exports.GrammaticCapture  = class GrammaticCapture extends GrammaticFragment
  constructor:    (opts)              ->
    opts ?= {}
    opts  = { name: opts } unless _.isObject(opts)
    super(opts)
  ingredients:    ()                  -> _.union      super(arguments...), ['comment', 'name', 'patterns']

exports.GrammaticRule     = class GrammaticRule extends GrammaticFragment
  constructor:    ()                  -> super(arguments...)
  ingredients:    ()                  -> _.union      super(arguments...), ['comment', 'name', 'patterns', 'include', 'match', 'captures', 'begin', 'beginCaptures', 'end', 'endCaptures', 'contentName']
  dependencies:   ()                  -> _.extend {}, super(arguments...), { captures: 'match', beginCaptures:'begin', endCaptures: 'end', contentName: 'begin' }

  match:          ()                  ->
  captures:       ()                  ->
  captures_x:     ()                  -> @buildCaptures(arguments...)

  # utilities
  buildRegexen:  ( props=[], args...  )   -> buildRegexen(this, props, args...) # call global utility routine
  buildCaptures: ( opts = {} )            ->
    caps = _.resolve.call(this, @?.captures, opts);
    buildCaptures _.defaults {caps}, opts         # call global helper routine

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
exports.tidyScope     = tidyScope     = ( scope )                   ->
  return unless scope?
  scope = String(scope)
  scope = scope.replace(/[.]+/g, '.') # multiple consequitive dots are replaced by a unique occurence
  scope = scope.replace(/^[.]/g, '' ) # leading  dot is suppressed
  scope = scope.replace(/[.]$/g, '' ) # trailing dot is suppressed
exports.buildRegexen  = buildRegexen  = (o, props)                  ->
  # build regexes from a bunch of properties (whose names are given by the srcProps array) of a given objet (src)
  return unless o?
  re = {}
  for k in props
    v = o?[k];
    re[k]  ?= o?.re?[k] ? o?['re_' + k] ? if v? then _.re_build(v) else ''
    re[k]  = re[k].source if _.isRegExp(re[k])
  return re
exports.buildCaptures = buildCaptures = ( opts = {} )               ->
  {caps} = opts
  return fixCaptures(caps, opts) unless _.isArray(caps)

  captures = {}
  for c,i in caps
    continue unless cap = fixCapture c, opts
    idx = cap?.index ? cap?.idx ? cap?.i ? i
    captures[ idx ] = cap   # !@NOTE that the left-hand-side is an object with numeric keys (but not an ARRAY). That's why we need the loop.

  return captures

exports.fixFragments  = fixFragments  = ( fragments, opts = {} )    ->
  return unless fragments?
  rules = _.resolve.call this, fragments, opts
  switch
    when not fragments?         then return
    when _.isArray(fragments)   then return _.terse _.compact(fragments).map (fragment) -> fixFragment.call(this, fragment, opts)
    when _.isObject(fragments)  then return _.mapObject fragments,           (fragment) -> fixFragment.call(this, fragment, opts)
  return fragments
exports.fixFragment   = fixFragment   = ( fragment,  opts = {} )    ->
  {klass} = _.defaults {}, opts, { klass: GrammaticFragment }
  return unless fragment?
  fragment = _.resolve.call this, fragment, opts
  return unless fragment?
  fragment = new klass(fragment) unless fragment instanceof GrammaticFragment
  return if fragment.isDisabled opts
  return  fragment

exports.fixCaptures   = fixCaptures   = ( captures,  opts = {} )    -> fixFragments.call this, captures, _.extend( {}, opts, { klass: ( opts?.captureClass ? GrammaticCapture)  } )
exports.fixCapture    = fixCapture    = ( capture,   opts = {} )    -> fixFragment.call  this, capture,  _.extend( {}, opts, { klass: ( opts?.captureClass ? GrammaticCapture)  } )

exports.fixRules      = fixRules      = ( rules,  opts = {} )       -> fixFragments.call this, rules, _.extend( {}, opts, { klass: ( opts?.ruleClass ? GrammaticRule) } )
exports.fixRule       = fixRule       = ( rule,   opts = {} )       -> fixFragment.call  this, rule,  _.extend( {}, opts, { klass: ( opts?.ruleClass ? GrammaticRule) } )

exports.genericGrammarRemarks = genericGrammarRemarks = ()          ->
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
