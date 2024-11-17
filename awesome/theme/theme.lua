local function load_colors()         -- Carregar as cores do tema
    local colors = {}                -- Criar um objeto para guardar as cores
    if settings.theme == "dark" then -- Se o tema for dark
        colors = {
            bg = "#050810" .. "A0",
            fg = "#f6f6f4",
            alt_bg = "#23262E" .. "A0",
            black = "#212121",
            white = "#f6f6f4",
            red = "#e78895",
            green = "#8ABFA3",
            yellow = "#dfb25c",
            orange = "#FFDBB5",
            blue = "#7EACB5",
            magenta = "#E7CCCC",
            purple = "#B2A4FF",
            cyan = "#AEE2FF",
            gray = "#c7c7c7",
            transparent = "#00000000",
        }
    elseif settings.theme == "light" then -- Se o tema for light
        colors = {
            bg = "#FFFFFF" .. "A0",
            fg = "#414868",
            alt_bg = "#F5F5F5" .. "A0",
            black = "#e1e2e7",
            white = "#212128",
            red = "#FF8A8A",
            green = "#658147",
            yellow = "#dfb25c",
            orange = "#FF7777",
            blue = "#667BC6",
            magenta = "#DA7297",
            purple = "#B2A4FF",
            cyan = "#8CABFF",
            gray = "#c7c7c7",
            transparent = "#ffffff00",
        }
    elseif settings.theme == "gruvbox" then -- Se o tema for gruvbox
        colors = {
            bg = "#282828",
            fg = "#eddbb2",
            alt_bg = "#1d2021",
            black = "#282828",
            white = "#fbf1c7",
            red = "#fb4934",
            green = "#b8bb26",
            yellow = "#fabd2f",
            orange = "#fe8019",
            blue = "#83a598",
            magenta = "#d3869b",
            purple = "#b16286",
            cyan = "#8ec07c",
            gray = "#928374",
            transparent = "#ffffff00",
        }
    elseif settings.theme == "rosepine" then -- Se o tema for rosepine
        colors = {
            bg = "#191724",
            fg = "#e0def4",
            alt_bg = "#403d52",
            black = "#26233a",
            white = "#e0def4",
            red = "#eb6f92",
            green = "#31748f",
            yellow = "#f6c177",
            orange = "#ce800f",
            blue = "#9ccfd8",
            magenta = "#c4a7e7",
            purple = "#b16286",
            cyan = "#ebbcba",
            gray = "#6e6a86",
            transparent = "#ffffff00",
        }
    end

    return colors
end

awesome.connect_signal("change::theme", function() -- Quando o tema mudar
    local colors = load_colors()                   -- Carregar as cores do tema
    awesome.emit_signal("theme::colors", colors)   -- Emitir a cor do tema
end)

return load_colors() -- Retornar as cores do tema
