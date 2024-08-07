local function notify_updates(count)
    naughty.notify({
        app_name = "Pacman",
        title = "Atualizações",
        text = count .. " Novas atualizações",
        icon = icons.package,
        icon_size = dpi(30),
        timeout = 5
    })
end

local function monitor_updates()
    awful.spawn.easy_async_with_shell("checkupdates | wc -l", function(stdout)
        local count = tonumber(stdout:match("%d+"))
        if count and count > 0 then
            os.execute("mpg123 ~/.config/awesome/themes/songs/update.mp3 &")
            notify_updates(count)
        end
    end)
end

gears.timer({
    timeout = 3600,
    call_now = true,
    autostart = true,
    callback = monitor_updates
})
