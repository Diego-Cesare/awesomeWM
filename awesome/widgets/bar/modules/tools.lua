local switch_theme = function()                                                  -- Função para alternar o tema
    local theme_path = os.getenv("HOME") .. "/.config/awesome/settings.lua"      -- Caminho do arquivo de configurações
    local file = io.open(theme_path, "r")                                        -- Abrir o arquivo
    local content = file:read("*all")                                            -- Leia o conteúdo do arquivo
    file:close()                                                                 -- Fechar o arquivo

    if content:match('settings.theme%s*=%s*"dark"') then                         -- Se o tema está definido como dark
        content = content:gsub('settings.theme%s*=%s*".-"',                      -- Substituir o valor do tema
            'settings.theme = "light"')                                          -- Alterar o valor do tema para light
        os.execute("sed -i 's/dark/light/g' ~/.config/alacritty/alacritty.toml") -- Alterar o arquivo de configurações
    elseif content:match('settings.theme%s*=%s"light"') then                     -- Se o tema está definido como light
        content = content:gsub('settings.theme%s*=%s*".-"',                      -- Substituir o valor do tema
            'settings.theme = "dark"')                                           -- Alterar o valor do tema para dark
        os.execute("sed -i 's/light/dark/g' ~/.config/alacritty/alacritty.toml") -- Alterar o arquivo de configurações
    end

    file = io.open(theme_path, "w") -- Abrir o arquivo
    file:write(content)             -- Escrever o conteúdo no arquivo
    file:close()                    -- Fechar o arquivo
end

local function update_mode_icon()    -- Função para atualizar o ícone do modo
    if settings.theme == "dark" then -- Se o tema for dark
        return icons.mode_dark       -- Retornar o ícone do modo
    else                             -- Se o tema for light
        return icons.mode            -- Retornar o ícone do modo
    end
end

local spacer = wibox.widget({     -- Criar um espaço
    markup = "",                  -- Texto vazio
    forced_width = dpi(10),       -- Largura do espaço
    halign = "center",            -- Alinhamento horizontal
    valign = "center",            -- Alinhamento vertical
    widget = wibox.widget.textbox -- Widget para exibir o texto
})

-- Criar um botão para o menu
local menu_bnt = maker.image(icons.menu, colors.transparent, dpi(5), dpi(0), "menu_bnt")
-- Criar um botão para a informação
local info_bnt = maker.image(icons.infos, colors.transparent, dpi(5), dpi(0), "info_bnt")
-- Criar um botão para o modo
local mode_bnt = maker.image(update_mode_icon(), colors.transparent, dpi(5), dpi(0), "mode_bnt")
-- Criar um botão para o menu
menu_bnt:buttons({ awful.button(nil, 1, function() launcher:toggle() end) })

local function open_info_center()                         -- Função para abrir o centro de informação
    if settings.bar_position == "top" then                -- Se a posição da barra for superior
        return anime.move_x(info_center, 10, -40, "left") -- Mover o centro de informação
    else                                                  -- Se a posição da barra for inferior
        return anime.move_x(info_center, 10, 40, "right") -- Mover o centro de informação
    end
end

info_bnt:buttons({                                -- Botões do botão de informação
    awful.button(nil, 1, function()               -- Botão esquerdo
        if not info_center.visible then           -- Se o centro de informação não estiver visível
            info_center.visible = true            -- Exibir o centro de informação
            open_info_center()                    -- Abrir o centro de informação
        else                                      -- Se o centro de informação estiver visível
            gears.timer.start_new(0.9, function() -- Iniciar um timer para fechar o centro de informação
                info_center.visible = false       -- Fechar o centro de informação
                return false                      -- Retornar falso
            end)
        end
    end)
})

mode_bnt:buttons({                               -- Botões do botão de modo
    awful.button(nil, 1, function()              -- Botão esquerdo
        switch_theme()                           -- Alternar o tema
        if settings.theme == "dark" then         -- Se o tema está definido como dark
            settings.theme = "light"             -- Definir o tema como light
        else                                     -- Se o tema está definido como light
            settings.theme = "dark"              -- Definir o tema como dark
        end
        gears.timer.start_new(0.5, function()    -- Iniciar um timer para emitir a mudança de tema
            awesome.emit_signal("change::theme") -- Emitir a mudança de tema
            awesome.emit_signal("change::icons") -- Emitir a mudança de ícones
            return false                         -- Retornar falso
        end)
    end)
})

-- Criar um box para os botões
local box = { menu_bnt, spacer, info_bnt, spacer, mode_bnt }

local main = wibox.widget {                                      -- Criar um widget para o menu
    widget = wibox.container.background,                         -- Widget para exibir o menu
    bg = colors.transparent,                                     -- Cor de fundo
    shape = maker.radius(6),                                     -- Forma do widget
    { widget = maker.horizontal_padding_box(10, 20, 0, 0, box) } -- Adicionar margens
}

awesome.connect_signal("change::theme",                                       -- Quando o tema mudar
    function() main:set_bg(colors.transparent) end)                           -- Definir o fundo do widget

awesome.connect_signal("theme::icons", function(icons)                        -- Quando os ícones mudarem
    if settings.theme == "dark" then                                          -- Se o tema está definido como dark
        mode_bnt:get_children_by_id("mode_bnt")[1]:set_image(icons.mode)      -- Definir o ícone do modo
    else                                                                      -- Se o tema está definido como light
        mode_bnt:get_children_by_id("mode_bnt")[1]:set_image(icons.mode_dark) -- Definir o ícone do modo
    end
    menu_bnt:get_children_by_id("menu_bnt")[1]:set_image(icons.menu)          -- Definir o ícone do menu
    info_bnt:get_children_by_id("info_bnt")[1]:set_image(icons.infos)         -- Definir o ícone da informação
end)

return main -- Retornar o widget
