local notifs_empty = wibox.widget({
    widget = wibox.container.background,
    layout = wibox.layout.align.vertical,
    expand = "none",
    forced_height = dpi(0),
    {
        widget = wibox.container.background,
        nil,
    },
    {
        widget = wibox.widget.textbox,
        align = "center",
        markup = maker.text(colors.fg, "Regular 12", "Sem notificações"),
    },
    {
        widget = wibox.container.background,
        nil,
    }
})

local notifs_container = wibox.widget({
    layout = wibox.layout.fixed.vertical,
    spacing = 5,
    forced_width = dpi(165),
})

local create_notif = function(icon, n)
    local image_nitify = wibox.widget({
        image = icon,
        resize = true,
        clip_shape = maker.radius(6),
        forced_height = dpi(40),
        halign = "center",
        valign = "center",
        widget = wibox.widget.imagebox,
    })

    local actions_template = wibox.widget({
        notification = n,
        widget_template = {},
        style = { underline_normal = false, underline_selected = true },
        widget = naughty.list.actions,
    })


    local title = wibox.widget({
        widget = wibox.widget.textbox,
        markup = maker.text(colors.fg, "Bold 12", n.title),
    })
    awesome.connect_signal("change::theme", function(c)
        title:set_markup(maker.text(colors.fg, "Bold 12", n.title))
    end)

    local msg = wibox.widget({
        markup = maker.text(colors.fg, "Bold 9", n.message),
        widget = wibox.widget.textbox,
    })
    awesome.connect_signal("change::theme", function(c)
        msg:set_markup(maker.text(colors.fg, "Bold 9", n.message))
    end)

    local scroll_title = wibox.widget({
        layout = wibox.container.scroll.horizontal,
        max_size = 160,
        step_function = wibox.container.scroll.step_functions.nonlinear_back_and_forth,
        speed = 50,
        fps = 60,
        maker.margins(title, 0, 20, 0, 0),
    })

    local scroll_msg = wibox.widget({
        layout = wibox.container.scroll.horizontal,
        max_size = 160,
        step_function = wibox.container.scroll.step_functions.nonlinear_back_and_forth,
        speed = 50,
        fps = 60,
        maker.margins(msg, 0, 20, 0, 0),
    })

    local descripition = wibox.widget({
        widget = wibox.container.place,
        halign = "left",
        valign = "center",
        {
            layout = wibox.layout.align.vertical,
            scroll_title,
            scroll_msg,
        },
        actions_template,
    })

    local box = wibox.widget({
        widget = wibox.container.background,
        forced_height = dpi(80),
        shape = maker.radius(6),
        bg = colors.bg .. "C1",
        {
            layout = wibox.layout.align.horizontal,
            expanded = "none",
            {
                widget = wibox.container.background,
                image_nitify,
            },
            {
                widget = wibox.container.background,
                maker.margins(descripition, 20, 0, 10, 10),
            },
        },

    })

    awesome.connect_signal("change::theme", function(c)
        box:set_bg(colors.bg .. "C1")
    end)

    return maker.margins(box, 10, 10, 0, 0)
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

notifs_container:insert(1, notifs_empty)

naughty.connect_signal("request::display", function(n)
    if #notifs_container.children == 1 and remove_notifs_empty then
        notifs_container:reset(notifs_container)
        remove_notifs_empty = false
    end

    local appicon = n.icon or n.app_icon
    if not appicon then
        appicon = icons.notify
    end

    notifs_container:insert(1, create_notif(appicon, n))
end)

local notifs = wibox.widget({
    widget = wibox.container.margin,
    visible = false,
    margins = { top = dpi(10), bottom = dpi(10), left = dpi(0), right = dpi(0) },
    {
        widget = wibox.container.background,
        bg = colors.alt_bg,
        id = "notifs",
        shape = maker.radius(6),
        forced_height = dpi(270),
        {
            layout = wibox.layout.fixed.vertical,
            maker.margins(notifs_container, 0, 0, 10, 10),
        },
    },
})

awesome.connect_signal("change::theme", function(c)
    notifs:get_children_by_id("notifs")[1]:set_bg(colors.alt_bg)
end)

return notifs
