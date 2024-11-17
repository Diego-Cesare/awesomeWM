local notifs_text = wibox.widget({
    markup = maker.text(colors.fg, "Bold 16", "Notifications"),
    halign = "center",
    id = "text",
    widget = wibox.widget.textbox,
})

local notifs_clear = wibox.widget({
    align = "center",
    widget = wibox.widget.imagebox,
    image = icons.clear,
    forced_width = dpi(25),
    forced_height = dpi(25),
})

local notifs_empty = wibox.widget({
    widget = wibox.container.background,
    layout = wibox.layout.align.vertical,
    expand = "none",
    forced_height = dpi(560),
    {
        widget = wibox.container.background,
        nil,
    },
    {
        widget = wibox.widget.textbox,
        align = "center",
        id = "empity",
        markup = maker.text(colors.fg, "Regular 16", "Sem notificações"),
    },
    {
        widget = wibox.container.background,
        nil,
    }
})

local notifs_container = wibox.widget({
    spacing = 10,
    spacing_widget = {
        {
            widget = wibox.container.background,
        },
        top = 2,
        bottom = 2,
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    },
    forced_width = 240,
    layout = wibox.layout.fixed.vertical,
})

local remove_notifs_empty = true

notif_center_reset_notifs_container = function()
    notifs_container:reset()
    notifs_container:add(notifs_empty)
    remove_notifs_empty = true
end

notif_center_remove_notif = function(box)
    notifs_container:remove_widgets(box, true)
    if #notifs_container.children == 0 then
        notifs_container:add(notifs_empty)
        remove_notifs_empty = true
    end
end

notifs_clear:buttons(gears.table.join(awful.button({}, 1, function()
    notif_center_reset_notifs_container()
end)))

local create_notif = function(icon, n, width)
    local time = os.date("%H:%M:%S")
    local box = wibox.widget({
        {
            {
                {
                    {
                        image = icon,
                        resize = true,
                        clip_shape = maker.radius(2),
                        halign = "center",
                        valign = "center",
                        widget = wibox.widget.imagebox,
                    },
                    strategy = "exact",
                    height = 70,
                    width = 70,
                    widget = wibox.container.constraint,
                },
                {
                    {
                        nil,
                        {
                            {
                                {
                                    step_function = wibox.container.scroll.step_functions
                                        .waiting_nonlinear_back_and_forth,
                                    speed = 50,
                                    {
                                        markup = maker.text(colors.fg, "Bold 12", n.title),
                                        id = "title",
                                        align = "left",
                                        widget = wibox.widget.textbox,
                                    },
                                    forced_width = 160,
                                    widget = wibox.container.scroll.horizontal,
                                },
                                nil,
                                {
                                    markup = maker.text(colors.orange, "Bold 12", time),
                                    align = "right",
                                    valign = "top",
                                    widget = wibox.widget.textbox,
                                },
                                expand = "none",
                                layout = wibox.layout.align.horizontal,
                            },
                            {
                                markup = maker.text(colors.fg, "Bold 8", n.message),
                                align = "left",
                                id = "message",
                                forced_width = 165,
                                widget = wibox.widget.textbox,
                            },
                            spacing = 20,
                            layout = wibox.layout.fixed.vertical,
                        },
                        expand = "none",
                        layout = wibox.layout.align.vertical,
                    },
                    left = 10,
                    widget = wibox.container.margin,
                },
                layout = wibox.layout.align.horizontal,
            },
            margins = 15,
            widget = wibox.container.margin,
        },
        forced_height = 150,
        widget = wibox.container.background,
        bg = colors.alt_bg,
        id = "box",
        border_width = dpi(1.5),
        border_color = colors.alt_bg,
        shape = maker.radius(6),
    })

    box:buttons(gears.table.join(awful.button({}, 1, function()
        notif_center_remove_notif(box)
    end)))

    awesome.connect_signal("theme::colors", function(colors)
        box:get_children_by_id("box")[1]:set_bg(colors.alt_bg)
        box:get_children_by_id("box")[1]:set_border_color(colors.alt_bg)
        box:get_children_by_id("title")[1]:set_markup(maker.text(colors.fg, "Bold 12", n.title))
        box:get_children_by_id("message")[1]:set_markup(maker.text(colors.fg, "Bold 8", n.message))
    end)

    return box
end
notifs_container:buttons(gears.table.join(
    awful.button({}, 4, nil, function()
        if #notifs_container.children == 1 then
            return
        end
        notifs_container:insert(1, notifs_container.children[#notifs_container.children])
        notifs_container:remove(#notifs_container.children)
    end),

    awful.button({}, 5, nil, function()
        if #notifs_container.children == 1 then
            return
        end
        notifs_container:insert(#notifs_container.children + 1, notifs_container.children[1])
        notifs_container:remove(1)
    end)
))

notifs_container:add(notifs_empty)

naughty.connect_signal("request::display", function(n)
    if #notifs_container.children == 1 and remove_notifs_empty then
        notifs_container:reset()
        remove_notifs_empty = false
    end

    local appicon = n.icon or n.app_icon
    if not appicon then
        appicon = icons.notify
    end

    notifs_container:insert(1, create_notif(appicon, n, width))
end)

local notifs = wibox.widget({
    {
        {
            nil,
            notifs_text,
            notifs_clear,
            expand = "none",
            layout = wibox.layout.align.horizontal,
        },
        left = 5,
        right = 5,
        top = 10,
        layout = wibox.container.margin,
    },
    notifs_container,
    spacing = 20,
    layout = wibox.layout.fixed.vertical,
})

local function notify_placement(c)
    if settings.bar_position == "top" then
        return awful.placement.top_right(c, { honor_workarea = true, margins = 20 })
    else
        return awful.placement.bottom_right(c, { honor_workarea = true, margins = 20 })
    end
end

local notify_box = awful.popup({
    widget = {
        widget = wibox.container.margin,
        margins = 20,
        forced_width = 500,
        forced_height = 850,
        {
            layout = wibox.layout.fixed.vertical,
            notifs,
        },
    },
    ontop = true,
    visible = false,
    bg = colors.bg,
    type = "dock",
    shape = maker.radius(10),
    placement = function(c)
        notify_placement(c)
        --awful.placement.top_right(c, { honor_workarea = true, margins = 20 })
    end
})

awesome.connect_signal("theme::colors", function(colors)
    notify_box:set_bg(colors.bg)
    notifs_empty:get_children_by_id("empity")[1]:set_markup(maker.text(colors.fg, "Regular 16", "Sem notificações"))
    notifs_text:get_children_by_id("text")[1]:set_markup(maker.text(colors.fg, "Bold 16", "Notifications"))
end)

awesome.connect_signal("theme::icons", function(icons)
    notifs_clear.image = icons.clear
end)

return notify_box
