local Gtk = lgi.require("Gtk", "3.0")

_G.maker = {}

maker.separtor = function(orientation, width, height, opacity, color)
    return wibox.widget({
        orientation = orientation,
        forced_width = width,
        forced_height = height,
        opacity = opacity,
        widget = wibox.widget.separator,
        color = color
    })
end

maker.button = function(icon, radius, app)
    return wibox.widget({
        widget = wibox.container.background,
        border_width = dpi(0),
        border_color = colors.fg,
        shape = maker.radius(radius),
        {
            widget = wibox.container.margin,
            margins = {
                top = dpi(10),
                bottom = dpi(10),
                left = dpi(10),
                right = dpi(10)
            },
            {
                widget = wibox.widget.imagebox,
                image = icon,
                forced_height = dpi(40),
                valign = "center",
                halign = "center",
                resize = true,
                id = "button",
                buttons = {awful.button({}, 1, function()
                    awful.spawn(app)
                end)}
            }
        }
    })
end

maker.hover = function(bnt, color_enter, color_out, border)
    return {
        bnt:connect_signal("mouse::enter", function()
            bnt.bg = color_enter
            bnt.border_width = dpi(border)
            bnt.border_color = beautiful.fg
        end), bnt:connect_signal("mouse::leave", function()
            bnt.bg = color_out
            bnt.border_width = dpi(0)
        end)
    }
end

maker.margins = function(item, l, r, t, b)
    return wibox.widget({
        item,
        widget = wibox.container.margin,
        left = dpi(l),
        right = dpi(r),
        top = dpi(t),
        bottom = dpi(b)
    })
end

maker.vertical_padding_box = function(l, r, t, b, widgets)
    local layout = wibox.layout.fixed.vertical()

    for _, widget in ipairs(widgets) do layout:add(widget) end

    return wibox.container.margin(layout, l, r, t, b)
end

maker.horizontal_padding_box = function(l, r, t, b, widgets)
    local layout = wibox.layout.fixed.horizontal()

    for _, widget in ipairs(widgets) do layout:add(widget) end

    return wibox.container.margin(layout, l, r, t, b)
end

function maker.text(color, font, text)
    return '<span color="' .. color .. '" font="' .. settings.font .. " " ..
               font .. '">' .. text .. "</span>"
end

function maker.radius(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

maker.image = function(image, bg, padding, r, id)
    return wibox.widget({
        widget = wibox.container.margin,
        margins = dpi(padding),
        {
            widget = wibox.container.background,
            bg = bg,
            shape = maker.radius(r),
            {
                widget = wibox.widget.imagebox,
                valign = "center",
                halign = "center",
                id = id,
                resize = true,
                image = image
            }
        }
    })
end

maker.clock = function(color, font, args)
    return wibox.widget({
        widget = wibox.widget.textclock,
        format = maker.text(color, settings.font .. " " .. font, args)
    })
end

-- Icons
maker.gtk_theme = Gtk.IconTheme.get_default()
maker.apps = Gio.AppInfo.get_all()

function maker.get_icon(client_name)
    if not client_name then return nil end

    local icon_info = maker.gtk_theme:lookup_icon(client_name, 64, 0)
    if icon_info then
        local icon_path = icon_info:get_filename()
        if icon_path then return icon_path end
    end

    return nil
end

function maker.get_newicon_path(newicon)
    if not newicon then return nil end

    local info = maker.gtk_theme:lookup_by_newicon(newicon, 64, 0)
    if info then return info:get_filename() end
end

return maker
