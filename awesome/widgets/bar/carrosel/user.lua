local clock_box = require("widgets.bar.carrosel.clock_box")
local usericon = maker.image(icons.user, colors.transparent, 0, 50, nil)

local wm_name = wibox.widget({
    widget = wibox.widget.textbox,
    valign = "center",
    markup = maker.text(colors.fg, "Regular 12", settings.wm_name)
})

local user_name = wibox.widget({
    widget = wibox.widget.textbox,
    valign = "center",
    markup = maker.text(colors.fg .. "50", "Regular 9", "@" .. settings.name)
})

local main_user_name = wibox.widget({
    layout = wibox.layout.flex.vertical,
    wm_name,
    user_name
})

local left_widgets = { usericon, maker.margins(main_user_name, 10, 10, 0, 0) }

local main_user = wibox.widget({
    layout = wibox.layout.align.horizontal,
    forced_width = dpi(380),
    visible = true,
    expand = "none",
    { widget = maker.horizontal_padding_box(0, 0, 0, 0, left_widgets) },
    nil,
    clock_box
})

awesome.connect_signal("theme::colors", function(colors)
    wm_name:set_markup(maker.text(colors.fg, "Regular 12", settings.wm_name))
    user_name:set_markup(maker.text(colors.fg .. "50", "Regular 9",
        "@" .. settings.name))
end)
return main_user
