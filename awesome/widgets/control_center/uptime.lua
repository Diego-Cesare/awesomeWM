local description = wibox.widget({
    widget = wibox.widget.textbox,
    markup = maker.text(colors.fg, "Regular 14", "Ligado á:"),
})

local uptime = wibox.widget({
    id = "up",
    widget = wibox.widget.textbox,
    font = "Regular 10",
})

local function update_uptime(widget)
    awful.spawn.easy_async_with_shell("uptime -p | sed 's/up//g;s/^ //g;s/hours/h/g'", function(stdout)
        local uptime = string.format(stdout)
        widget:get_children_by_id("up")[1].markup = maker.text(colors.fg, "Regular 10", uptime)

        awesome.connect_signal("change::theme", function()
            widget:get_children_by_id("up")[1].markup = maker.text(colors.fg, "Regular 10", uptime)
        end)
    end)
end

update_uptime(uptime)

gears.timer({
    timeout = 60,
    autostart = true,
    call_now = true,
    callback = function()
        update_uptime(uptime)
    end,
})

local main_uptime = wibox.widget({
    widget = wibox.container.background,
    bg = colors.purple .. "50",
    shape = maker.radius(6),
    {
        widget = wibox.container.place,
        valign = "center",
        {
            layout = wibox.layout.flex.vertical,
            description,
            uptime
        }
    }
})

awesome.connect_signal("change::theme", function()
    description:set_markup(maker.text(colors.fg, "Regular 14", "Ligado á:"))
end)


return main_uptime
