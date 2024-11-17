local hours = maker.clock(colors.blue, "Regular 10", "%H:%M") -- Horário
local weeks = maker.clock(colors.fg, "Regular 9", "%A,")      -- Dia da semana
local days = maker.clock(colors.fg, "Regular 9", "%d")        -- Dia da semana
local months = maker.clock(colors.fg, "Regular 9", "%B")      -- Mês

local main_clock = wibox.widget({
    widget = wibox.container.place,                            -- Centraliza os widgets
    align = "center",                                          -- Alinha os widgets
    {
        widget = wibox.container.margin,                       -- Adiciona margens ao widget
        margins = { right = dpi(0) },                          -- Margens
        {
            layout = wibox.layout.align.vertical,              -- Alinha os widgets verticalmente
            expand = "none",                                   -- Expande os widgets
            { layout = wibox.layout.fixed.horizontal, hours }, -- Adiciona os widgets
            nil,                                               -- Separador
            {
                layout = wibox.layout.fixed.horizontal,        -- Alinha os widgets
                spacing = dpi(2),                              -- Espaçamento
                weeks,                                         -- Dia da semana
                days,                                          -- Dia da semana
                months                                         -- Mês
            }
        }
    }
})

awesome.connect_signal("change::theme", function()
    hours.format = maker.text(colors.blue, "Regular 10", "%H:%M") -- Horário formatado com o tema atual
    weeks.format = maker.text(colors.fg, "Regular 9", "%A,")      -- Dia da semana formatado com o tema atual
    days.format = maker.text(colors.fg, "Regular 9", "%d")        -- Dia da semana formatado com o tema atual
    months.format = maker.text(colors.fg, "Regular 9", "%B")      --  Mês formatado com o tema atual
end)

return main_clock -- Retorna o widget
