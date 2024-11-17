local switch_float = function()
    local settings_path = os.getenv("HOME") .. "/.config/awesome/settings.lua"
    local file = io.open(settings_path, "r")
    local content = file:read("*all")
    file:close()

    if content:match('settings.bar_floating%s*=%s*true') then
        content = content:gsub('settings.bar_floating%s*=%s*true',
            'settings.bar_floating = false')
    elseif content:match('settings.bar_floating%s*=%s*false') then
        content = content:gsub('settings.bar_floating%s*=%s*false',
            'settings.bar_floating = true')
    end

    file = io.open(settings_path, "w")
    file:write(content)
    file:close()
end

local tray = wibox.widget {
    widget = wibox.container.background,
    maker.margins(wibox.widget.systray(), dpi(10), dpi(10), dpi(5), dpi(5)),
    visible = false
}

local systraytext = wibox.widget {
    widget = wibox.container.background,
    fg = colors.fg,
    {
        text = "",
        id = "txt",
        font = settings.font .. " Regular 18",
        align = "center",
        widget = wibox.widget.textbox
    }
}

local systraybutton = wibox.widget {
    systraytext,
    buttons = {
        awful.button({}, 1,
            function() awesome.emit_signal("widget::systray") end)
    },
    margins = dpi(0),
    widget = wibox.container.margin
}

local floating_bar = maker.image(icons.float_bar, colors.transparent, 5, 0, "float")
floating_bar:buttons({
    awful.button({}, 1, function()
        switch_float()
        awesome.emit_signal("float::bar")
    end)
})

local box_a = { floating_bar }

local systray = wibox.widget {
    widget = wibox.container.background,
    bg = colors.transparent,
    shape = maker.radius(6),
    {
        layout = wibox.layout.fixed.horizontal,
        maker.margins(systraybutton, dpi(5), dpi(5), dpi(0), dpi(0)),
        tray,
        maker.horizontal_padding_box(dpi(10), dpi(10), dpi(0), dpi(0), box_a)
    }
}

awesome.connect_signal("widget::systray", function()
    if not tray.visible then
        tray.visible = true
        systraytext:get_children_by_id("txt")[1].text = ""
    else
        tray.visible = false
        systraytext:get_children_by_id("txt")[1].text = ""
    end
end)

awesome.connect_signal("theme::icons", function(icons)
    floating_bar:get_children_by_id("float")[1]:set_image(icons.float_bar)
end)

awesome.connect_signal("change::theme", function()
    systray:set_bg(colors.transparent)
    systraytext:set_fg(colors.fg)
end)

return systray
