{Serenade} = require './serenade'
{AjaxCollection} = require './ajax_collection'
{Events} = require './events'
{extend} = require './helpers'

class Serenade.Model
  extend(@prototype, Events)
  extend(@prototype, Serenade.Properties)

  @property: -> @prototype.property(arguments...)
  @collection: -> @prototype.collection(arguments...)

  @_getFromCache: (id) ->
    @_identityMap ||= {}
    @_identityMap[id] if @_identityMap.hasOwnProperty(id)

  @_storeInCache: (id, object) ->
    @_identityMap ||= {}
    @_identityMap[id] = object

  @find: (id) ->
    if document = @_getFromCache(id)
      document.refresh() if @_storeOptions?.refresh in ['always']
      document.refresh() if @_storeOptions?.refresh in ['stale'] and document.isStale()
    else
      document = new this(id: id)
      document.refresh() if @_storeOptions?.refresh in ['always', 'stale', 'new']
    document

  @all: ->
    if @_all
      @_all.refresh() if @_storeOptions?.refresh in ['always']
      @_all.refresh() if @_storeOptions?.refresh in ['stale'] and @_all.isStale()
    else
      @_all = new AjaxCollection(this, @_storeOptions.url)
      @_all.refresh() if @_storeOptions?.refresh in ['always', 'stale', 'new']
    @_all

  @store: (options) ->
    @_storeOptions = options

  constructor: (attributes) ->
    if attributes?.id
      fromCache = @constructor._getFromCache(attributes.id)
      if fromCache
        fromCache.set(attributes)
        return fromCache
      else
        @constructor._storeInCache(attributes.id, this)
    @set(attributes)

  refresh: ->
  save: ->

  isStale: ->
    @get('expires') < new Date()
