local dock = require("widgets.bar.modules.dock")                             -- Carregar os módulos de aplicativos

local tasklist_buttons = gears.table.join(                                   -- Botões do widget de tarefas
    awful.button({}, 1, function(c)                                          -- Botão esquerdo
        if c == client.focus then                                            -- Se o cliente for o foco
            c.minimized = true                                               -- Minimizar o cliente
        else                                                                 -- Se o cliente não for o foco
            c:emit_signal("request::activate", "tasklist", { raise = true }) -- Reativar o cliente
            c.first_tag:view_only()                                          -- Exibir apenas o cliente
        end
    end))

local task = awful.widget.tasklist {                                                -- Criar um widget para as tarefas
    screen = awful.screen.focused(),                                                -- Obter a tela focada
    filter = awful.widget.tasklist.filter.allscreen,                                -- Filtrar as tarefas
    buttons = tasklist_buttons,                                                     -- Botões do widget
    style = { shape = maker.radius(6) },                                            -- Estilo do widget
    layout = { spacing = dpi(0), layout = wibox.layout.fixed.horizontal },          -- Layout do widget
    widget_template = {                                                             -- Widget do widget
        id = 'background_role_container',                                           -- ID do widget
        bg = colors.transparent,                                                    -- Cor de fundo
        widget = wibox.container.background,                                        -- Widget para exibir o widget
        {
            { id = 'clienticon', widget = awful.widget.clienticon, resize = true }, -- Widget do cliente
            margins = dpi(5),                                                       -- Margens
            widget = wibox.container.margin                                         -- Widget para exibir o cliente
        }
    }

}

task.visible = false -- Exibir o widget de tarefas

local task_open = wibox.widget { --  Criar um botão para abrir o widget de tarefas
    markup = maker.text(colors.fg, " Regular 14", ""), -- Texto do botão
    id = "txt", -- ID do botão
    font = settings.font .. " Regular 14", -- Fonte do botão
    align = "center", -- Alinhamento
    widget = wibox.widget.textbox, -- Widget para exibir o texto
    buttons = { -- Botões
        awful.button({}, 1, function() -- Botão esquerdo
            awesome.emit_signal("widget::task") -- Emitir o sinal de exibição do widget de tarefas
            --dock.visible = not dock.visible
        end)
    }
}

local main = wibox.widget {                     -- Criar um widget para exibir o widget de tarefas
    widget = wibox.container.background,        -- Widget para exibir o widget
    bg = colors.transparent,                    -- Cor de fundo
    shape = maker.radius(6),                    -- Forma do widget
    {
        layout = wibox.layout.fixed.horizontal, -- Layout
        task,                                   -- Widget de tarefas
        maker.margins(task_open, 5, 5, 0, 0)    -- Adicionar margens
    }
}

awesome.connect_signal("widget::task", function() -- Quando o widget de tarefas for exibido
    if not task.visible then -- Se o widget de tarefas estiver oculto
        task.visible = true -- Exibir o widget de tarefas
        task_open.markup = maker.text(colors.fg, " Regular 14", "") -- Alterar o texto do botão
    else -- Se o widget de tarefas estiver visível
        task.visible = false -- Ocultar o widget de tarefas
        task_open.markup = maker.text(colors.fg, " Regular 14", "") -- Alterar o texto do botão
    end
end)

awesome.connect_signal("change::theme", function() -- Quando o tema mudar
    main:set_bg(colors.transparent) -- Definir o fundo do widget
    if not task.visible then -- Se o widget de tarefas estiver oculto
        task_open:set_markup(maker.text(colors.fg, " Regular 14", "")) -- Alterar o texto do botão
    else -- Se o widget de tarefas estiver visível
        task_open:set_markup(maker.text(colors.fg, " Regular 14", "")) -- Alterar o texto do botão
    end
end)

return main -- Retornar o widget
