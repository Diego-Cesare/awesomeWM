local menu = {}
local itens = 6

if settings.awesometheme == "dark" then
    menu_back = "/home/diego/Imagens/Abstract/wallhaven-0wm99q.jpg"
else
    menu_back = "/.config/awesome/themes/icons/menu_back_light.png"
end

local wallpaper_path_file = gears.filesystem.get_cache_dir() .. "/current_wallpaper.txt"

local function load_back()
    local file = io.open(wallpaper_path_file, "r")
    if file then
        local path = file:read("*all")
        file:close()
        return path
    end
    return nil
end

local back = wibox.widget({
    widget = wibox.widget.imagebox,
    image = load_back(),
    valign = "top",
    halign = "center",
    scaling_quality = "best",
    horizontal_fit_policy = "cover",
    --vertical_fit_policy = "pad",
    resize = true,
})

local power = maker.button(icons.power, 50, nil)
maker.hover(power, colors.yellow, nil, 0)
local reboot = maker.button(icons.reboot, 50, nil)
maker.hover(reboot, colors.yellow, nil, 0)
local exit = maker.button(icons.exit, 50, nil)
maker.hover(exit, colors.yellow, nil, 0)
power.forced_height = dpi(50)
reboot.forced_height = dpi(50)
exit.forced_height = dpi(50)


power:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        awful.spawn("systemctl poweroff")
    end)
))

reboot:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        awful.spawn("systemctl reboot")
    end)
))

exit:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        awful.spawn.with_shell("pkill -u -9 $USER")
    end)
))

local power_box = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(0),
    power,
    reboot,
    exit,
})

local usericon = wibox.widget({
    widget = wibox.container.background,
    bg = colors.alt_bg,
    border_width = 2,
    border_color = colors.magenta,
    forced_height = dpi(150),
    shape = gears.shape.circle,
    {
        widget = wibox.widget.imagebox,
        image = icons.user,
        valign = "center",
        halign = "center",
        horizontal_fit_policy = "cover",
        vertical_fit_policy = "cover",
        resize = true,
    },
})

local main_power = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(230),
    maker.margins(power_box, 20, 0, 20, 0),
})

local awesomeWM = wibox.widget.textbox()
awesomeWM.markup = maker.text(colors.fg .. "99", settings.font .. " Bold 30", "AwesomeWM")
local distro = wibox.widget.textbox()
distro.markup = maker.text(colors.fg, settings.font .. " Regular 20", settings.host)

local wm_box = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(50),
    {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(0),
        maker.margins(awesomeWM, 0, 0, 0, 7),
        distro,
    },
    maker.margins(usericon, 80, 0, 90, 0),
})

menu.main_widget = wibox.widget({
    layout = wibox.layout.stack,
    back,
    forced_height = dpi(730),
    forced_width = dpi(500),
    {
        widget = wibox.container.background,
        bg = colors.transparent
    },
    {
        layout = wibox.layout.fixed.vertical,
        {
            layout = wibox.layout.fixed.vertical,
            main_power,
        },
        {
            widget = wibox.container.background,
            maker.margins(wm_box, 20, 0, 50, 0),
        },
        {
            widget = wibox.container.margin,
            margins = { top = dpi(20), bottom = dpi(20), left = dpi(10), right = dpi(10) },
            {
                widget = wibox.container.background,
                bg = colors.fg .. "50",
                fg = colors.fg,
                border_width = dpi(2),
                border_color = colors.black,
                shape = maker.radius(10),
                forced_height = dpi(40),
                id = "prompt_icon",
                {
                    id = "prompt",
                    widget = wibox.widget.textbox
                },
            },
        },
        {
            widget = wibox.container.margin,
            margins = { top = dpi(0), bottom = dpi(20), left = dpi(10), right = dpi(20) },
            {
                widget = wibox.container.background,
                id = "menu",
                fg = colors.fg,
                {
                    id = "entries_container",
                    layout = wibox.layout.fixed.vertical,
                },
            },
        },
    },
})

menu.popup_widget = awful.popup {
    ontop = true,
    visible = false,
    type = "dock",
    widget = wibox.container.background,
    bg = colors.bg,
    shape = maker.radius(10),
}

menu.popup_widget:setup({
    widget = wibox.container.background,
    bg = colors.transparent,
    shape = maker.radius(0),
    shape_border_color = colors.bg,
    shape_border_width = 0,
    menu.main_widget
})

function menu:next()
    if self.index_entry ~= #self.filtered and #self.filtered > 1 then
        self.index_entry = self.index_entry + 1
        if self.index_entry > self.index_start + itens - 1 then
            self.index_start = self.index_start + 1
        end
    else
        self.index_entry = 1
        self.index_start = 1
    end
end

function menu:back()
    if self.index_entry ~= 1 and #self.filtered > 1 then
        self.index_entry = self.index_entry - 1
        if self.index_entry < self.index_start then
            self.index_start = self.index_start - 1
        end
    else
        self.index_entry = #self.filtered
        if #self.filtered < itens then
            self.index_start = 1
        else
            self.index_start = #self.filtered - itens + 1
        end
    end
