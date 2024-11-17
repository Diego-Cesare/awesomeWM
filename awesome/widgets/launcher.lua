local menu = {}                                                     -- Criar um objeto para guardar as funções
local itens = 6                                                     -- Quantidade de itens na lista

if settings.awesometheme == "dark" then                             -- Se o tema for dark
    menu_back = "/home/diego/Imagens/Abstract/wallhaven-0wm99q.jpg" -- Caminho da imagem de fundo
else                                                                -- Se o tema for light
    menu_back = "/.config/awesome/themes/icons/menu_back_light.png" -- Caminho da imagem de fundo
end

-- Função para carregar a imagem de fundo
local wallpaper_path_file = gears.filesystem.get_cache_dir() .. "/current_wallpaper.txt"

local function load_back()                         -- Função para carregar a imagem de fundo
    local file = io.open(wallpaper_path_file, "r") -- Abrir o arquivo
    if file then                                   -- Se o arquivo existir
        local path = file:read("*all")             -- Ler o arquivo
        file:close()                               -- Fechar o arquivo
        return path                                -- Retornar a imagem de fundo
    end
    return nil                                     -- Retornar nil
end

local back = wibox.widget({          -- Criar um widget para a imagem de fundo
    widget = wibox.widget.imagebox,  -- Widget para exibir a imagem
    image = load_back(),             -- Image
    valign = "top",                  -- Alinhamento vertical
    halign = "center",               -- Alinhamento horizontal
    scaling_quality = "best",        -- Qualidade da imagem
    horizontal_fit_policy = "cover", -- Alinhamento horizontal
    --vertical_fit_policy = "pad", -- Alinhamento vertical
    resize = true,                   -- Redimensionar a imagem
})

local power = maker.button(icons.power, 50, nil)   -- Criar um botão para o power
maker.hover(power, colors.yellow, nil, 0)          -- Adicionar efeito de hover
local reboot = maker.button(icons.reboot, 50, nil) -- Criar um botão para o reboot
maker.hover(reboot, colors.yellow, nil, 0)         -- Adicionar efeito de hover
local exit = maker.button(icons.exit, 50, nil)     -- Criar um botão para o exit
maker.hover(exit, colors.yellow, nil, 0)           -- Adicionar efeito de hover
power.forced_height = dpi(50)                      -- Definir a altura do botão
reboot.forced_height = dpi(50)                     -- Definir a altura do botão
exit.forced_height = dpi(50)                       -- Definir a altura do botão


power:buttons(gears.table.join(           -- Adicionar botões ao botão de power
    awful.button({}, 1, nil, function()   -- Botão esquerdo
        awful.spawn("systemctl poweroff") -- Desligar
    end)
))

reboot:buttons(gears.table.join(        -- Adicionar botões ao botão de reboot
    awful.button({}, 1, nil, function() -- Botão esquerdo
        awful.spawn("systemctl reboot") -- Reiniciar
    end)
))

exit:buttons(gears.table.join(                      -- Adicionar botões ao botão de exit
    awful.button({}, 1, nil, function()             -- Botão esquerdo
        awful.spawn.with_shell("pkill -u -9 $USER") -- Encerrar o processo do usuário
    end)
))

local power_box = wibox.widget({            -- Criar um widget para o botão de power
    layout = wibox.layout.fixed.horizontal, -- Layout
    spacing = dpi(0),                       -- Espaçamento
    power,                                  -- Botão de power
    reboot,                                 -- Botão de reboot
    exit,                                   -- Botão de exit
})

local usericon = wibox.widget({          -- Criar um widget para o ícone do usuário
    widget = wibox.container.background, -- Widget para exibir o ícone
    bg = colors.alt_bg,                  -- Cor de fundo
    border_width = 2,                    -- Tamanho do borda
    border_color = colors.magenta,       -- Cor do borda
    forced_height = dpi(150),            -- Altura do widget
    shape = gears.shape.circle,          -- Forma do widget
    {
        widget = wibox.widget.imagebox,  -- Widget para exibir o ícone
        image = icons.user,              -- Ícone
        valign = "center",               -- Alinhamento vertical
        halign = "center",               -- Alinhamento horizontal
        horizontal_fit_policy = "cover", -- Alinhamento horizontal
        vertical_fit_policy = "cover",   -- Alinhamento vertical
        resize = true,                   -- Redimensionar o ícone
    },
})

