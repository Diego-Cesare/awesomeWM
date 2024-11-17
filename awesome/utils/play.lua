-- Se o player esta ativo
local player_status = "playerctl status"
-- Titulo da música
local title_cmd = "playerctl metadata --format '{{ title }}'"
--  Artista da música
local artist_cmd = "playerctl metadata --format '{{ artist }}'"
-- Imagem da música
local tmp_dir = gears.filesystem.get_cache_dir() .. "/img"
-- Path para a imagem da música
local tmp_cover_path = tmp_dir .. "/cover.png"
-- Comando para obter a imagem da música
local art_command = "curl $(playerctl metadata mpris:artUrl) --output " .. tmp_cover_path
-- Imagem de música sem reprodução
local img_fake = os.getenv("HOME") .. "/.config/awesome/theme/music.png"
-- Tempo da música
local current_time = "playerctl metadata --format '{{ duration(position) }}'"
-- Tempo total da música
local total_time = "playerctl metadata --format '{{ duration(mpris:length) }}'"

local function clean_string(str) return str:gsub("%s+", " ") end -- Limpar a string

-- Função para executar um comando
local function execute_command(cmd, callback)
    awful.spawn.easy_async_with_shell(cmd, function(output) -- Executar o comando
        callback(clean_string(output))                      -- Callback com a string limpa
    end)
end

-- Função para emitir as informações da música
local function emit_metadata()
    execute_command(title_cmd, function(title)                       -- Obter o título da música
        execute_command(artist_cmd, function(artist)                 -- Obter o artista da música
            execute_command(player_status, function(std)             -- Obter o status da música
                local out = std:gsub("%s+", "")                      -- Limpar a string
                if out ~= "Playing" then                             -- Se a música estiver pausada
                    title = "Titulo"                                 -- Definir o título da música
                    artist = "Artista"                               -- Definir o artista da música
                end
                awesome.emit_signal("play::metadata", title, artist) -- Emitir as informações da música
                collectgarbage("collect")                            -- Limpar a memória
            end)
        end)
    end)
end

-- Função para emitir a imagem da música
local function emit_cover()
    -- Função para criar um diretório
    local function make_dir(path)
        gears.filesystem.make_directories(path)
    end

    make_dir(tmp_dir)                                          -- Criar o diretório temporário

    execute_command(art_command, function()                    -- Obter a imagem da música
        execute_command(player_status, function(std)           -- Obter o status da música
            local out = std:gsub("%s+", "")                    -- Limpar a string
            if out == "Playing" then                           -- Se a música estiver tocando
                cover_path = tmp_cover_path                    -- Definir o caminho da imagem da música
            else                                               -- Se a música estiver pausada
                cover_path = img_fake                          -- Definir o caminho da imagem da música
            end
            awesome.emit_signal("image::metadata", cover_path) -- Emitir a imagem da música
            collectgarbage("collect")                          -- Limpar a memória
        end)
    end)
end

local function emit_status()                         -- Função para emitir o status da música
    execute_command(player_status, function(std)     -- Obter o status da música
        local out = std:gsub("%s+", "")              -- Limpar a string
        awesome.emit_signal("status::metadata", out) -- Emitir o status da música
        collectgarbage("collect")                    -- Limpar a memória
    end)
end

local function emit_time()                                       -- Função para emitir o tempo da música
    execute_command(player_status, function(std)                 -- Obter o status da música
        local out = std:gsub("%s+", "")                          -- Limpar a string
        if out == "Playing" then                                 -- Se a música estiver tocando
            execute_command(current_time, function(std_time)     -- Obter o tempo atual da música
                out_time = std_time:gsub("%s+", "")              -- Limpar a string
            end)
            execute_command(total_time, function(std_time_total) -- Obter o tempo total da música
                time_total = std_time_total:gsub("%s+", "")      -- Limpar a string
            end)
            time = out_time .. "|" .. time_total                 -- Definir o tempo da música
        else                                                     -- Se a música estiver pausada
            time = "__:__ / __:__"                               -- Definir o tempo da música
        end
        awesome.emit_signal("time::metadata", time)              -- Emitir o tempo da música
        collectgarbage("collect")                                -- Limpar a memória
    end)
    collectgarbage("collect")                                    -- Limpar a memória
end

local function emit_perc()                                             -- Função para emitir a porcentagem da música
    local out_total = "playerctl metadata mpris:length"                -- Comando para obter o tempo total da música
    local out_current = "playerctl position"                           -- Comando para obter o tempo atual da música

    execute_command(out_current, function(std_time)                    -- Obter o tempo atual da música
        local out_time = std_time:gsub("%s+", "")                      -- Limpar a string
        local current_seconds = tonumber(out_time) or 0                -- Converter o tempo atual para segundos

        execute_command(out_total, function(std_time_total)            -- Obter o tempo total da música
            local time_total = std_time_total:gsub("%s+", "")          -- Limpar a string
            local total_seconds = tonumber(time_total) or 1            -- Converter o tempo total para segundos

            total_seconds = total_seconds / 1000000                    -- Converter o tempo total para milissegundos

            local percentage = (current_seconds / total_seconds) * 100 -- Calcular a porcentagem da música
            execute_command("playerctl status", function(std)          -- Obter o status da música
                local out = std:gsub("%s+", "")                        -- Limpar a string
                local percent                                          -- Definir a porcentagem da música
                if out == "Playing" then                               -- Se a música estiver tocando
                    percent = percentage                               -- Definir a porcentagem da música
                else                                                   -- Se a música estiver pausada
                    percent = 0                                        -- Definir a porcentagem da música
                end
                awesome.emit_signal("perc::metadata", percent)         -- Emitir a porcentagem da música
            end)
        end)
    end)
end

local timer_a = gears.timer { -- Criar um timer para emitir as informações da música
    timeout = 5,              -- Tempo de pausa
    call_now = true,          -- Chamar agora
    autostart = true,         -- Iniciar automaticamente
    callback = function()     -- Callback
        emit_metadata()       -- Emitir as informações da música
        emit_cover()          -- Emitir a imagem da música
    end
}

local timer_b = gears.timer { -- Criar um timer para emitir as informações da música
    timeout = 1,              -- Tempo de pausa
    call_now = true,          -- Chamar agora
    autostart = true,         -- Iniciar automaticamente
    callback = function()     -- Callback
        emit_time()           -- Emitir o tempo da música
        emit_perc()           -- Emitir a porcentagem da música
        emit_status()         -- Emitir o status da música
    end
}

local function stop_all()                        -- Função para parar todos os timers
    execute_command(player_status, function(std) -- Obter o status da música
        local out = std:gsub("%s+", "")          -- Limpar a string
        if out == "Playing" then                 -- Se a música estiver tocando
            timer_a:start()                      -- Iniciar o timer 1
            timer_b:start()                      -- Iniciar o timer 2
        else                                     -- Se a música estiver pausada
            timer_a:stop()                       -- Parar o timer 1
            timer_b:stop()                       -- Parar o timer 2
        end
        collectgarbage("collect")                -- Limpar a memória
    end)
end

gears.timer {           -- Criar um timer para parar todos os timers
    timeout = 10,       -- Tempo de pausa
    call_now = true,    -- Chamar agora
    autostart = true,   -- Iniciar automaticamente
    callback = stop_all -- Callback
}
