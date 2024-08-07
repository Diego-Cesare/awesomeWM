local notify_center = require("widgets.control_center.notifications_center")
local calendar = require("widgets.control_center.calendar")

local mini_icon = wibox.widget {
	widget = wibox.widget.imagebox,
	image = icons.user,
	forced_width = dpi(40),
	forced_height = dpi(40),
	valign = "center",
	halign = "center",
	horizontal_fit_policy = "cover",
	vertical_fit_policy = "cover",
	resize = true
}

local notification_count = 0

local notification_count_widget = wibox.widget {
	widget = wibox.widget.textbox,
	markup = maker.text(colors.fg, "Bold 12", "0")
}

local notification_app_name_widget = wibox.widget {
	widget = wibox.widget.textbox,
	markup = maker.text(colors.fg, "Bold 10", "Sem notificações")
}

local notification_app_msg_widget = wibox.widget {
	widget = wibox.widget.textbox,
	markup = maker.text(colors.fg, "Bold 10", "Remetente")
}

local function show_notification_icon(n)
	if n.icon then
		mini_icon.image = n.icon
	else
		mini_icon.image = icons.user
	end
	notification_count = notification_count + 1
	local num_notify = tostring(notification_count)
	notification_count_widget.markup = maker.text(colors.fg, "Bold 12", num_notify)
	notification_app_msg_widget.markup = maker.text(colors.fg, "Bold 10", n.message)

	if n.app_name then
		notification_app_name_widget.markup = maker.text(colors.fg, "Bold 10", n.app_name)
	else
		notification_app_name_widget.markup = maker.text(colors.fg, "Bold 12",
			"Desconhecido")
	end
end

naughty.connect_signal("request::display", function(n)
	show_notification_icon(n)
end)

local open_notify = wibox.widget({
	widget = wibox.container.background,
	bg = colors.alt_bg,
	forced_height = dpi(60),
	shape = maker.radius(50),
	{
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			widget = wibox.container.place,
			valign = "center",
			{
				widget = wibox.container.margin,
				margins = { left = dpi(20) },
				{
					widget = wibox.container.background,
					shape = maker.radius(50),
					border_width = dpi(2),
					border_color = colors.green,
					mini_icon,
				},
			},
		},
		{
			widget = wibox.container.place,
			valign = "center",
			halign = "center",
			{
				layout = wibox.layout.flex.vertical,
				notification_app_name_widget,
				{
					layout = wibox.container.scroll.horizontal,
					max_size = 150,
					step_function = wibox.container.scroll.step_functions.nonlinear_back_and_forth,
					speed = 50,
					fps = 60,
					notification_app_msg_widget,
				},
			},
		},
		maker.margins(notification_count_widget, 0, 20, 0, 0),
	},
})

open_notify:buttons(gears.table.join(
	awful.button({}, 1, nil, function()
		notify_center.visible = not notify_center.visible
		calendar.visible = not calendar.visible
	end)
))

awesome.connect_signal("change::theme", function()
	open_notify:set_bg(colors.alt_bg)
	notification_app_name_widget:set_markup(maker.text(colors.fg, "Bold 10", "Sem notificações"))
	notification_app_msg_widget:set_markup(maker.text(colors.fg, "Bold 10", "Remetente"))
	notification_count_widget:set_markup(maker.text(colors.fg, "Bold 12", "0"))
end)

return open_notify
