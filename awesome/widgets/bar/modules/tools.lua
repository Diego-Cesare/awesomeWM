local switch_theme = function()
  local theme_path = os.getenv("HOME") .. "/.config/awesome/settings.lua"
  local file = io.open(theme_path, "r")
  local content = file:read("*all")
  file:close()

  if content:match('settings.theme%s*=%s*"dark"') then
    content = content:gsub('settings.theme%s*=%s*".-"', 'settings.theme = "light"')
    os.execute("sed -i 's/dark/light/g' ~/.config/alacritty/alacritty.toml")
  elseif content:match('settings.theme%s*=%s"light"') then
    content = content:gsub('settings.theme%s*=%s*".-"', 'settings.theme = "dark"')
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

local mode_bnt = wibox.widget({
  widget = wibox.widget.imagebox,
  valign = "center",
  halign = "center",
  resize = true,
  image = update_mode_icon(),
  border_width = dpi(2),
  buttons = awful.button(nil, 1, function()
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
  end),
})

local info_bnt = wibox.widget({
  widget = wibox.widget.imagebox,
  valign = "center",
  halign = "center",
  resize = true,
  image = icons.infos,
  border_width = dpi(2),
  buttons = awful.button(nil, 1, function()
    if not info_center.visible then
      info_center.visible = true
      anime.move_x(info_center, 10, 80, "left")
    else
      anime.move_x_out(info_center, 10, 80, "right")
      gears.timer.start_new(0.9, function()
        info_center.visible = false
        return false
      end)
    end
  end)
})

local menu_bnt = wibox.widget({
  widget = wibox.widget.imagebox,
  valign = "center",
  halign = "center",
  resize = true,
  image = icons.menu,
  border_width = dpi(2),
  buttons = awful.button(nil, 1, function()
    launcher:toggle()
    anime.move_x(launcher.popup_widget, 10, 80, "left")
  end)
})

local sep = maker.margins(maker.separtor(vertical, 1, 1, 0, colors.transparent), 20, 20, 15, 15)

local box = { menu_bnt, sep, info_bnt, sep, mode_bnt }

local main = wibox.widget {
  widget = wibox.container.background,
  bg = colors.transparent,
  shape = maker.radius(6),
  {
    widget = maker.horizontal_padding_box(20, 20, 16, 16, box)
  }
}

awesome.connect_signal("change::theme", function()
  main:set_bg(colors.transparent)
end)

awesome.connect_signal("theme::icons", function(icons)
  if settings.theme == "dark" then
    mode_bnt:set_image(icons.mode_dark)
  else
    mode_bnt:set_image(icons.mode)
  end
  info_bnt:set_image(icons.infos)
  menu_bnt:set_image(icons.menu)
end)

return main
