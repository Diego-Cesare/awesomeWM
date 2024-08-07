local dock = require("widgets.bar.modules.dock")
local tools = require("widgets.bar.modules.tools")
local dynamic = require("widgets.bar.dynamic.dynamic")
local tray = require("widgets.bar.modules.tray")
local task = require("widgets.bar.modules.task")
local carrosel = require("widgets.bar.carrosel.carrosel")

local sep = maker.margins(maker.separtor(vertical, 1, 1, 0.5, colors.green), 5, 5, 10, 10)

local box_a = { tools, task, sep, dock }
local box_b = { nil, }
local box_c = { carrosel, sep, dynamic, sep, maker.margins(tray, 10, 5, 0, 0) }


-- Barra principal
local main = awful.wibar({
    stretch = false,
    position = "bottom",
    height = settings.bar_height,
    width = settings.bar_width,
    type = "dock",
    --bg = colors.bg,
    shape = maker.radius(settings.bar_radius),
    opacity = 1,
    ontop = true,
    visible = true,
    widget = {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {
            widget = maker.horizontal_padding_box(5, 0, 5, 5, box_a)
        },
        {
            widget = maker.horizontal_padding_box(0, 0, 5, 5, box_b)
        },
        {
            widget = maker.horizontal_padding_box(0, 5, 5, 5, box_c),
        },
    }
})


local main_geometry = main:geometry()
local main_y_position = main_geometry.y
local screen_geometry = awful.screen.focused().geometry

if settings.bar_floating then
    main.y = main_y_position - 10
else
    main.y = main_y_position
    main.width = screen_geometry.width
    main.shape = maker.radius(0)
end

local function is_floating()
    if settings.bar_floating then
        main.y = main_y_position - 10
        main.width = screen_geometry.width
        main.shape = maker.radius(0)
        settings.bar_floating = false
    else
        main.width = settings.bar_width
        main.shape = maker.radius(settings.bar_radius)
        settings.bar_floating = true
        main.y = main_y_position - 10
    end
end

awesome.connect_signal("float::bar", function()
    is_floating()
end)

local function update_ontop(c)
    main.visible = not c.fullscreen
end

client.connect_signal("property::fullscreen", update_ontop)

awesome.connect_signal("change::theme", function(c)
    main:set_bg(colors.bg)
end)
