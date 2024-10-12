-- Get player status
local player_status = "playerctl status"
-- Get title music
local title_cmd = "playerctl metadata --format '{{ title }}'"
-- Get artist name
local artist_cmd = "playerctl metadata --format '{{ artist }}'"
-- Image path
local tmp_dir = gears.filesystem.get_cache_dir() .. "/img"
-- Temporary cover image path
local tmp_cover_path = tmp_dir .. "/cover.png"
-- Command to get cover art URL from playerctl and save it to a temporary file
local art_command = "curl $(playerctl metadata mpris:artUrl) --output " ..
                        tmp_cover_path
-- Fake image path (icon) if cover art is not found or playerctl fails to get it
local img_fake = os.getenv("HOME") .. "/.config/awesome/theme/music.png"
-- Get current time
local current_time = "playerctl metadata --format '{{ duration(position) }}'"
-- Get total music time
local total_time = "playerctl metadata --format '{{ duration(mpris:length) }}'"

local function clean_string(str) return str:gsub("%s+", " ") end

local function execute_command(cmd, callback)
    awful.spawn.easy_async_with_shell(cmd, function(output)
        callback(clean_string(output))
    end)
end

local function emit_metadata()
    execute_command(title_cmd, function(title)
        execute_command(artist_cmd, function(artist)
            execute_command(player_status, function(std)
                local out = std:gsub("%s+", "")
                if out ~= "Playing" then
                    title = "Titulo"
                    artist = "Artista"
                end
                awesome.emit_signal("play::metadata", title, artist)
                collectgarbage("collect")
            end)
        end)
    end)
end

local function emit_cover()
    local function make_dir(path) gears.filesystem.make_directories(path) end

    make_dir(tmp_dir)

    execute_command(art_command, function()
        execute_command(player_status, function(std)
            local out = std:gsub("%s+", "")
            if out == "Playing" then
                cover_path = tmp_cover_path
            else
                cover_path = img_fake
            end
            awesome.emit_signal("image::metadata", cover_path)
            collectgarbage("collect")
        end)
    end)
end

local function emit_status()
    execute_command(player_status, function(std)
        local out = std:gsub("%s+", "")
        awesome.emit_signal("status::metadata", out)
        collectgarbage("collect")
    end)
end

local function emit_time()
    execute_command(player_status, function(std)
        local out = std:gsub("%s+", "")
        if out == "Playing" then
            execute_command(current_time, function(std_time)
                out_time = std_time:gsub("%s+", "")
            end)
            execute_command(total_time, function(std_time_total)
                time_total = std_time_total:gsub("%s+", "")
            end)
            time = out_time .. "|" .. time_total
        else
            time = "__:__ / __:__"
        end
        awesome.emit_signal("time::metadata", time)
        collectgarbage("collect")
    end)
    collectgarbage("collect")
end

local function emit_perc()
    local out_total = "playerctl metadata mpris:length"
    local out_current = "playerctl position"

    execute_command(out_current, function(std_time)
        local out_time = std_time:gsub("%s+", "")
        local current_seconds = tonumber(out_time) or 0

        -- Obter o tempo total da música
        execute_command(out_total, function(std_time_total)
            local time_total = std_time_total:gsub("%s+", "")
            local total_seconds = tonumber(time_total) or 1

            total_seconds = total_seconds / 1000000

            local percentage = (current_seconds / total_seconds) * 100
            execute_command("playerctl status", function(std)
                local out = std:gsub("%s+", "")
                local percent
                if out == "Playing" then
                    percent = percentage
                else
                    percent = 0
                end
                awesome.emit_signal("perc::metadata", percent)
            end)
        end)
    end)
end

local timer_a = gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function()
        emit_metadata()
        emit_cover()
    end
}

local timer_b = gears.timer {
    timeout = 1,
    call_now = true,
    autostart = true,
    callback = function()
        emit_time()
        emit_perc()
        emit_status()
    end
}

local function stop_all()
    execute_command(player_status, function(std)
        local out = std:gsub("%s+", "")
        if out == "Playing" then
            timer_a:start()
            timer_b:start()
        else
            timer_a:stop()
            timer_b:stop()
        end
        collectgarbage("collect")
    end)
end

gears.timer {
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = stop_all
}
