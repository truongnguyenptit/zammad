class App.DashboardActivityStream extends App.CollectionController
  model: false
  template: 'dashboard/activity_stream_item'
  uniqKey: 'id'
  observe:
    updated_at: true
  prepareForObjectListItemSupport: true
  items: []
  insertPosition: 'before'

  constructor: ->
    super
    @fetch()

    # bind to rebuild view event
    @bind('activity_stream_rebuild', @load)

  fetch: =>

    # use cache of first page
    cache = App.SessionStorage.get('activity_stream')
    if cache
      @load(cache)

    # init fetch via ajax, all other updates on time via websockets
    else
      @ajax(
        id:    'dashoard_activity_stream'
        type:  'GET'
        url:   "#{@apiPath}/activity_stream"
        data:
          limit: @limit || 8
        processData: true
        success: (data) =>
          @load(data)
      )

  load: (data) =>
    App.SessionStorage.set('activity_stream', data)
    @items = data.activity_stream
    App.Collection.loadAssets(data.assets)
    @collectionSync(@items)

  itemGet: (key) =>
    for item in @items
      return item if key is item.id

  itemDestroy: (key) ->
    # nothing

  itemsAll: =>
    @items

  onRenderEnd: =>
    return if _.isEmpty(@items)

    # remove description of activity stream
    @el.removeClass('activity-description').addClass('activity-entries')

  onRenderItemEnd: (item, el) ->
    new App.WidgetAvatar(
      el:        el.find('.js-avatar')
      object_id: item.created_by_id
      size:      40
    )