local main_power = wibox.widget({           -- Criar um widget para o botão de power
    layout = wibox.layout.fixed.horizontal, -- Layout
    spacing = dpi(230),                     -- Espaçamento
    maker.margins(power_box, 20, 0, 20, 0), -- Adicionar margens
})

-- Criar um widget para o nome do host
local awesomeWM = wibox.widget.textbox()
-- Adicionar o texto ao widget
awesomeWM.markup = maker.text(colors.fg .. "99", settings.font .. " Bold 30", "AwesomeWM")
-- Criar um widget para o nome do distro
local distro = wibox.widget.textbox()
-- Adicionar o texto ao widget
distro.markup = maker.text(colors.fg, settings.font .. " Regular 20", settings.host)

local wm_box = wibox.widget({                 -- Criar um widget para o nome do WM
    layout = wibox.layout.fixed.horizontal,   -- Layout
    spacing = dpi(50),                        -- Espaçamento
    {
        layout = wibox.layout.fixed.vertical, -- Layout
        spacing = dpi(0),                     -- Espaçamento
        maker.margins(awesomeWM, 0, 0, 0, 7), -- Adicionar margens
        distro,                               -- Widget para o nome do distro
    },
    maker.margins(usericon, 80, 0, 90, 0),    -- Adicionar margens
})

menu.main_widget = wibox.widget({            -- Criar um widget para o menu
    layout = wibox.layout.stack,             -- Layout
    back,                                    -- Widget para a imagem de fundo
    forced_height = dpi(730),                -- Altura do widget
    forced_width = dpi(500),                 -- Largura do widget
    {
        widget = wibox.container.background, -- Widget para exibir o menu
        bg = colors.transparent              -- Cor de fundo
    },
    {
        layout = wibox.layout.fixed.vertical,     -- Layout
        {
            layout = wibox.layout.fixed.vertical, -- Layout
            main_power,                           -- Botão de power
        },
        {
            widget = wibox.container.background, -- Widget para exibir o menu
            maker.margins(wm_box, 20, 0, 50, 0), -- Adicionar margens
        },
        {
            widget = wibox.container.margin,                                                -- Widget para exibir o menu
            margins = { top = dpi(20), bottom = dpi(20), left = dpi(10), right = dpi(10) }, -- Margens
            {
                widget = wibox.container.background,                                        -- Widget para exibir o prompt
                bg = colors.fg .. "50",                                                     -- Cor de fundo
                fg = colors.fg,                                                             -- Cor do texto
                border_width = dpi(2),                                                      -- Tamanho do borda
                border_color = colors.black,                                                -- Cor do borda
                shape = maker.radius(10),                                                   -- Forma do widget
                forced_height = dpi(40),                                                    -- Altura do widget
                id = "prompt_icon",                                                         -- ID do widget
                {
                    id = "prompt",                                                          -- ID do widget
                    widget = wibox.widget
                        .textbox                                                            -- Widget para exibir o prompt
                },
            },
        },
        {
            widget = wibox.container.margin,                                               -- Widget para exibir o menu
            margins = { top = dpi(0), bottom = dpi(20), left = dpi(10), right = dpi(20) }, -- Margens
            {
                widget = wibox.container.background,                                       -- Widget para exibir o menu
                id = "menu",                                                               -- ID do widget
                fg = colors.fg,                                                            -- Cor do texto
                {
                    id = "entries_container",                                              -- ID do widget
                    layout = wibox.layout.fixed.vertical,                                  -- Layout
                },
            },
        },
    },
})

