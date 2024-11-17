local function create_app_icon(app_name, app_command) -- Função para criar um ícone do aplicativo
    local icon_path = maker.get_icon(app_name)        -- Obter o caminho do ícone do aplicativo
    local icon_widget = wibox.widget {                -- Criar um widget para o ícone do aplicativo
        image = icon_path,                            -- Ícone do aplicativo
        forced_width = dpi(30),                       -- Largura do ícone
        valign = "center",                            -- Alinhamento vertical
        halign = "center",                            -- Alinhamento horizontal
        resize = true,                                -- Redimensionar o ícone
        widget = wibox.widget.imagebox                -- Widget para exibir o ícone
    }

    local button = wibox.widget {                                      -- Criar um botão para o aplicativo
        { icon_widget, margins = 2, widget = wibox.container.margin }, -- Ícone do aplicativo
        shape = maker.radius(6),                                       -- Forma do botão
        widget = wibox.container.background                            -- Widget para exibir o botão
    }

    button:buttons(gears.table.join(awful.button({}, 1, function()          -- Botão esquerdo
            local found = false                                             -- Verificar se o aplicativo já está sendo executado
            for _, c in ipairs(client.get()) do                             -- Obter todos os clientes
                if c.class and c.class:lower() == app_name:lower() then     -- Se o cliente for do aplicativo
                    if c.minimized then                                     -- Se o cliente estiver minimizado
                        c.minimized = false                                 -- Reativar o cliente
                        c:emit_signal("request::activate", "tasklist", nil) -- Reativar o cliente
                    else                                                    -- Se o cliente não estiver minimizado
                        c.minimized = true                                  -- Minimizar o cliente
                    end
                    found = true                                            -- Definir que o aplicativo já está sendo executado
                    break
                end
            end

            if not found then            -- Se o aplicativo não estiver sendo executado
                awful.spawn(app_command) -- Executar o aplicativo
            end
        end),
        awful.button({}, 3, function() -- Botão direito
            awful.spawn(app_command)   -- Executar o aplicativo
        end)))

    maker.hover(button, colors.fg .. "10", colors.transparent, 0)          -- Adicionar efeito de hover

    local function update_bg_color()                                       -- Função para atualizar a cor do botão
        awful.spawn.easy_async_with_shell("pgrep -f '" .. app_name .. "'", -- Obter o PID do aplicativo
            function(stdout)                                               -- Callback
                if stdout and stdout ~= "" then                            -- Se o aplicativo estiver sendo executado
                    button.bg = colors.alt_bg                              -- Definir a cor do botão
                else                                                       -- Se o aplicativo não estiver sendo executado
                    button.bg = colors.transparent                         -- Definir a cor do botão
                end
            end)
    end

    update_bg_color()                                                            -- Atualizar a cor do botão
    gears.timer { timeout = 1, autostart = true, callback = update_bg_color }    -- Atualizar a cor do botão
    return wibox.widget { button, margins = 0, widget = wibox.container.margin } -- Retornar o widget
end

local itens = { -- Lista de aplicativos
    -- Antes de adicionar um aplicativo, verifique seu icone no tema de icones!!!
    -- Pois se ele nao existir no tema de icones e ou for adicionado com o nome errado, ele nao vai funcionar!!!
    -- Icone Comando
    { name = "alacritty",     command = "alacritty" },            -- Alacritty
    { name = "neovim",        command = "alacritty -e nvim" },    -- Neovim
    { name = "theme-config",  command = "lxappearance" },         -- Tema
    { name = "nemo",          command = "nemo" },                 -- Gestor de arquivos
    { name = "google-chrome", command = "google-chrome-stable" }, -- Navegador
    { name = "zed",           command = "zeditor" },              -- Editor
    { name = "apostrophe",    command = "apostrophe" },           -- Editor markdown
    { name = "telegram",      command = "telegram-desktop" },     -- Telegram

}

-- Criar um widget para os
local app_box = wibox.widget { layout = wibox.layout.fixed.horizontal, spacing = dpi(15) }

for _, app in ipairs(itens) do                          -- Criar os ícones dos aplicativos
    app_box:add(create_app_icon(app.name, app.command)) -- Adicionar o ícone do aplicativo
end

-- Criar um widget para a barra de aplicativos
local main = wibox.widget { layout = wibox.layout.fixed.horizontal, app_box }

return main -- Retornar o widget
