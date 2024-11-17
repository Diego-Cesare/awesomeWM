require("widgets.bar.carrosel.init") -- Carrosel

local mouse_over = false             -- Mouse sobre o carrosel
local animating = false              -- Animação em andamento
local animation_timer = nil          -- Timer de animação

local function animate_widget(widget, target_opacity, callback)
    local current_opacity = widget.opacity or 1 -- Opacidade atual do widget
    local duration = 0.5                        -- Duração da animação
    local step = 0.05                           -- Passo da animação
    local alpha_step = step / duration          -- Passo da animação para a opactidade

    animation_timer = gears.timer.start_new(step, function()
        if mouse_over then                  -- Se o mouse está sobre o carrosel
            widget.opacity = 1              -- Opacidade do widget
            animation_timer:stop()          -- Parar o timer
            if callback then callback() end -- Executar callback
            return false                    -- Retornar falso para interromper a animação
        end

        if current_opacity < target_opacity then -- Se a opactidade atual é menor que a opactidade alvo
            current_opacity = math.min(current_opacity + alpha_step, target_opacity)
        else
            current_opacity = math.max(current_opacity - alpha_step,
                target_opacity)
        end

        widget.opacity = current_opacity          -- Atualizar a opactidade do widget

        if current_opacity == target_opacity then -- Se a opactidade atual é igual a opactidade alvo
            animation_timer:stop()                -- Parar o timer
            if callback then callback() end       -- Executar callback
            return false                          -- Retornar falso para interromper a animação
        end

        return true -- Retornar verdadeiro para continuar a animação
    end)
end

local function carrosel()                                -- Carrosel
    if not mouse_over and not animating then             -- Se o mouse não está sobre o carrosel e a animação não está em andamento
        animating = true                                 -- Iniciar a animação
        if userbox.visible then                          -- Se o widget de usuário estiver visível
            animate_widget(userbox, 0, function()        -- Animar o widget de usuário
                userbox.visible = false                  -- Ocultar o widget de usuário
                weatherbox.opacity = 0                   -- Opacidade do widget de clima
                weatherbox.visible = true                -- Ocultar o widget de clima
                animate_widget(weatherbox, 1, function() -- Animar o widget de clima
                    animating = false                    -- Parar a animação
                end)
            end)
        elseif weatherbox.visible then                -- Se o widget de clima estiver visível
            animate_widget(weatherbox, 0, function()  -- Animar o widget de clima
                weatherbox.visible = false            -- Ocultar o widget de clima
                userbox.opacity = 0                   --  Opacidade do widget de usuário
                userbox.visible = true                -- Ocultar o widget de usuário
                animate_widget(userbox, 1, function() -- Animar o widget de usuário
                    animating = false                 -- Parar a animação
                end)
            end)
        end
    end
end

gears.timer {           -- Iniciar o timer de carrosel
    timeout = 10,       -- Tempo de espera
    call_now = true,    -- Chamar agora
    autostart = true,   --  Iniciar automaticamente
    callback = carrosel -- Callback
}

local widgets_box = { userbox, weatherbox }                              -- Widgets do carrosel

local main = wibox.widget({                                              -- Carrosel
    widget = wibox.container.background,                                 -- Widget de fundo
    forced_width = dpi(350),                                             -- Largura fixa
    bg = colors.transparent,                                             -- Cor de fundo transparente
    shape = maker.radius(6),                                             -- Forma de arredondamento
    { widget = maker.horizontal_padding_box(20, 20, 0, 0, widgets_box) } -- Widgets do carrosel
})

awesome.connect_signal("theme::colors",                   -- Conectar a função de alteração de tema
    function(colors) main:set_bg(colors.transparent) end) -- Alterar a cor de fundo do carrosel

return main                                               -- Retornar o carrosel
