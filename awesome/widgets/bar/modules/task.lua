local dock = require("widgets.bar.modules.dock")
local tasklist_buttons = gears.table.join(
                             awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
            c.first_tag:view_only()
        end
    end))

local task = awful.widget.tasklist {
    screen = awful.screen.focused(),
    filter = awful.widget.tasklist.filter.allscreen,
    buttons = tasklist_buttons,
    style = {shape = maker.radius(6)},
    layout = {spacing = dpi(0), layout = wibox.layout.fixed.horizontal},
    widget_template = {
        id = 'background_role_container',
        bg = colors.transparent,
        widget = wibox.container.background,
        {
            {id = 'clienticon', widget = awful.widget.clienticon, resize = true},
            margins = dpi(15),
            widget = wibox.container.margin
        }
    }

}

task.visible = false

local task_open = wibox.widget {
    markup = maker.text(colors.fg, " Regular 14", ""),
    id = "txt",
    font = settings.font .. " Regular 14",
    align = "center",
    widget = wibox.widget.textbox,
    buttons = {
        awful.button({}, 1, function()
            awesome.emit_signal("widget::task")
            dock.visible = not dock.visible
        end)
    }
}

local main = wibox.widget {
    widget = wibox.container.background,
    bg = colors.transparent,
    shape = maker.radius(6),
    {
        layout = wibox.layout.fixed.horizontal,
        task,
        maker.margins(task_open, 5, 5, 0, 0)
    }
}

awesome.connect_signal("widget::task", function()
    if not task.visible then
        task.visible = true
        task_open.markup = maker.text(colors.fg, " Regular 14", "")
    else
        task.visible = false
        task_open.markup = maker.text(colors.fg, " Regular 14", "")
    end
end)

awesome.connect_signal("change::theme", function()
    main:set_bg(colors.transparent)
    if not task.visible then
        task_open:set_markup(maker.text(colors.fg, " Regular 14", ""))
    else
        task_open:set_markup(maker.text(colors.fg, " Regular 14", ""))
    end
end)

return main
