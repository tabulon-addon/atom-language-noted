_ = require('./thunderscore')

# Base class for all Grammatic Objects (the Grammar itself as well as Rules/Patterns, etc)
exports.GrammaticFragment  = class GrammaticFragment extends _.Bakeable
  _specialKeys: ()                -> {
    defs:   [ 'defs' ]
    vars:   [ 'vars', 'm', 'stash', '_stash']
    scopes: [ 'scopes', 'scope', 's' ]
  }

  constructor:    ( opts )           ->
    opts ?= {}
    opts  = {include: opts} unless _.isObject(opts)

    super()

    specialKeys    = @_specialKeys() ? {}
    allSpecialKeys = _.compact _.union _.values specialKeys

    o = _.extend this, _.resolve.call(this, _.extract_compact([this, opts], specialKeys?.defs))...
    o = _.extend this, _.omit(opts, allSpecialKeys)

    @_stash        =         _.defaulted _.resolve.call(this, _.extract_compact([opts, this],    specialKeys?.vars))...
    @_stash.scopes = _.terso _.defaulted _.resolve.call(this, _.extract_compact([opts, @_stash], specialKeys?.scopes))...
  bakingIngredients:  () -> @ingredients()
  bakingDependencies: () -> @dependencies()
  bakingParams:       () -> [ @context() ]
  bakers:          (key) -> if key? then [ "#{key}_x", key ] else undefined

  writeOut:       ()                 -> @bakeOut(arguments...)

  defs:           ()                 -> {}                                # Typically overridden (for adding more)
  vars:           ()                 -> {}                                # Typically overridden (for adding more)

  ingredients:    ()                 -> ['comment', 'name', 'patterns']   # Typically overridden (for adding more)
  dependencies:   ()                 -> {}                                # Typically overridden (for adding more)

  isGrammatical:  ()                 -> true
  isDisabled:     ( opts = {} )      ->
    return  @disabled unless _.isUndefined(@?.disabled)
    return !@enabled  unless _.isUndefined(@?.enabled)

    {ref}    = opts
    {m}      = @context(opts)
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

  scopeNamesCommon: ()               ->
    ['comment', 'constant', 'entity', 'invalid', 'keyword', 'markup', 'meta', 'punctuation', 'storage', 'string', 'support', 'variable']
  scopeDefs:       ()                ->
    _.defaults {
      prefix: ''
      suffix: ''
      meta: 'meta'
      punc: 'punctuation'
      punk: 'punctuation.definition'
      poke: 'markup.other.poke'
      soft: 'markup.other.soft'
    }, _.dittoMappings @scopeNamesCommon()
  scopes:          ()      ->
    {scopes} = _.defaulted  arguments..., @stash?(arguments...), {scopes: {}}
    _.defaulted  scopes, @scopeDefs()

  stash:          ( opts = {} )      -> _.defaulted _.resolve.call(this, _.extract_compact([opts, this], _.without( @_specialKeys()?.vars ? [], 'stash')))...
  context:        ()                 ->
    # Provides the current stash (vars) and scopes, under various aliases (synonyms) for ease of use.
    res = {}
    specialKeys = @_specialKeys()

    res.stash   = @stash(arguments...)
    res[key]    = res.stash  for key in ['m'] # _.without( @_specialKeys()?.vars   ? [], 'stash')

    res.scopes  = @scopes(arguments...)
    res[key]    = res.scopes for key in ['s'] # _.without( @_specialKeys()?.scopes ? [], 'scopes')

    return res

  recipe:         ( opts = {} )      -> this # %#DEPRECATED. For backwards compatibity.

  name_lc:        ()                 -> String( _.resolve.call(this, @?.name, arguments...)).toLowerCase() if @?.name?
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
    items   = o?.items ? @?.subrules ? []
    items   = _.resolve.call(this, items, arguments...)
    {stash} = @context(arguments...)

    r = []  # result
    for item in items
    #  _.dump _msg: 'collating...', data: {item}
      continue unless item?
      m = _.defaulted  item?.stash ? {}, stash ? {}
      c = if (item?.isGrammatical?() ? false) then item else new this.constructor(_.extend({}, item, {m:m}) )
      r = r.concat c if c?

    r = _.compact(r)

