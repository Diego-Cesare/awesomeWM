local function load_colors()
  local colors = {}
  if settings.theme == "dark" then
    colors = {
      bg = "#14171f",
      fg = "#f6f6f4",
      alt_bg = "#282a33",
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
      bg = "#f8f9fa",
      fg = "#414868",
      alt_bg = "#ffffff",
      black = "#e1e2e7",
      white = "#212128",
      red = "#e78895",
      green = "#57A6A1",
      yellow = "#dfb25c",
      orange = "#F97300",
      blue = "#1679AB",
      magenta = "#FF8DC7",
      purple = "#B2A4FF",
      cyan = "#8CABFF",
      gray = "#c7c7c7",
      transparent = "#ffffff00",
    }
  end

  return colors
end

awesome.connect_signal("change::theme", function()
  local colors = load_colors()
  awesome.emit_signal('theme::colors', colors)
end)

return load_colors()
