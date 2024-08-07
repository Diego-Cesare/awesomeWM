require("widgets.bar.carrosel.init")

local mouse_over = false
local animating = false
local animation_timer = nil

local function animate_widget(widget, target_opacity, callback)
  local current_opacity = widget.opacity or 1
  local duration = 0.5
  local step = 0.05
  local alpha_step = step / duration

  animation_timer = gears.timer.start_new(step, function()
    if mouse_over then
      widget.opacity = 1
      animation_timer:stop()
      if callback then
        callback()
      end
      return false
    end

    if current_opacity < target_opacity then
      current_opacity = math.min(current_opacity + alpha_step, target_opacity)
    else
      current_opacity = math.max(current_opacity - alpha_step, target_opacity)
    end

    widget.opacity = current_opacity

    if current_opacity == target_opacity then
      animation_timer:stop()
      if callback then
        callback()
      end
      return false
    end

    return true
  end)
end

local function carrosel()
  if not mouse_over and not animating then
    animating = true
    if userbox.visible then
      animate_widget(userbox, 0, function()
        userbox.visible = false
        weatherbox.opacity = 0
        weatherbox.visible = true
        animate_widget(weatherbox, 1, function()
          animating = false
        end)
      end)
    elseif weatherbox.visible then
      animate_widget(weatherbox, 0, function()
        weatherbox.visible = false
        userbox.opacity = 0
        userbox.visible = true
        animate_widget(userbox, 1, function()
          animating = false
        end)
      end)
    end
  end
end

gears.timer {
  timeout = 10,
  call_now = true,
  autostart = true,
  callback = carrosel
}

local widgets_box = { userbox, weatherbox }

local main = wibox.widget({
  widget = wibox.container.background,
  forced_width = dpi(350),
  bg = colors.transparent,
  shape = maker.radius(6),
  {
    widget = maker.horizontal_padding_box(20, 20, 10, 10, widgets_box)
  }
})

awesome.connect_signal("theme::colors", function(colors)
  main:set_bg(colors.transparent)
end)

return main
