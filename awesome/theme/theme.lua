local function load_colors()
    local colors = {}
    if settings.theme == "dark" then
        colors = {
            bg = "#050810" .. "A0",
            fg = "#f6f6f4",
            alt_bg = "#23262E" .. "A0",
            black = "#212121",
            white = "#f6f6f4",
            red = "#e78895",
            green = "#afd198",
            yellow = "#dfb25c",
            orange = "#FF8787",
            blue = "#1679AB",
            magenta = "#FF8DC7",
            purple = "#B2A4FF",
            cyan = "#AEE2FF",
            gray = "#c7c7c7",
            transparent = "#00000000",
        }
    elseif settings.theme == "light" then
        colors = {
            bg = "#f8f9fa" .. "A0",
            fg = "#414868",
            alt_bg = "#ffffff" .. "A0",
            black = "#e1e2e7",
            white = "#212128",
            red = "#B03052",
            green = "#219B9D",
            yellow = "#dfb25c",
            orange = "#FC8F54",
            blue = "#1679AB",
            magenta = "#CC2B52",
            purple = "#B2A4FF",
            cyan = "#8CABFF",
            gray = "#c7c7c7",
            transparent = "#ffffff00",
        }
    elseif settings.theme == "gruvbox" then
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
    elseif settings.theme == "rosepine" then
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

awesome.connect_signal("change::theme", function()
    local colors = load_colors()
    awesome.emit_signal("theme::colors", colors)
end)

return load_colors()