end

function menu.get_apps()
    local apps = {}
    for _, app in ipairs(Gio.AppInfo.get_all()) do
        if app:should_show() then
            table.insert(apps, {
                appinfo = app,
                name = app:get_name(),
                executable = app:get_executable()
            })
        end
    end

    return apps
end

function menu:filter()
    local clear_input = self.input:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%[", "%%["):gsub("%]", "%%]")

    self.filtered = {}
    self.filtered_any = {}

    for _, entry in ipairs(self.unfiltered) do
        if entry.name:lower():sub(1, clear_input:len()) == clear_input:lower() or entry.executable:lower():sub(1, clear_input:len()) == clear_input:lower() then
            table.insert(self.filtered, entry)
        elseif entry.name:lower():match(clear_input:lower()) or entry.executable:lower():sub(1, clear_input:len()) == clear_input:lower() then
            table.insert(self.filtered_any, entry)
        end
    end

    table.sort(self.filtered, function(a, b) return a.name:lower() < b.name:lower() end)
    table.sort(self.filtered_any, function(a, b) return a.name:lower() < b.name:lower() end)

    for i = 1, #self.filtered_any do
        self.filtered[#self.filtered + 1] = self.filtered_any[i]
    end
end

function menu:add_entries()
    local entries_container = self.main_widget:get_children_by_id("entries_container")[1]
    entries_container:reset()

    if self.index_entry > #self.filtered and #self.filtered ~= 0 then
        self.index_start, self.index_entry = 1, 1
    elseif self.index_entry < 1 then
        self.index_entry, self.index_start = 1, 1
    end

    for i, entry in ipairs(self.filtered) do
        local entry_widget = wibox.widget {
            forced_height = dpi(40),
            buttons = {
                awful.button({}, 1, function()
                    if self.index_entry == i then
                        entry.appinfo:launch()
                        self:close()
                    else
                        self.index_entry = i
                        self:filter()
                        self:add_entries()
                    end
                end),
                awful.button({}, 4, function()
                    self:back()
                    self:filter()
                    self:add_entries()
                end),
                awful.button({}, 5, function()
                    self:next()
                    self:filter()
                    self:add_entries()
                end),
            },
            widget = wibox.container.background,
            {
                widget = wibox.container.margin,
                margins = dpi(10),
                {
                    widget = wibox.widget.textbox,
                    font = settings.font .. " Regular 12",
                    id = "text",
                    text = entry.name
                }
            }
        }

        if self.index_start <= i and i <= self.index_start + itens - 1 then
            entries_container:add(entry_widget)
        end

        if i == self.index_entry then
            entry_widget.shape = maker.radius(6)
            entry_widget.bg = colors.fg .. "10"
            entry_widget.fg = colors.fg
        end
    end

    collectgarbage("collect")
end

function menu:run_prompt()
    local prompt = self.main_widget:get_children_by_id("prompt")[1]

    awful.prompt.run {
        prompt = "  ",
        font = settings.font .. " Regular 14",
        textbox = prompt,
        bg_cursor = colors.fg,
        done_callback = function()
            self:close()
        end,
        changed_callback = function(input)
            self.input = input
            self:filter()
            self:add_entries()
        end,
        exe_callback = function(input)
            if self.filtered[self.index_entry] then
                self.filtered[self.index_entry].appinfo:launch()
            else
                awful.spawn.with_shell(input)
            end
        end,
        keypressed_callback = function(_, key)
            if key == "Down" then
                self:next()
            elseif key == "Up" then
                self:back()
            end
        end
    }
end

function menu:open()
    if self.state then return end
    self.state = true
    self.popup_widget.visible = true
    self:send_state()

    self.index_start, self.index_entry = 1, 1
    self.unfiltered = self.get_apps()

    self.input = ""
    self:filter()
    self:add_entries()

    awful.keygrabber.stop()
    self:run_prompt()

    self.popup_widget.placement = function(d)
        awful.placement.bottom_left(d, { honor_workarea = true, margins = 10 })
    end
end

function menu:close()
    if not self.state then return end
    self.state = false
    awful.keygrabber.stop()
    self.popup_widget.visible = false
    self:send_state()
end

usericon:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        menu:close()
    end)
))

function menu:toggle()
    if not self.popup_widget.visible then
        self:open()
    else
        self:close()
    end
end

function menu:send_state()
    awesome.emit_signal("menu:state", self.state)
end

awesome.connect_signal("change::theme", function(c)
    menu.popup_widget:set_bg(colors.bg)

    menu.main_widget:get_children_by_id("menu")[1]:set_fg(colors.fg)
    menu.main_widget:get_children_by_id("prompt_icon")[1]:set_fg(colors.fg)
    menu.main_widget:get_children_by_id("prompt_icon")[1]:set_bg(colors.alt_bg .. "50")
end)

return menu
