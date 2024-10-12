local player_img = maker.image(icons.music, colors.transparent, 3, 0, "music")

local song_info = wibox.widget({
    widget = wibox.widget.textbox,
    halign = "center"
})

local music_graph = wibox.widget({
    max_value = 100,
    value = 0,
    forced_height = 8,
    forced_width = 120,
    paddings = 1,
    color = colors.orange,
    background_color = colors.fg .. "10",
    shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar,
    id = "music_graph"
})

local song_description = wibox.widget({
    widget = wibox.widget.textbox,
    markup = maker.text(colors.orange, "Bold 10", "Tocando agora"),
    halign = "right",
    valign = "center"
})

local song_artist = wibox.widget({
    widget = wibox.widget.textbox,
    halign = "right"
})

awesome.connect_signal("perc::metadata",
                       function(percent) music_graph.value = percent end)

awesome.connect_signal("play::metadata", function(title, artist)
    song_info:set_markup(maker.text(colors.fg, "Bold 10", title))
    song_artist:set_markup(maker.text(colors.fg, "Regular 9", artist))
    awesome.connect_signal("theme::colors", function(colors)
        song_info:set_markup(maker.text(colors.fg, "Bold 10", title))
        song_artist:set_markup(maker.text(colors.fg, "Regular 9", artist))
    end)
    if artist == "Artist" then
        song_description:set_markup(maker.text(colors.fg, "Bold 10",
                                               "Parado agora"))
    else
        song_description:set_markup(maker.text(colors.orange, "Bold 10",
                                               "Tocando agora"))
    end
end)

player_img:buttons(gears.table.join(awful.button({}, 1, nil, function(s)
    if not music_player.visible then
        music_player.visible = true
        anime.move_x(music_player, 1410, 320, "right")
    else
        anime.move_x_out(music_player, 1420, 320, "left")
        gears.timer.start_new(0.9, function()
            music_player.visible = false
            return false
        end)
    end
end)))

local main_scrool = wibox.widget({
    widget = wibox.container.place,
    valign = "center",
    {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
        anime.scroll(song_info, 120, 30, 30),
        music_graph
    }
})

local widgets_left = {player_img, maker.margins(main_scrool, 10, 0, 0, 0)}
local widgets_right = {song_description, anime.scroll(song_artist, 100, 30, 30)}

local music_widget = wibox.widget({
    layout = wibox.layout.align.horizontal,
    forced_width = dpi(330),
    expand = "none",
    visible = false,
    {widget = maker.horizontal_padding_box(0, 0, 0, 0, widgets_left)},
    nil,
    {
        widget = wibox.container.place,
        valign = "center",
        maker.vertical_padding_box(0, 0, 0, 0, widgets_right)
    }
})

awesome.connect_signal("theme::colors", function(colors)
    music_graph:set_background_color(colors.fg .. "10")
end)

awesome.connect_signal("theme::icons", function(icons)
    player_img:get_children_by_id("music")[1]:set_image(icons.music)
end)

return music_widget
