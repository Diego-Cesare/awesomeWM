local image_dir = os.getenv("HOME") .. "/Imagens"
local wallpaper_path_file = gears.filesystem.get_cache_dir() .. "/current_wallpaper.txt"

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
            gears.wallpaper.set(colors.transparent)
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
for i = 1, 1 do
    local widget = wibox.widget({
        widget = wibox.container.background,
        bg = "#00000000",
        border_color = colors.fg,
        shape = maker.radius(0),
        {
            id = "image",
            widget = wibox.widget.imagebox,
            forced_width = dpi(80),
            forced_height = dpi(100),
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
    bg = colors.black,
    border_color = colors.fg,
    forced_width = dpi(15),
    forced_height = dpi(50),
    --shape = gears.shape.circle,
    {
        widget = wibox.widget.textbox,
        align = "center",
        id = "next",
        markup = maker.text(colors.fg, "Regular 10", "")
    }
})

local prev_image = wibox.widget({
    widget = wibox.container.background,
    bg = colors.black,
    border_color = colors.fg,
    forced_width = dpi(15),
    forced_height = dpi(50),
    --shape = gears.shape.circle,
    {
        widget = wibox.widget.textbox,
        id = "prev",
        align = "center",
        markup = maker.text(colors.fg, "Regular 10", "")
    }
})

awesome.connect_signal("theme::colors", function(colors)
    next_image:set_bg(colors.black)
    prev_image:set_bg(colors.black)
    next_image:get_children_by_id("next")[1]:set_markup(maker.text(colors.fg, "Regular 10", ""))
    prev_image:get_children_by_id("prev")[1]:set_markup(maker.text(colors.fg, "Regular 10", ""))
end)


maker.hover(next_image, colors.orange, colors.black, 2)
maker.hover(prev_image, colors.orange, colors.black, 2)

local function update_images()
    for i = 1, 1 do
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
    layout = wibox.layout.fixed.horizontal,
    table.unpack(image_widgets),
})

prev_image:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        start_image = start_image - 1
        if start_image < 1 then
            start_image = #images
        end
        update_images()
    end
end)

next_image:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        start_image = start_image + 1
        if start_image > #images then
            start_image = 1
        end
        update_images()
    end
end)

local wall = maker.image(icons.wallpaper, colors.transparent, 3, 0, "image_icon")

awesome.connect_signal("theme::icons", function(icons)
    wall:get_children_by_id("image_icon")[1]:set_image(icons.wallpaper)
end)

wall:buttons(gears.table.join(
    awful.button({}, 1, nil, function()
        wallpapers.visible = not wallpapers.visible
    end)
))

local description = wibox.widget({
    widget = wibox.widget.textbox,
    markup = maker.text(colors.fg, "Bold 9", "Selecionar ou")
})

local description_all = wibox.widget({
    widget = wibox.widget.textbox,
    markup = maker.text(colors.fg, "Bold 9", "Mostrar mais")
})

awesome.connect_signal("theme::colors", function(colors)
    description:set_markup(maker.text(colors.fg, "Bold 9", "Selecionar ou"))
    description_all:set_markup(maker.text(colors.fg, "Bold 9", "Mostrar mais"))
end)

local description_box = wibox.widget({
    widget = wibox.container.place,
    valign = "center",
    {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(2),
        description,
        description_all,
    },
})

wall:connect_signal("mouse::enter", function()
    description_all.markup = maker.text(colors.orange, "Bold 9", "Mostrar mais")
end)

wall:connect_signal("mouse::leave", function()
    description_all.markup = maker.text(colors.fg, "Bold 9", "Mostrar mais")
end)

local main_papers = wibox.widget({
    layout = wibox.layout.align.horizontal,
    expand = "none",
    {
        widget = wibox.container.place,
        valign = "center",
        halign = "left",
        maker.margins(prev_image, 0, 0, 0, 0),
    },
    maker.margins(image_container, 0, 0, 0, 0),
    {
        widget = wibox.container.place,
        valign = "center",
        halign = "right",
        maker.margins(next_image, 0, 0, 0, 0),
    },
})

local widgets_left = { wall, maker.margins(description_box, 10, 0, 0, 0) }
local widgets_right = { main_papers }

local wallpapers = wibox.widget({
    layout = wibox.layout.align.horizontal,
    forced_width = dpi(330),
    visible = false,
    expand = "none",
    {
        widget = maker.horizontal_padding_box(0, 0, 0, 0, widgets_left),
    },
    nil,
    {
        widget = wibox.container.place,
        valign = "center",
        maker.horizontal_padding_box(0, 0, 0, 0, widgets_right),
    }
})

update_images()

local current_wallpaper = load_wallpaper_path()
if current_wallpaper and gears.filesystem.file_readable(current_wallpaper) then
    set_wallpaper(current_wallpaper)
end

return wallpapers
