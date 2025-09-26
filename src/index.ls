module.exports =
  pkg:
    name: 'bar-list', version: '0.0.1'
    extend: {name: "@makechart/base"}
    dependencies: [
      {url: "/assets/lib/ldview/main/index.min.js"}
    ]
  init: ({root, context, t, pubsub}) ->
    pubsub.fire \init, {
      mod: mod({root, context, t})
      prepare-svg: false
      layout: false
      data-accessor: -> it._data._raw
    }

mod = ({root, context, t}) ->
  {chart,d3,debounce} = context
  sample: ->
    raw: [0 to 10].map -> {name: it, value: (Math.random! * 100).toFixed(2)}
    binding:
      size: {key: "value"}
      name: {key: "name"}
  config: {}
  dimension:
    size: {type: \R, name: "size"}
    name: {type: \NO, name: "name"}
  init: ->
    @picked = {}
    @tint = tint = new chart.utils.tint!
    @scale = scale = {}
    @extent = {}
    get-list = ~>
      return [[k,v] for k,v of @picked].filter(-> !it.1).map -> it.0

    @view = new ldview do
      root: root
      init-render: false
      action: click:
        select: ({views, node}) ~>
          name = node.getAttribute \data-name
          if name == \none => @parsed.map ~> @picked[it.name] = false
          else @picked = {}
          @filter {name: {type: 'exclude', value: get-list!}}, true
          views.0.render \data

      handler:
        data:
          list: ~> @parsed
          key: -> it._idx
          action: click: ({views, node, data}) ~>
            @picked[data.name] = if @picked[data.name]? => !@picked[data.name] else false
            views.0.render \data, data._idx
            @filter {name: {type: 'exclude', value: get-list!}}, true

          handler: ({node, data}) ~>
            nn = node.querySelector('[ld=name]')
            nb = node.querySelector('[ld=bar]')
            unit = (@binding.{}size.unit or '')
            nn.textContent = "#{data.name} / #{data.size}#{unit}"
            nb.style <<< width: "#{(@scale.x data.size)}%", background: @tint.get 'size'
            node.style.opacity = if @picked[data.name] == false => 0.3 else 1

  filter: (filters, internal = false)->
  parse: ->
    @parsed = @data.map -> it
    names = @parsed.map -> it.name
    @parsed ++= [k for k of @picked]
      .filter -> !(it in names)
      .map ~> {name: it, size: 0}
    @parsed.sort (a,b) ~>
      pb = !(@picked[b.name]?) or @picked[b.name]
      pa = !(@picked[a.name]?) or @picked[a.name]
      if pb and !pa => return 1 else if !pb and pa => return -1
      if b.size - a.size => return that
      return 0
    @parsed.map (d,i) -> d._idx = i

  resize: ->
    @extent = d3.extent @parsed.map -> it.size
    @scale.x = d3.scaleLinear!domain [0, @extent.1] .range [0, 100]
  render: -> @view.render!
