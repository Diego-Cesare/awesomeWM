require("widgets.bar.dynamic.init")

local function button_action(widget, button_functions)
    widget:buttons(gears.table.join(
        awful.button({}, 3, nil, button_functions[1])))
end

local widgets_list = { notify_box, volume_box, music_box, wall }
local current_widget_index = 1

local function navigate_widgets(direction)
    widgets_list[current_widget_index].visible = false
    if direction == "next" then
        current_widget_index = current_widget_index % #widgets_list + 1
    end
    widgets_list[current_widget_index].visible = true
end

for _, widget in ipairs(widgets_list) do
    button_action(widget, { function() navigate_widgets("next") end })
end

local widgets_box = { volume_box, notify_box, music_box, wall }

local dynamic = wibox.widget({
    widget = wibox.container.background,
    forced_width = dpi(330),
    bg = colors.transparent,
    shape = maker.radius(6),
    { widget = maker.horizontal_padding_box(20, 20, 0, 0, widgets_box) }
})

naughty.connect_signal("request::display", function(n)
    if notify_box.visible then return end
    for _, widget in ipairs(widgets_box) do widget.visible = false end
    notify_box.visible = true
    gears.timer.start_new(10, function()
        notify_box.visible = false
        for _, widget in ipairs(widgets_box) do widget.visible = true end
        return false
    end)
end)

awesome.connect_signal("theme::colors",
    function(colors) dynamic:set_bg(colors.transparent) end)

return dynamic
