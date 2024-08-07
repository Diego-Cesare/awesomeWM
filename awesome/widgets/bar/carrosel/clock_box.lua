local hours = maker.clock(colors.fg, "Bold 11", "%H:%M")
local weeks = maker.clock(colors.orange, "Bold 11", "%A,")
local days = maker.clock(colors.fg, "Bold 10", "%d")
local months = maker.clock(colors.fg, "Bold 10", "%B")

local main_clock = wibox.widget({
  widget = wibox.container.place,
  align = "center",
  {
    widget = wibox.container.margin,
    margins = { right = dpi(0) },
    {
      layout = wibox.layout.align.vertical,
      expand = "none",
      {
        layout = wibox.layout.fixed.horizontal,
        hours,
      },
      nil,
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(5),
        weeks,
        days,
        months,
      },
    },
  }
})
awesome.connect_signal("change::theme", function()
  hours.format = maker.text(colors.fg, "Bold 11", "%H:%M")
  days.format = maker.text(colors.fg, "Bold 10", "%d")
  months.format = maker.text(colors.fg, "Bold 10", "%B")
end)
return main_clock
