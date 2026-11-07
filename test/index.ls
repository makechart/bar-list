# bar-list 的 test case ( @makechart/viewer 的 mctest )
names = <[Taipei Taichung Kaohsiung Tainan Taoyuan Hsinchu Keelung Chiayi Yilan Hualien Taitung Nantou]>
# 每份資料用自己的種子, 跟產生的先後順序無關
mk = (n) ->
  rnd = mctest.random n
  raw: names.slice(0, n).map (name) -> {name, val: Math.round(rnd! * 1000) / 10}
  binding: {name: {key: \name}, size: {key: \val, unit: \%}}
click = (ctx, sel, i = 0) -> ctx.root.querySelectorAll(sel)[i].dispatchEvent new MouseEvent(\click, {bubbles: true})

mctest.suite do
  size: [400, 360]
  data:
    few: mk 4
    many: mk 12
    nan: do ->
      d = mk 5
      d.raw.1.val = \abc
      d
  cases:
    * name: "few", data: \few
    * name: "many", data: \many
    * name: "nan", data: \nan
    * name: "short", data: \many, size: [400, 160]
    # 點一條: 排除它 ( 變淡, 排到最後 )
    * name: "pick", data: \many
      steps: [(c, ctx) -> click ctx, '.data', 2]
    * name: "pick-twice", data: \many
      steps: [((c, ctx) -> click ctx, '.data', 2), ((c, ctx) -> click ctx, '.data', 0)]
    * name: "select-none", data: \many
      steps: [(c, ctx) -> click ctx, '[ld=select][data-name=none]']
    * name: "select-all", data: \many
      steps: [((c, ctx) -> click ctx, '[ld=select][data-name=none]'), ((c, ctx) -> click ctx, '[ld=select][data-name=all]')]
    * name: "update", data: \few
      steps: [(c) -> d = mk 7; c.set-raw d.raw, d.binding]
