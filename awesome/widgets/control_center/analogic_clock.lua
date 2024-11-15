local dig_hour = wibox.widget({
    widget = wibox.container.background,
    {
        widget = wibox.widget.textclock,
        halign = "center",
        format = maker.text(colors.orange, "Bold 22", "%H"),
    },
})

local dig_minute = wibox.widget({
    widget = wibox.container.background,
    {
        widget = wibox.widget.textclock,
        halign = "center",
        format = maker.text(colors.gray, "Bold 20", "%M"),
    },
})

local dig_sep = wibox.widget({
    widget = wibox.container.background,
    {
        widget = wibox.widget.textbox,
        markup = maker.text(colors.gray, "Bold 22", ":"),
    },
})

local clock = wibox.widget({
    widget = wibox.container.background,
    {
        widget = wibox.container.place,
        halign = "center",
        valign = "center",
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(0),
            dig_hour,
            dig_sep,
            dig_minute,
        },
    },
})

local function draw_clock(cr, w, h)
    local cx, cy = w / 2, h / 2
    local side = math.min(cx, cy) * 2 - 20
    local radius = math.min(cx, cy) - 10

    local now = os.date("*t")
    local hour = now.hour % 12
    local min = now.min
    local sec = now.sec

    cr:save()
    cr:set_source_rgba(0, 0, 0, 0)
    cr:paint()
    cr:restore()

    cr:set_source(gears.color(colors.transparent))
    --cr:arc(cx, cy, radius, 0, 2 * math.pi)
    cr:rectangle(cx - radius, cy - radius, side, side)
    cr:fill()

    cr:set_source(gears.color(colors.fg))
    cr:set_line_cap(cairo.LineCap.ROUND)

    cr:set_source(gears.color(colors.orange))
    cr:move_to(cx, cy)
    cr:line_to(cx + radius * 0.8 * math.sin(2 * math.pi * sec / 60),
        cy - radius * 0.8 * math.cos(2 * math.pi * sec / 60))
    cr:set_line_width(1)
    cr:stroke()

    cr:set_source(gears.color(colors.fg))
    cr:move_to(cx, cy)
    cr:line_to(cx + radius * 0.7 * math.sin(2 * math.pi * min / 60),
        cy - radius * 0.7 * math.cos(2 * math.pi * min / 60))
    cr:set_line_width(2)
    cr:stroke()

    cr:move_to(cx, cy)
    cr:line_to(cx + radius * 0.5 * math.sin(2 * math.pi * (hour + min / 60) / 12),
        cy - radius * 0.5 * math.cos(2 * math.pi * (hour + min / 60) / 12))
    cr:set_line_width(3)
    cr:stroke()

    cr:set_line_width(2)
    for i = 0, 11 do
        local angle = 2 * math.pi * i / 12
        local is_second_over = sec == (i % 12) * 5

        if is_second_over then
            cr:set_source(gears.color(colors.orange))
        else
            cr:set_source(gears.color(colors.fg))
        end

        cr:set_line_width(4)
        cr:move_to(cx + radius * 0.9 * math.sin(angle),
            cy - radius * 0.9 * math.cos(angle))
        cr:line_to(cx + radius * math.sin(angle),
            cy - radius * math.cos(angle))
        cr:stroke()
    end
end

-- Crie o widget do relógio
local clock_widget = wibox.widget {
    widget = wibox.container.background,
    bg = colors.alt_bg,
    shape = maker.radius(6),
    {
        layout = wibox.layout.align.vertical,
        expand = "none",
        forced_width = dpi(150),
        forced_height = dpi(200),
        maker.margins(clock, 0, 0, 20, 0),
        nil,
        {
            widget = wibox.widget.base.make_widget,
            fit = function(_, _, _, _)
                return 150, 150
            end,
            draw = function(_, _, cr, width, height)
                draw_clock(cr, width, height)
            end,
        },
    }
}

-- Atualize o relógio a cada segundo
gears.timer {
    timeout = 1,
    autostart = true,
    callback = function()
        clock_widget:emit_signal("widget::redraw_needed")
    end,
}

awesome.connect_signal("change::theme", function()
    clock_widget:set_bg(colors.alt_bg)
end)


return clock_widget
