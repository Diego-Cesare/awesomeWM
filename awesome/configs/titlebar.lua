client.connect_signal("request::titlebars", function(c)
    local icon_size = settings.title_size * 40 / 100

    local close_button = wibox.widget({
        widget = wibox.widget.imagebox,
        image = icons.close_icon,
        valign = "center",
        halign = "center",
        resize = true,
        forced_width = dpi(icon_size),
        buttons = awful.button({}, 1, function() c:kill() end)
    })

    local maximize_button = wibox.widget({
        widget = wibox.widget.imagebox,
        image = icons.maximize,
        valign = "center",
        halign = "center",
        resize = true,
        forced_width = dpi(icon_size),
        buttons = awful.button({}, 1,
            function() c.maximized = not c.maximized end)
    })

    local minimize_button = wibox.widget({
        widget = wibox.widget.imagebox,
        image = icons.minimize,
        valign = "center",
        halign = "center",
        resize = true,
        forced_width = dpi(icon_size),
        buttons = gears.table.join(awful.button({}, 1, function()
            gears.timer.delayed_call(function() c.minimized = true end)
        end))
    })

    local buttons = {
        awful.button({}, 1, function()
            c:activate { context = "titlebar", action = "mouse_move" }
        end), awful.button({}, 3, function()
        c:activate { context = "titlebar", action = "mouse_resize" }
    end)
    }

    local actions = wibox.widget {
        widget = wibox.container.background,
        bg = colors.alt_bg,
        shape = maker.radius(6),
        forced_width = dpi(100),
        {
            widget = wibox.container.place,
            align = "center",

            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(5),
                minimize_button,
                maximize_button,
                close_button
            }
        }
    }
    local widgets_box = { maker.margins(actions, 10, 10, 10, 10) }

    local titlebuttons = wibox.widget {
        widget = wibox.container.background,
        bg = colors.bg,
        {
            layout = wibox.layout.align.horizontal,
            nil,
            { buttons = buttons, widget = wibox.container.background },
            {
                widget = wibox.container.background,
                maker.horizontal_padding_box(0, 0, 0, 0, widgets_box)
            }
        }
    }

    local titlebar = awful.titlebar(c, {
        size = dpi(settings.title_size),
        position = settings.title_position,
        bg = colors.bg
    })

    titlebar:setup { widget = maker.margins(titlebuttons, 0, 0, 0, 0) }

    awesome.connect_signal("theme::colors", function()
        titlebuttons:set_bg(colors.bg)
        actions:set_bg(colors.alt_bg)
    end)

    awesome.connect_signal("theme::icons", function(icons)
        close_button:set_image(icons.close_icon)
        maximize_button:set_image(icons.maximize)
        minimize_button:set_image(icons.minimize)
    end)
end)
