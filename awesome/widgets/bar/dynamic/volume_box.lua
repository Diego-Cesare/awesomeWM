local volume_icon = wibox.widget({
    widget = wibox.container.background,
    bg = colors.transparent,
    {
        widget = wibox.container.margin,
        margins = dpi(3),
        {
            widget = wibox.widget.imagebox,
            image = icons.volume,
            id = "volume",
            valign = "center",
            halign = "center",
            horizontal_fit_policy = "cover",
            vertical_fit_policy = "cover",
            resize = true,
        },
    },
})

local volume_slider = wibox.widget({
    widget = wibox.widget.slider,
    bar_shape = maker.radius(6),
    bar_height = dpi(8),
    bar_color = colors.fg .. "90",
    bar_active_color = colors.magenta,
    handle_width = dpi(0),
    handle_color = colors.fg,
    handle_border_width = 1,
    handle_border_color = colors.magenta,
    handle_shape = gears.shape.circle,
    minimum = 0,
    maximum = 100,
    value = 100,
})

local volume_perc = wibox.widget({
    widget = wibox.widget.textbox,
    halign = "right",
    valign = "center",
})

local level_description = wibox.widget({
    widget = wibox.widget.textbox,
    markup = maker.text(colors.fg, "Bold 10", "Nivel Max")
})


local update_volume_slider = function()
    awful.spawn.easy_async("amixer sget Master", function(stdout)
        local volume = tonumber(string.match(stdout, "(%d?%d?%d)%%"))
        volume_slider.value = volume
        volume_perc:set_markup(maker.text(colors.fg .. "90", "Bold 10", volume .. "%"))
        if volume >= 0 and volume <= 30 then
            volume_slider.bar_active_color = colors.blue
            level_description:set_markup(maker.text(colors.blue, "Bold 10", "Nivel Min"))
        elseif volume >= 30 and volume <= 60 then
            volume_slider.bar_active_color = colors.green
            level_description:set_markup(maker.text(colors.green, "Bold 10", "Nivel Med"))
        else
            volume_slider.bar_active_color = colors.magenta
            level_description:set_markup(maker.text(colors.magenta, "Bold 10", "Nivel Max"))
        end
    end)
end

gears.timer({
    timeout = 0.5,
    call_now = true,
    autostart = true,
    callback = update_volume_slider,
})

volume_slider:connect_signal("property::value", function(slider)
    local volume_level = math.floor(slider.value / 100 * 100)
    awful.spawn("amixer set Master " .. volume_level .. "%")
end)

local volume_description = wibox.widget({
    widget = wibox.widget.textbox,
    markup = maker.text(colors.fg, "Bold 10", "Volume")
})

local left_box = wibox.widget({
    layout = wibox.layout.fixed.vertical,
    forced_width = dpi(120),
    volume_description,
    volume_slider
})

local widgets_left = { volume_icon, maker.margins(left_box, 10, 0, 0, 0) }
local widgets_right = { level_description, volume_perc }

local volume_box = wibox.widget({
    layout = wibox.layout.align.horizontal,
    forced_width = dpi(330),
    visible = true,
    expand = "none",
    {
        widget = maker.horizontal_padding_box(0, 0, 0, 0, widgets_left),
    },
    nil,
    {
        widget = wibox.container.place,
        valign = "center",
        maker.vertical_padding_box(0, 0, 0, 0, widgets_right),
    }
})

awesome.connect_signal("theme::colors", function(colors)
    volume_description:set_markup(maker.text(colors.fg, "Bold 10", "Volume"))
    volume_slider.bar_color = colors.fg .. "50"
    volume_icon:set_bg(colors.transparent)
end)

awesome.connect_signal("theme::icons", function(icons)
    volume_icon:get_children_by_id("volume")[1].image = icons.volume
end)

return volume_box