menu.popup_widget = awful.popup {        --       -- Criar um popup para o menu
    ontop = true,                        -- Colocar o popup acima
    visible = false,                     -- Exibir o popup
    type = "dock",                       -- Tipo do popup
    widget = wibox.container.background, -- Widget para exibir o popup
    bg = colors.bg,                      -- Cor de fundo
    shape = maker.radius(10),            -- Forma do popup
}

menu.popup_widget:setup({                -- Configurar o popup
    widget = wibox.container.background, -- Widget para exibir o popup
    bg = colors.transparent,             -- Cor de fundo
    shape = maker.radius(0),             -- Forma do popup
    shape_border_color = colors.bg,      -- Cor do borda
    shape_border_width = 0,              -- Tamanho do borda
    menu.main_widget                     -- Widget para exibir o menu
})

function menu:next()                                                  -- Função para mover para a próxima entrada
    if self.index_entry ~= #self.filtered and #self.filtered > 1 then -- Se não estiver na última entrada e houver mais de uma entrada
        self.index_entry = self.index_entry + 1                       -- Mover para a próxima entrada
        if self.index_entry > self.index_start + itens - 1 then       -- Se a próxima entrada for maior que o número de itens
            self.index_start = self.index_start + 1                   -- Mover para a próxima página
        end
    else                                                              -- Se não estiver na última entrada e não houver mais de uma entrada
        self.index_entry = 1                                          -- Mover para a primeira entrada
        self.index_start = 1                                          -- Mover para a primeira página
    end
end

function menu:back()                                      -- Função para mover para a entrada anterior
    if self.index_entry ~= 1 and #self.filtered > 1 then  -- Se não estiver na primeira entrada e houver mais de uma entrada
        self.index_entry = self.index_entry - 1           -- Mover para a entrada anterior
        if self.index_entry < self.index_start then       -- Se a entrada anterior for menor que a página atual
            self.index_start = self.index_start - 1       -- Mover para a página anterior
        end
    else                                                  -- Se não estiver na primeira entrada e não houver mais de uma entrada
        self.index_entry = #self.filtered                 -- Mover para a última entrada
        if #self.filtered < itens then                    -- Se a última entrada for menor que o número de itens
            self.index_start = 1                          -- Mover para a primeira página
        else                                              -- Se a última entrada for maior que o número de itens
            self.index_start = #self.filtered - itens + 1 -- Mover para a última página
        end
    end
end

function menu.get_apps()                           -- Função para obter as aplicações
    local apps = {}                                -- Criar um objeto para guardar as aplicações
    for _, app in ipairs(Gio.AppInfo.get_all()) do -- Obter todas as aplicações
        if app:should_show() then                  -- Verificar se a aplicação deve ser exibida
            table.insert(apps, {                   -- Adicionar a aplicação ao objeto
                appinfo = app,                     -- Informações da aplicação
                name = app:get_name(),             -- Nome da aplicação
                executable = app:get_executable()  -- Executável da aplicação
            })
        end
    end

    return apps -- Retornar as aplicações
end

