tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.tile, awful.layout.suit.floating
    })
end)

awful.screen.connect_for_each_screen(function(s)
    awful.tag({"1", "2", "3", "4", "5"}, s, awful.layout.layouts[1])
end)

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        app_name = "Awesome",
        title = "Um erro inesperado ocorreu" ..
            (startup and " Na inicialização" or "!"),
        message = message
    }
end)

ruled.notification.connect_signal('request::rules', function()
    ruled.notification.append_rule {
        rule = {},
        properties = {screen = awful.screen.preferred, implicit_timeout = 5}
    }
end)

client.connect_signal("mouse::enter", function(c)
    c:activate{context = "mouse_enter", raise = false}
end)
