-- Define the widget
local shot_now = wibox.widget({
    widget = wibox.container.background,
    bg = colors.magenta .. "50",
    fg = colors.fg,
    forced_width = dpi(225),
    shape = maker.radius(6),
    {
        widget = wibox.container.margin,
        margins = { top = dpi(10), bottom = dpi(10), left = dpi(10), right = dpi(10) },
        {
            layout = wibox.layout.align.vertical,
            expanded = "none",
            {
                widget = wibox.widget.imagebox,
                image = icons.print,
                id = "print",
                resize = true,
                forced_height = dpi(40),
            },
            nil,
            {
                widget = wibox.widget.textbox,
                text = "Captura de tela",
                id = "text",
                font = settings.font .. " Regular 12",
            },
        },
    },
})

local shot_area = wibox.widget({
    widget = wibox.container.background,
    bg = colors.alt_bg .. "50",
    fg = colors.fg,
    forced_width = dpi(225),
    shape = maker.radius(6),
    {
        widget = wibox.container.margin,
        margins = { top = dpi(10), bottom = dpi(10), left = dpi(10), right = dpi(10) },
        {
            layout = wibox.layout.fixed.horizontal,
            {
                widget = wibox.widget.imagebox,
                image = icons.area,
                id = "area",
                resize = true,
                forced_height = dpi(30),
            },
            {
                widget = wibox.widget.textbox,
                text = " Capturar area",
                id = "text",
                align = "center",
                font = settings.font .. " Regular 10",
            },
        },
    },
})

local shot_time = wibox.widget({
    widget = wibox.container.background,
    bg = colors.alt_bg .. "50",
    fg = colors.fg,
    forced_width = dpi(225),
    shape = maker.radius(6),
    {
        widget = wibox.container.margin,
        margins = { top = dpi(10), bottom = dpi(10), left = dpi(10), right = dpi(10) },
        {
            layout = wibox.layout.fixed.horizontal,
            {
                widget = wibox.widget.imagebox,
                image = icons.timer,
                id = "timer",
                resize = true,
                forced_height = dpi(30),
            },
            {
                widget = wibox.widget.textbox,
                text = " Captura em 5s",
                id = "text",
                align = "center",
                font = settings.font .. " Regular 10",
            },
        },
    },
})

maker.hover(shot_now, colors.magenta, colors.magenta .. "50", 1)
maker.hover(shot_area, colors.yellow, colors.alt_bg .. "50", 1)
maker.hover(shot_time, colors.red, colors.alt_bg .. "50", 1)

local now = "maim "
local area = "maim -s "

local function take_screenshot(time, type)
    time = time
    local filename = os.getenv("HOME") .. "/screenshot_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    awful.spawn.easy_async_with_shell(type .. filename, function()
        gears.timer.start_new(time, function()
            if gears.filesystem.file_readable(filename) then
                naughty.notify({
                    app_name = "Captura de tela",
                    title = "Captura de tela",
                    text = "Screenshot salva como: " .. filename,
                    icon = filename,
                    icon_size = 120,
                    timeout = 5,
                })
            else
                naughty.notify({
                    title = "Erro",
                    text = "A captura de tela falhou ou o arquivo não está acessível.",
                    timeout = 5,
                })
            end
            return false -- Não reiniciar o timer
        end)
    end)
end

shot_now:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        take_screenshot(0.5, now)
    end)
))

shot_area:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        take_screenshot(0.5, area)
    end)
))

shot_time:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        naughty.notify({
            title = "Captura iniciada",
            text = "Captura em 5 segundos.",
            icon = icons.screenshot_timer,
            timeout = 3,
        })
        take_screenshot(5, now)
    end)
))


local main = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    maker.margins(shot_now, 0, 5, 0, 0),
    {
        layout = wibox.layout.flex.vertical,
        maker.margins(shot_time, 5, 0, 0, 5),
        maker.margins(shot_area, 5, 0, 5, 0),
    }
})

awesome.connect_signal("theme::icons", function(icons)
    shot_now:get_children_by_id("print")[1]:set_image(icons.print)
    shot_area:get_children_by_id("area")[1]:set_image(icons.area)
    shot_time:get_children_by_id("timer")[1]:set_image(icons.timer)
end)

awesome.connect_signal("change::theme", function()
    shot_now:set_fg(colors.fg)
    shot_area:set_fg(colors.fg)
    shot_time:set_fg(colors.fg)
    shot_area:set_bg(colors.alt_bg .. "50")
    shot_time:set_bg(colors.alt_bg .. "50")
    maker.hover(shot_area, colors.yellow, colors.alt_bg .. "50", 1)
    maker.hover(shot_time, colors.red, colors.alt_bg .. "50", 1)
end)

return main
