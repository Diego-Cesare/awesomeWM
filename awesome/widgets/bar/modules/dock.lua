local function create_app_icon(app_name, app_command)
    local icon_path = maker.get_icon(app_name)
    local icon_widget = wibox.widget {
        image = icon_path,
        resize = true,
        widget = wibox.widget.imagebox
    }

    local button = wibox.widget {
        {
            icon_widget,
            margins = 2,
            widget = wibox.container.margin
        },
        shape = maker.radius(6),
        widget = wibox.container.background,
    }

    button:buttons(gears.table.join(
        awful.button({}, 1, function()
            -- Procura por uma janela do aplicativo
            local found = false
            for _, c in ipairs(client.get()) do
                if c.class and c.class:lower() == app_name:lower() then
                    if c.minimized then
                        c.minimized = false
                        c:emit_signal("request::activate", "tasklist", nil)
                    else
                        c.minimized = true
                    end
                    found = true
                    break
                end
            end

            if not found then
                awful.spawn(app_command)
            end
        end),
        awful.button({}, 3, function()
            awful.spawn(app_command)
        end)
    ))

    maker.hover(button, colors.fg .. "10", colors.transparent, 0)

    local function update_bg_color()
        awful.spawn.easy_async_with_shell(
            "pgrep -f '" .. app_name .. "'",
            function(stdout)
                if stdout and stdout ~= "" then
                    button.bg = colors.alt_bg
                else
                    button.bg = colors.transparent
                end
            end
        )
    end

    update_bg_color()

    gears.timer {
        timeout = 1,
        autostart = true,
        callback = update_bg_color
    }

    return wibox.widget {
        button,
        margins = 10,
        widget = wibox.container.margin,
    }
end

itens = {
    { name = "alacritty",        command = "alacritty" },
    { name = "code-oss",         command = "code-oss" },
    { name = "neovim",           command = "alacritty -e nvim" },
    { name = "nemo",             command = "nemo" },
    { name = "google-chrome",    command = "google-chrome-stable" },
    { name = "telegram-desktop", command = "telegram-desktop" },
    { name = "spotify",          command = "spotify" },
    { name = "discord",          command = "discord" },
    { name = "obs",              command = "obs" },
    { name = "pavucontrol",      command = "pavucontrol" },
}

local app_box = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
}

for _, app in ipairs(itens) do
    app_box:add(create_app_icon(app.name, app.command))
end

local main = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    app_box,
}

return main
