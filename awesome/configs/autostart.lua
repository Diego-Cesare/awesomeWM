-- Função para executar um comando apenas uma vez
local function run_once(cmd)                                                    -- cmd = comando a ser executado
    local findme = cmd                                                          -- Comando a ser executado
    local firstspace = cmd:find(" ")                                            -- Primeiro espaço do comando
    if firstspace then                                                          -- Se o primeiro espaço for encontrado
        findme = cmd:sub(0, firstspace - 1)                                     -- Buscar o comando sem o primeiro espaço
    end
    awful.spawn.easy_async_with_shell(                                          -- Iniciar o comando
        string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd), -- Comando
        function(stdout, stderr)                                                -- Callback
            if stderr and #stderr > 0 then                                      -- Se o comando falhar
                naughty.notification({                                          -- Notificação
                    app_name = "Start-up Applications",                         -- Nome do aplicativo
                    title = "<b>Eroo na inicialização de um aplicativo!</b>",   -- Título
                    message = stderr:gsub("%\n", ""),                           -- Mensagem
                    timeout = 20,                                               -- Tempo de espera
                    icon = icons.warning,                                       -- Ícone
                })
            end
        end
    )
end

-- Lista de aplicativos para iniciar
local apps = {                                          -- Aplicativos
    "picom",                                            -- Configuração do compositor
    "setxkbmap -model abnt2 -layout br -variant abnt2", -- Teclado
    "xsetroot -cursor_name left_ptr",                   -- Cursor
    "xset s off",                                       -- Tela desligado
    "xset -dpms",                                       -- DPMS
    --"playerctld daemon",                                -- Controle de reprodução de música
    --"nm-applet"                                         -- Applet de rede
}

-- Executa cada aplicativo uma vez
for _, app in ipairs(apps) do -- Aplicativos
    run_once(app)             -- Executar o aplicativo
end
