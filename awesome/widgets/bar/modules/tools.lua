local switch_theme = function()
    local theme_path = os.getenv("HOME") .. "/.config/awesome/settings.lua"
    local file = io.open(theme_path, "r")
    local content = file:read("*all")
    file:close()

    if content:match('settings.theme%s*=%s*"dark"') then
        content = content:gsub('settings.theme%s*=%s*".-"',
            'settings.theme = "light"')
        os.execute("sed -i 's/dark/light/g' ~/.config/alacritty/alacritty.toml")
    elseif content:match('settings.theme%s*=%s"light"') then
        content = content:gsub('settings.theme%s*=%s*".-"',
            'settings.theme = "dark"')
        os.execute("sed -i 's/light/dark/g' ~/.config/alacritty/alacritty.toml")
    end

    file = io.open(theme_path, "w")
    file:write(content)
    file:close()
end

local function update_mode_icon()
    if settings.theme == "dark" then
        return icons.mode_dark
    else
        return icons.mode
    end
end

local menu_bnt = maker.image(icons.menu, colors.transparent, 11, 0, "menu_bnt")
local info_bnt = maker.image(icons.infos, colors.transparent, 11, 0, "info_bnt")
local mode_bnt = maker.image(update_mode_icon(), colors.transparent, 11, 0, "mode_bnt")

menu_bnt:buttons({ awful.button(nil, 1, function() launcher:toggle() end) })

info_bnt:buttons({
    awful.button(nil, 1, function()
        if not info_center.visible then
            info_center.visible = true
            anime.move_x(info_center, 10, 90, "left")
        else
            anime.move_x_out(info_center, 10, 90, "right")
            gears.timer.start_new(0.9, function()
                info_center.visible = false
                return false
            end)
        end
    end)
})

mode_bnt:buttons({
    awful.button(nil, 1, function()
        switch_theme()
        if settings.theme == "dark" then
            settings.theme = "light"
        else
            settings.theme = "dark"
        end
        gears.timer.start_new(0.5, function()
            awesome.emit_signal("change::theme")
            awesome.emit_signal("change::icons")
            return false
        end)
    end)
})

local box = { menu_bnt, info_bnt, mode_bnt }

local main = wibox.widget {
    widget = wibox.container.background,
    bg = colors.transparent,
    shape = maker.radius(6),
    { widget = maker.horizontal_padding_box(10, 20, 0, 0, box) }
}

awesome.connect_signal("change::theme",
    function() main:set_bg(colors.transparent) end)

awesome.connect_signal("theme::icons", function(icons)
    if settings.theme == "dark" then
        mode_bnt:get_children_by_id("mode_bnt")[1]:set_image(icons.mode)
    else
        mode_bnt:get_children_by_id("mode_bnt")[1]:set_image(icons.mode_dark)
    end
    menu_bnt:get_children_by_id("menu_bnt")[1]:set_image(icons.menu)
    info_bnt:get_children_by_id("info_bnt")[1]:set_image(icons.infos)
end)

return main