function menu:filter() -- - Função para filtrar as aplicações
    -- Limpar o input
    local clear_input = self.input:gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%[", "%%["):gsub("%]", "%%]")

    self.filtered = {}     -- Criar um objeto para guardar as aplicações filtradas
    self.filtered_any = {} -- Criar um objeto para guardar as aplicações que correspondem ao input

    -- Filtrar as aplicações
    for _, entry in ipairs(self.unfiltered) do
        -- Verificar se a aplicação corresponde ao input
        if entry.name:lower():sub(1, clear_input:len()) == clear_input:lower() or entry.executable:lower():sub(1, clear_input:len()) == clear_input:lower() then
            table.insert(self.filtered, entry) -- Adicionar a aplicação ao objeto
            -- Verificar se a aplicação corresponde ao input
        elseif entry.name:lower():match(clear_input:lower()) or entry.executable:lower():sub(1, clear_input:len()) == clear_input:lower() then
            -- Adicionar a aplicação ao objeto
            table.insert(self.filtered_any, entry)
        end
    end

    -- Ordenar as aplicações
    table.sort(self.filtered, function(a, b) return a.name:lower() < b.name:lower() end)
    -- Ordenar as aplicações
    table.sort(self.filtered_any, function(a, b) return a.name:lower() < b.name:lower() end)

    for i = 1, #self.filtered_any do                             -- Adicionar as aplicações que correspondem ao input
        self.filtered[#self.filtered + 1] = self.filtered_any[i] -- Adicionar a aplicação ao objeto
    end
end

function menu:add_entries() -- Função para adicionar as entradas ao menu
    -- Criar um objeto para guardar as entradas
    local entries_container = self.main_widget:get_children_by_id("entries_container")[1]
    entries_container:reset()                                         -- Limpar os widgets

    if self.index_entry > #self.filtered and #self.filtered ~= 0 then -- Se não estiver na última entrada e houver mais de uma entrada
        self.index_start, self.index_entry = 1, 1                     -- Mover para a primeira entrada
    elseif self.index_entry < 1 then                                  -- Se não estiver na primeira entrada
        self.index_entry, self.index_start = 1, 1                     -- Mover para a primeira entrada
    end

    for i, entry in ipairs(self.filtered) do      -- Adicionar as entradas ao objeto
        local entry_widget = wibox.widget {       -- Criar um widget para a entrada
            forced_height = dpi(40),              -- Altura do widget
            buttons = {                           -- Botões do widget
                awful.button({}, 1, function()    -- Botão esquerdo
                    if self.index_entry == i then -- Se a entrada for a atual
                        entry.appinfo:launch()    -- Executar a aplicação
                        self:close()              -- Fechar o menu
                    else                          -- Se a entrada for diferente da atual
                        self.index_entry = i      -- Mover para a entrada
                        self:filter()             -- Filtrar as aplicações
                        self:add_entries()        -- Adicionar as entradas ao menu
                    end
                end),
                awful.button({}, 4, function() -- Rodar para a entrada anterior
                    self:back()                -- Mover para a entrada anterior
                    self:filter()              -- Filtrar as aplicações
                    self:add_entries()         -- Adicionar as entradas ao menu
                end),
                awful.button({}, 5, function() -- Rodar para a próxima entrada
                    self:next()                -- Mover para a próxima entrada
                    self:filter()              -- Filtrar as aplicações
                    self:add_entries()         -- Adicionar as entradas ao menu
                end),
            },
            widget = wibox.container.background,           -- Widget para exibir a entrada
            {
                widget = wibox.container.margin,           -- Widget para exibir a entrada
                margins = dpi(10),                         -- Margens
                {
                    widget = wibox.widget.textbox,         -- Widget para exibir o texto
                    font = settings.font .. " Regular 12", -- Fonte
                    id = "text",                           -- ID do widget
                    text = entry.name                      -- Texto
                }
            }
        }

        if self.index_start <= i and i <= self.index_start + itens - 1 then -- Se a entrada estiver dentro da página
            entries_container:add(entry_widget)                             -- Adicionar a entrada ao objeto
        end

        if i == self.index_entry then            -- Se a entrada for a atual
            entry_widget.shape = maker.radius(6) -- Forma do widget
            entry_widget.bg = colors.fg .. "10"  -- Cor do widget
            entry_widget.fg = colors.fg          -- Cor do texto
        end
    end

    collectgarbage("collect") -- Limpar a memória
end

function menu:run_prompt() -- Função para exibir o prompt
    local prompt = self.main_widget:get_children_by_id("prompt")[1] -- Obter o prompt

    awful.prompt.run { -- Exibir o prompt
        prompt = "  ", -- Texto do prompt
        font = settings.font .. " Regular 14", -- Fonte do prompt
        textbox = prompt, -- Widget para exibir o prompt
        bg_cursor = colors.fg, -- Cor do cursor
        done_callback = function() -- Callback para quando o prompt for fechado
            self:close() -- Fechar o menu
        end,
        changed_callback = function(input) -- Callback para quando o input for alterado
            self.input = input -- Guardar o input
            self:filter() -- Filtrar as aplicações
            self:add_entries() -- Adicionar as entradas ao menu
        end,
        exe_callback = function(input) -- Callback para quando o input for executado
            if self.filtered[self.index_entry] then -- Se a aplicação for encontrada
                self.filtered[self.index_entry].appinfo:launch() -- Executar a aplicação
            else
                awful.spawn.with_shell(input) -- Executar o input
            end
        end,
        keypressed_callback = function(_, key) -- Callback para quando o teclado for pressionado
            if key == "Down" then              -- Se a tecla for seta para baixo
                self:next()                    -- Mover para a próxima entrada
            elseif key == "Up" then            -- Se a tecla for seta para cima
                self:back()                    -- Mover para a entrada anterior
            end
        end
    }
end

function menu:open()                                                                -- Função para abrir o menu
    if self.state then return end                                                   -- Se o menu estiver aberto, retornar
    self.state = true                                                               -- Definir o estado do menu como aberto
    self.popup_widget.visible = true                                                -- Exibir o popup
    self:send_state()                                                               -- Enviar o estado do menu

    self.index_start, self.index_entry = 1, 1                                       -- Definir a posição do menu
    self.unfiltered = self.get_apps()                                               -- Obter as aplicações

    self.input = ""                                                                 -- Definir o input como vazio
    self:filter()                                                                   -- Filtrar as aplicações
    self:add_entries()                                                              -- Adicionar as entradas ao menu

    awful.keygrabber.stop()                                                         -- Parar o captura de teclas
    self:run_prompt()                                                               -- Exibir o prompt

    if settings.bar_position == "top" then                                          -- Se a posição da barra for superior
        self.popup_widget.placement = function(d)                                   -- Função para posicionar o popup
            awful.placement.top_left(d, { honor_workarea = true, margins = 20 })    -- Posicionar o popup
        end
    else                                                                            -- Se a posição da barra for inferior
        self.popup_widget.placement = function(d)                                   -- Função para posicionar o popup
            awful.placement.bottom_left(d, { honor_workarea = true, margins = 20 }) -- Posicionar o popup
        end
    end
end

function menu:close()                 -- Função para fechar o menu
    if not self.state then return end -- Se o menu não estiver aberto, retornar
    self.state = false                -- Definir o estado do menu como fechado
    awful.keygrabber.stop()           -- Parar o captura de teclas
    self.popup_widget.visible = false -- Exibir o popup
    self:send_state()                 -- Enviar o estado do menu
end

usericon:buttons(gears.table.join(      -- Adicionar botões ao botão de menu
    awful.button({}, 1, nil, function() -- Botão esquerdo
        menu:close()                    -- Fechar o menu
    end)
))

function menu:toggle()                    -- Função para alternar o menu
    if not self.popup_widget.visible then -- Se o popup não estiver visível
        self:open()                       -- Abrir o menu
    else                                  -- Se o popup estiver visível
        self:close()                      -- Fechar o menu
    end
end

function menu:send_state()                        -- Função para enviar o estado do menu
    awesome.emit_signal("menu:state", self.state) -- Enviar o estado do menu
end

awesome.connect_signal("change::theme", function(c)                                     -- Quando o tema mudar
    menu.popup_widget:set_bg(colors.bg)                                                 -- Definir o fundo do popup

    menu.main_widget:get_children_by_id("menu")[1]:set_fg(colors.fg)                    -- Definir o fundo do menu
    menu.main_widget:get_children_by_id("prompt_icon")[1]:set_fg(colors.fg)             -- Definir o fundo do ícone do prompt
    menu.main_widget:get_children_by_id("prompt_icon")[1]:set_bg(colors.alt_bg .. "50") -- Definir o fundo do ícone do prompt
end)

return menu -- Retornar o menu