# Class that enables easy dynamic generation of first-mate grammars (useful for Atom language packages)
exports.Grammar = class Grammar extends GrammaticFragment
  constructor:    () ->
    super(arguments...)
    @filename ?= arguments?.caller?.__filename
  comment:        () -> genericGrammarRemarks();   # "Remarks" # @FIXME: During DEBUGGING, we just return a short string.
  ingredients:    () -> _.union super(arguments...), [
    'comment',
    'name',       'scopeName',
    'fileTypes',  'firstLineMatch'
    'injections', 'injectionSelector',
    'patterns',   'repository'
    'foldingStartMarker', 'foldingStopMarker',
    'limitLineLength',     'maxLineLength',     'maxTokensPerLine'
  ]
  rules:          () -> {}        # you may wish to override this
  lexicons:       () -> {}        # you may wish to override this
  lexiconClass:   () -> Lexicon   # you may wish to override this, to match your own Lexicon subclass
  repository_x:   () ->
    return if @isDisabled(arguments...)
    repos = {
      lexicons: {ruleClass: @lexiconClass()}
    }
    repo = {}
    for k in _.union( ['repository', 'rules'], _.keys(repos) )
      continue if _.isUndefined v = @?[k]
      r = _.resolve.call this, v, arguments...
      r = fixRules r,  _.extended repos?[k]
      repo = _.defaults repo, r

    return repo


exports.GrammaticCapture  = class GrammaticCapture extends GrammaticFragment
  constructor:    (opts)              ->
    opts ?= {}
    opts  = {name: opts} unless _.isObject(opts)
    super(opts)
  ingredients:    ()                  -> _.union    super(arguments...), ['comment', 'name', 'patterns']

exports.GrammaticRule     = class GrammaticRule extends GrammaticFragment
  constructor:    ()                  -> super(arguments...)
  ingredients:    ()                  -> _.union    super(arguments...), ['comment', 'name', 'patterns', 'include', 'match', 'captures', 'begin', 'beginCaptures', 'end', 'endCaptures', 'contentName']
  dependencies:   ()                  -> _.extended super(arguments...), {captures: 'match', beginCaptures:'begin', endCaptures: 'end', contentName: 'begin'}

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
    rex = @buildRegexen?(['anterior', 'intro', 'head', 'body', 'tail', 'conclusion', 'posterior'], arguments...)
    return unless rex?.body? and not _.isEmpty(rex?.body)

    ///
    #{rex.anterior}
    (                                                         # $1  - full term
      (#{rex.intro})                                           # $2
      (                                                       # $3  - term
        (#{rex.head})                                          # $4
        (#{rex.body})                                          # $5
        (#{rex.tail})                                          # $6
      )
        (#{rex.conclusion})                                    # $7
    )
    #{rex.posterior}
    ///
  captures:       ()       ->
    {m, s} = @context(arguments...)
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
  defs:           ()      -> _.extended super(arguments...), {rex_anterior:/(?:^|\s|\W)/, rex_head: /[@#]?/, rex_posterior:/\b/}
  scopes:         ()      ->
    _.extended super(arguments...), {
      suffix: 'text.lexicon'
      punc: 'punctuation.lexicon'
      punk: 'punctuation.definition.lexicon'
      poke: 'markup.lexicon'
    }


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
  rex = {}
  for k in props
    v = o?[k];
    rex[k]  ?= o?.rex?[k] ? o?['rex_' + k] ? if v? then _.rex_build(v) else ''
    rex[k]  = rex[k].source if _.isRegExp(rex[k])
  return rex
exports.buildCaptures = buildCaptures = ( opts = {} )               ->
  {caps} = opts
  return fixCaptures(caps, opts) unless _.isArray(caps)

  captures = {}
  for c,i in caps
    continue unless _.isDefined cap = fixCapture c, opts
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
  {klass} = _.defaulted  opts, {klass: GrammaticFragment}
  return unless fragment?
  unless fragment instanceof GrammaticFragment
    fragment = _.resolve.call this, fragment, opts
    fragment = new klass(fragment)
    #_.dump _msg: "     Just fixed fragment by creating a new instance of '#{fragment.constructor.name}' with it ", data: fragment
  return if fragment.isDisabled(opts)
  return fragment

exports.fixCaptures   = fixCaptures   = ( captures, o = {} )    -> fixFragments.call this, captures, _.extend( {}, o, {klass: ( o?.captureClass ? GrammaticCapture)} )
exports.fixCapture    = fixCapture    = ( capture,  o = {} )    -> fixFragment.call  this, capture,  _.extend( {}, o, {klass: ( o?.captureClass ? GrammaticCapture)} )
exports.fixRules      = fixRules      = ( rules,    o = {} )    -> fixFragments.call this, rules, _.extend( {}, o, {klass: ( o?.ruleClass ? GrammaticRule)} )
exports.fixRule       = fixRule       = ( rule,     o = {} )    -> fixFragment.call  this, rule,  _.extend( {}, o, {klass: ( o?.ruleClass ? GrammaticRule)} )

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
