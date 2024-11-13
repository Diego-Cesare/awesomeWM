local image_dir = os.getenv("HOME") .. "/Imagens"
local wallpaper_path_file = gears.filesystem.get_cache_dir()  .. "/current_wallpaper.txt"

local function get_image_files()
  local files = {}
  local find_command = "find " .. image_dir .. " -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \\)"
  for file in io.popen(find_command):lines() do
    table.insert(files, file)
  end
  return files
end

local function save_wallpaper_path(path)
  local file = io.open(wallpaper_path_file, "w")
  if file then
    file:write(path)
    file:close()
  end
end

local function set_wallpaper(image_path)
  local function apply_wallpaper(s)
    if image_path then
      gears.wallpaper.maximized(image_path, s, true)
    else
      gears.wallpaper.set(colors.bg)
    end
  end

  screen.connect_signal("request::wallpaper", apply_wallpaper)

  for s in screen do
    apply_wallpaper(s)
  end

  save_wallpaper_path(image_path)
end

local function load_wallpaper_path()
  local file = io.open(wallpaper_path_file, "r")
  if file then
    local path = file:read("*all")
    file:close()
    return path
  end
  return nil
end

local images = get_image_files()
local start_image = 1
local selected_image = start_image

local image_widgets = {}
for i = 1, 9 do
  local widget = wibox.widget({
    widget = wibox.container.background,
    bg = "#00000000",
    border_color = colors.fg,
    shape = maker.radius(6),
    {
      id = "image",
      widget = wibox.widget.imagebox,
      forced_width = dpi(350),
      forced_height = dpi(150),
      valign = "center",
      halign = "center",
      horizontal_fit_policy = "cover",
      vertical_fit_policy = "cover",
      resize = true,
    },
    buttons = gears.table.join(
      awful.button({}, 1, function()
        selected_image = start_image + i - 1
        set_wallpaper(images[selected_image])
      end)
    ),
  })
  table.insert(image_widgets, widget)
end

local next_image = wibox.widget({
  widget = wibox.container.background,
  bg = colors.alt_bg,
  border_color = colors.fg,
  forced_width = dpi(60),
  forced_height = dpi(60),
  shape = gears.shape.circle,
  {
    widget = wibox.widget.textbox,
    align = "center",
    markup = maker.text(colors.fg, "Regular 20", "")
  }
})

local prev_image = wibox.widget({
  widget = wibox.container.background,
  bg = colors.alt_bg,
  border_color = colors.fg,
  forced_width = dpi(60),
  forced_height = dpi(60),
  shape = gears.shape.circle,
  {
    widget = wibox.widget.textbox,
    align = "center",
    markup = maker.text(colors.fg, "Regular 20", "")
  }
})

maker.hover(next_image, colors.orange, colors.alt_bg, 2)
maker.hover(prev_image, colors.orange, colors.alt_bg, 2)

local function update_images()
  for i = 1, 9 do
    local index = start_image + i - 1
    local image_widget = image_widgets[i]:get_children_by_id("image")[1]
    if index <= #images then
      image_widget.image = images[index]
      image_widget.image_path = images[index]
    else
      image_widget.image = nil
      image_widget.image_path = nil
    end
  end
end

local image_container = wibox.widget({
  layout          = wibox.layout.grid,
  homogeneous     = true,
  vertical_expand = true,
  spacing         = dpi(10),
  forced_num_cols = 3,
  forced_num_rows = 3,
  table.unpack(image_widgets),
})

prev_image:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    start_image = start_image - 9
    if start_image < 1 then
      start_image = #images
    end
    update_images()
  end
end)

next_image:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    start_image = start_image + 9
    if start_image > #images then
      start_image = 1
    end
    update_images()
  end
end)

local wallpapers = awful.popup({
  widget = wibox.container.background,
  ontop = true,
  bg = colors.transparent,
  visible = false,
  --type = "dock",
  placement = function(c)
    awful.placement.centered(c, { margins = { top = dpi(0), bottom = dpi(0), left = dpi(0), right = dpi(0) } })
  end,
  shape = maker.radius(28),
})

wallpapers:setup({
  widget = wibox.container.background,
  bg = colors.bg,
  shape = maker.radius(20),
  shape_border_color = colors.bg,
  shape_border_width = 10,
  {
    layout = wibox.layout.stack,
    stretch_horizontally = true,
    maker.margins(image_container, 50, 50, 10, 10),

    {
      widget = wibox.container.place,
      valign = "center",
      halign = "left",
      maker.margins(prev_image, 10, 0, 0, 0),
    },
    {
      widget = wibox.container.place,
      valign = "center",
      halign = "right",
      maker.margins(next_image, 0, 10, 0, 0),
    },
  },
})

update_images()

local current_wallpaper = load_wallpaper_path()
if current_wallpaper and gears.filesystem.file_readable(current_wallpaper) then
  set_wallpaper(current_wallpaper)
end

return wallpapers
