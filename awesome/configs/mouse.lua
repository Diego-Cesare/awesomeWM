awful.mouse.append_global_mousebindings({
    awful.button({}, 1, function()
        info_center.visible = false
        -- wallpapers.visible = false
        music_player.visible = false
        notify_center.visible = false
        launcher:close()
    end)
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate{context = "mouse_click"}
        end), awful.button({modkey}, 1, function(c)
            c:activate{context = "mouse_click", action = "mouse_move"}
        end), awful.button({modkey}, 3, function(c)
            c:activate{context = "mouse_click", action = "mouse_resize"}
        end)
    })
end)
