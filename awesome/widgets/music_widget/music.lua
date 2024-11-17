local music_graph = wibox.widget({
    max_value        = 100,
    value            = 0,
    forced_height    = 15,
    forced_width     = 200,
    paddings         = 1,
    color            = colors.orange,
    background_color = colors.fg .. "10",
    shape            = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
    id               = "music_graph",
})

local player_img = wibox.widget({
    widget                = wibox.widget.imagebox,
    id                    = "song_img",
    align                 = "center",
    resize                = true,
    horizontal_fit_policy = "cover",
    vertical_fit_policy   = "cover",
    forced_height         = dpi(200),
    forced_width          = dpi(250),
})


local song_info = wibox.widget({
    widget = wibox.widget.textbox,
    halign = "center",
    forced_width = dpi(200),
})

local song_artist = wibox.widget({
    widget = wibox.widget.textbox,
    halign = "center",
    forced_width = dpi(200),
})

local song_time = wibox.widget({
    widget = wibox.widget.textbox,
    halign = "center",
})

awesome.connect_signal("play::metadata", function(title, artist)
    song_info:set_markup(maker.text(colors.fg, "Bold 18", title))
    song_artist:set_markup(maker.text(colors.orange, "Regular 12", artist))
end)

awesome.connect_signal("image::metadata", function(cover_path)
    player_img:set_image(gears.surface.load_uncached(cover_path))
end)

awesome.connect_signal("time::metadata", function(time)
    song_time:set_markup(maker.text(colors.fg, "Bold 12", time))
end)

awesome.connect_signal("perc::metadata", function(percent)
    music_graph.value = percent
end)


local prev_button = wibox.widget({
    widget  = wibox.widget.textbox,
    markup  = "",
    font    = settings.font .. " Regular 20",
    buttons = awful.button({}, 1, function()
        awful.spawn("playerctl previous")
    end),
})

local play_pause_button = wibox.widget({
    widget  = wibox.widget.textbox,
    id      = "player_status",
    font    = settings.font .. " Regular 24",
    buttons = awful.button({}, 1, function()
        awful.spawn("playerctl play-pause")
    end),
})

awesome.connect_signal("status::metadata", function(status)
    if status == "Playing" then
        play_pause_button:get_children_by_id("player_status")[1]:set_text("")
    else
        play_pause_button:get_children_by_id("player_status")[1]:set_text("")
    end
end)


local next_button = wibox.widget({
    widget  = wibox.widget.textbox,
    text    = "",
    font    = settings.font .. " Regular 20",
    buttons = awful.button({}, 1, function()
        awful.spawn("playerctl next")
    end),
})

local player_control = wibox.widget({
    widget = wibox.container.background,
    fg     = colors.fg,
    {
        layout        = wibox.layout.fixed.horizontal,
        forced_height = dpi(50),
        forced_width  = dpi(120),
        spacing       = dpi(15),
        prev_button,
        play_pause_button,
        next_button,
    },
})

local music_widget = awful.popup({
    widget    = wibox.container.background,
    bg        = colors.bg,
    shape     = maker.radius(0),
    ontop     = true,
    visible   = false,
    placement = function(c)
        awful.placement.bottom_right()
    end,
})

music_widget:setup({
    widget = wibox.container.background,
    {
        widget = wibox.container.margin,
        forced_width = dpi(500),
        margins = dpi(30),
        {
            layout = wibox.layout.flex.horizontal,
            {
                layout = wibox.layout.fixed.horizontal,
                {
                    widget = wibox.container.background,
                    border_width = dpi(10),
                    border_color = colors.fg .. "50",
                    shape = gears.shape.circle,
                    player_img,
                },
            },
            {
                layout = wibox.layout.align.vertical,
                expand = "none",
                nil,
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        layout = wibox.layout.flex.vertical,
                        {
                            layout = wibox.layout.align.horizontal,
                            expand = "none",
                            nil,
                            forced_height = dpi(20),
                            forced_width = dpi(100),
                            anime.scroll(song_info, 180, 60, 30),
                            nil
                        },
                        {
                            layout = wibox.layout.align.horizontal,
                            expand = "none",
                            nil,
                            forced_width = dpi(200),
                            anime.scroll(song_artist, 150, 30, 30),
                            nil,
                        },
                    },
                    {
                        layout = wibox.layout.align.horizontal,
                        expand = "none",
                        nil,
                        song_time,
                        nil,
                    },
                    {
                        layout = wibox.layout.align.horizontal,
                        expand = "none",
                        nil,
                        maker.margins(music_graph, 0, 0, 20, 0),
                        nil,
                    },
                    {
                        layout = wibox.layout.align.horizontal,
                        expand = "none",
                        nil,
                        player_control,
                        nil,
                    },
                },
                nil,
            },
        },
    },
})

awesome.connect_signal("theme::colors", function(colors)
    music_widget:set_bg(colors.bg)
    player_control:set_fg(colors.fg)
    music_graph:set_background_color(colors.fg .. "10")
end)


return music_widget
