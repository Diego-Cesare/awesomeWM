ruled.client.connect_signal("request::rules", function()
    ruled.client.append_rule {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.centered
        }
    }

    ruled.client.append_rule {
        id = "floating",
        rule_any = {
            instance = {"copyq", "pinentry"},
            class = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            name = {"Event Tester"},
            role = {"AlarmWindow", "ConfigManager", "pop-up"}
        },
        properties = {floating = true}
    }

    ruled.client.append_rule {
        rule = {class = "pop-up"},
        properties = {titlebars_enabled = false}
    }

    ruled.client.append_rule {
        id = "titlebars",
        rule_any = {type = {"normal", "dialog"}},
        properties = {titlebars_enabled = true}
    }
end)
