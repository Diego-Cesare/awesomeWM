local dock = require("widgets.bar.modules.dock")          -- Carregar os módulos de aplicativos
local tools = require("widgets.bar.modules.tools")        -- Carregar os módulos de ferramentas
local dynamic = require("widgets.bar.dynamic.dynamic")    -- Carregar os módulos dinâmicos
local tray = require("widgets.bar.modules.tray")          -- Carregar os módulos de tray
local task = require("widgets.bar.modules.task")          -- Carregar os módulos de tarefas
local carrosel = require("widgets.bar.carrosel.carrosel") -- Carregar os módulos de carrosel

-- Calcula o tamanho dos widgets da barra
local box_height = settings.bar_height / 100 * 18

-- Cria um separador
local sep = maker.margins(maker.separtor(vertical, 1, 1, 0.5, colors.green), 10, 10, 5, 5)

local left_itens = { tools, sep, task, sep, dock }                                    -- Widgets da barra esquerda
local center_itens = { nil }                                                          -- Espaço vazio ao centro da barra
local right_itens = { carrosel, sep, dynamic, sep, maker.margins(tray, 10, 5, 0, 0) } -- Widgets da barra direita

-- Barra principal
local main = awful.wibar({                                                                     -- Criar uma barra
    stretch = false,                                                                           -- Não esticar
    position = settings.bar_position,                                                          -- Posição da barra
    height = settings.bar_height,                                                              -- Altura da barra
    width = settings.bar_width,                                                                -- Largura da barra
    type = "dock",                                                                             -- Tipo da barra
    bg = colors.bg,                                                                            -- Cor de fundo
    shape = maker.radius(settings.bar_radius),                                                 -- Forma da barra
    opacity = 1,                                                                               -- Opacidade da barra
    ontop = true,                                                                              -- Colocar a barra acima
    visible = true,                                                                            -- Exibir a barra
    widget = {                                                                                 -- Widget da barra
        layout = wibox.layout.align.horizontal,                                                -- Layout
        expand = "none",                                                                       -- Expandir
        { widget = maker.horizontal_padding_box(5, 0, box_height, box_height, left_itens) },   -- Widget esquerda
        { widget = maker.horizontal_padding_box(0, 0, box_height, box_height, center_itens) }, -- Espaço vazio
        { widget = maker.horizontal_padding_box(0, 5, box_height, box_height, right_itens) },  -- Widget direita
    },
})

local main_geometry = main:geometry()                   -- Geometria da barra
local main_y_position = main_geometry.y                 -- Posição da barra
local screen_geometry = awful.screen.focused().geometry -- Geometria da tela

-- Define as magens da barra de acordo com a posição
if settings.bar_position == "top" then
    position_y = main_y_position + 10 -- Define a posição da barra na Posição top
elseif settings.bar_position == "bottom" then
    position_y = main_y_position - 10 -- Define a posição da barra na Posição bottom
end

if settings.bar_floating then          -- Se a barra estiver flutuando
    main.y = position_y                -- Define a posição da barra
else                                   -- Se a barra estiver fixa
    main.y = main_y_position           -- Define a posição da barra
    main.width = screen_geometry.width -- Define a largura da barra
    main.shape = maker.radius(0)       -- Define a forma da barra
end

local function is_floating()                           -- Função para verificar se a barra está flutuando
    if settings.bar_floating then                      -- Se a barra estiver flutuando
        main.y = position_y                            -- Define a posição da barra
        main.width = screen_geometry.width             -- Define a largura da barra
        main.shape = maker.radius(0)                   -- Define a forma da barra
        settings.bar_floating = false                  -- Define a barra como fixa
    else                                               -- Se a barra estiver fixa
        main.width = settings.bar_width                -- Define a largura da barra
        main.shape = maker.radius(settings.bar_radius) -- Define a forma da barra
        settings.bar_floating = true                   -- Define a barra como flutuante
        main.y = position_y                            -- Define a posição da barra
    end
end

awesome.connect_signal("float::bar", function() -- Quando a barra for flutuante
    is_floating()                               -- Define a barra como flutuante
end)

local function update_ontop(c)      -- Função para atualizar a posição da barra
    main.visible = not c.fullscreen -- Se a barra estiver flutuante e o cliente estiver em tela cheia, esconde a barra
end

client.connect_signal("property::fullscreen", update_ontop) -- Conectar o sinal de atualização da posição da barra

awesome.connect_signal("change::theme", function(c)         -- Quando o tema mudar
    main:set_bg(colors.bg)                                  -- Definir o fundo da barra
end)
