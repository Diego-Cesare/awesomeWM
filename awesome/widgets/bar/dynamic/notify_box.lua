local notification_count = 0

local disable = maker.image(icons.bell_active, colors.transparent, 6, 0,
    "icon_notify")
disable:buttons({
    awful.button({}, 1, function()
        not_disturbed:toggle_silent()
        awesome.emit_signal("disable::notify")
    end)
})

maker.hover(disable, colors.fg .. "10", colors.transparent, 0)

awesome.connect_signal("disable::notify", function()
    if not not_disturbed.silent then
        disable:get_children_by_id("icon_notify")[1].image = icons.bell_active
    else
        disable:get_children_by_id("icon_notify")[1].image = icons.bell_inactive
    end
end)

local mini_icon = maker.image(icons.user, colors.transparent, 0, 50, "icon_user")

local notification_count_widget = wibox.widget {
    widget = wibox.widget.textbox,
    markup = maker.text(colors.green, "Bold 10", "0")
}

local notification_app_name_widget = wibox.widget {
    widget = wibox.widget.textbox,
    markup = maker.text(colors.fg, "Bold 10", " Notificações")
}

local notification_app_msg_widget = wibox.widget {
    widget = wibox.widget.textbox,
    visible = dpi(250),
    markup = maker.text(colors.green, "Regular 9", "Remetente")
}

local function update_notification_widgets(n)
    mini_icon:get_children_by_id("icon_user")[1].image = n.icon or icons.user
    notification_count = notification_count + 1
    notification_count_widget.markup = maker.text(colors.green, "Bold 10",
        tostring(notification_count) ..
        " ")
    notification_app_msg_widget.markup =
        maker.text(colors.green, "Bold 10", n.message)
    notification_app_name_widget.markup =
        maker.text(colors.fg, "Bold 10", n.app_name or "Desconhecido")
end

naughty.connect_signal("request::display", function(n)
    awful.spawn.with_shell('canberra-gtk-play -i message')
    update_notification_widgets(n)
end)

local notify_description = wibox.widget({
    layout = wibox.layout.flex.vertical,
    {
        layout = wibox.layout.fixed.horizontal,
        notification_count_widget,
        notification_app_name_widget
    },
    nil,
    notification_app_msg_widget
})

local function reset_notification_widgets()
    mini_icon:get_children_by_id("icon_user")[1].image = icons.user
    notification_count = 0
    notification_count_widget.markup = maker.text(colors.green, "Bold 10", "0")
    notification_app_msg_widget.markup = maker.text(colors.green, "Regular 9", "Remetente")
    notification_app_name_widget.markup = maker.text(colors.fg, "Bold 10", " Notificações")
end

mini_icon:buttons(gears.table.join(awful.button({}, 1, function()
    if not notify_center.visible then
        notify_center.visible = true
        anime.move_x(notify_center, 1410, 40, "right")
        reset_notification_widgets()
    else
        anime.move_x_out(notify_center, 1410, 30, "left")
        gears.timer.start_new(0.9, function()
            notify_center.visible = false
            return false
        end)
    end
    reset_notification_widgets()
end)))

local left_widgets = { mini_icon, maker.margins(notify_description, 10, 0, 0, 0) }
local right_widgets = { disable }

local main_notify = wibox.widget({
    layout = wibox.layout.align.horizontal,
    forced_width = dpi(330),
    visible = false,
    expand = "none",
    { widget = maker.horizontal_padding_box(0, 0, 0, 0, left_widgets) },
    nil,
    {
        widget = wibox.container.place,
        align = "center",
        maker.horizontal_padding_box(0, 0, 0, 0, right_widgets)
    }
})

awesome.connect_signal("theme::colors", function(colors)
    notification_app_name_widget:set_markup(
        maker.text(colors.fg, "Bold 10", " Notificações"))
end)

awesome.connect_signal("theme::icons", function(icons)
    if not not_disturbed.silent then
        disable:get_children_by_id("icon_notify")[1].image = icons.bell_active
    else
        disable:get_children_by_id("icon_notify")[1].image = icons.bell_inactive
    end
end)

return main_notify
