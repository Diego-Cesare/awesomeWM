local volume_slider = wibox.widget({
	widget = wibox.widget.slider,
	bar_shape = maker.radius(6),
	bar_height = dpi(10),
	bar_color = colors.orange .. "50",
	bar_active_color = colors.orange,
	handle_width = dpi(20),
	handle_color = colors.bg,
	handle_border_width = 1,
	handle_border_color = colors.fg,
	handle_shape = gears.shape.circle,
	minimum = 0,
	maximum = 100,
	value = 100,
})

local update_volume_slider = function()
	awful.spawn.easy_async("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
		local volume = tonumber(string.match(stdout, "(%d?%d?%d)%%"))
		volume_slider.value = volume
	end)
end

gears.timer({
	timeout = 1,
	call_now = true,
	autostart = true,
	callback = update_volume_slider,
})

volume_slider:connect_signal("property::value", function(slider)
	local volume_level = math.floor(slider.value / 100 * 100)
	awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. volume_level .. "%")
end)

local volume_icon = wibox.widget({
	widget = wibox.widget.imagebox,
	image = icons.volume,
	forced_width = dpi(50),
	resize = true,
	opacity = 1,
})

local volume_box = wibox.widget({
	widget = wibox.container.background,
	bg = colors.alt_bg,
	shape = maker.radius(6),
	{
		layout = wibox.layout.align.horizontal,
		expand = "none",
		forced_width = dpi(200),
		forced_height = dpi(46),
		maker.margins(volume_icon, 10, 0, 8, 8),
		nil,
		maker.margins(volume_slider, 10, 10, 0, 0)
	}
})

awesome.connect_signal("theme::icons", function(icons)
	volume_icon:set_image(icons.volume)
end)

awesome.connect_signal("change::theme", function()
	volume_box:set_bg(colors.alt_bg)
	volume_slider:set_handle_color(colors.bg)
	volume_slider:set_handle_border_color(colors.fg)
end)

return volume_box
