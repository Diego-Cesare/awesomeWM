anime = {}

anime.scroll = function(widget, size, speed, fps)
    return wibox.widget({
        widget,
        layout = wibox.container.scroll.horizontal,
        max_size = size,
        step_function = wibox.container.scroll.step_functions
            .nonlinear_back_and_forth,
        speed = speed,
        fps = fps
    })
end

function anime.open(widget, time, in_size, fin_size)
    local timed = rubato.timed({
        duration = time,
        rate = 100,
        intro = 1 / 60,
        override_dt = true,
        easing = rubato.easing.bounce,
        pos = in_size,
        subscribed = function(pos) widget.forced_width = dpi(pos) end
    })
    timed.target = fin_size
end

function anime.close(widget, time, in_size, fin_size)
    local timed = rubato.timed({
        duration = time,
        rate = 100,
        intro = 1 / 13,
        override_dt = true,
        easing = rubato.easing.bounce,
        pos = fin_size,
        subscribed = function(pos) widget.forced_width = dpi(pos) end
    })
    timed.target = in_size
end

function anime.move(widget, final)
    local screen_geometry = widget.screen.geometry
    local target_x = (screen_geometry.width - widget:geometry().width) / 2
    local target_y = (screen_geometry.height - widget:geometry().height) / final

    widget:geometry({ y = -widget:geometry().height / 2 })

    local slide = rubato.timed {
        pos = -widget:geometry().height,
        rate = 60,
        intro = 1 / 60,
        duration = 0.5,
        easing = rubato.quadratic,
        subscribed = function(pos)
            widget:geometry({ y = pos, x = target_x })
            widget:struts { top = 0, bottom = 0, left = 0, right = 0 }
        end
    }

    slide.target = target_y
end

function anime.move_up(widget, start_y, end_y)
    local screen_geometry = widget.screen.geometry
    local widget_geometry = widget:geometry()
    local target_x = (screen_geometry.width + widget_geometry.width) / 2 +
        start_y

    -- Atribuir a posição inicial do widget
    widget:geometry({ y = start_y, x = target_x })

    local slide = rubato.timed {
        pos = start_y,
        rate = 60,
        intro = 1 / 60,
        duration = 0.3,
        easing = rubato.quadratic,
        subscribed = function(pos)
            widget:geometry({ y = pos, x = target_x })
            widget:struts { top = 0, bottom = 0, left = 0, right = 0 }
        end
    }

    slide.target = end_y
end

function anime.move_down(widget, from)
    local screen_geometry = widget.screen.geometry
    local widget_geometry = widget:geometry()
    local target_x = (screen_geometry.width - widget_geometry.width) / 2
    local original_y = widget_geometry.y
    local off_screen_y = screen_geometry.height - from

    widget:geometry({ y = original_y, x = target_x })

    local slide = rubato.timed {
        pos = original_y,
        rate = 60,
        intro = 1 / 60,
        duration = 0.3,
        easing = rubato.quadratic,
        subscribed = function(pos)
            widget:geometry({ y = pos, x = target_x })
            widget:struts { top = 0, bottom = 0, left = 0, right = 0 }
        end
    }

    slide.target = off_screen_y
end

function anime.move_x(widget, final_x, final_y, direction)
    local screen_geometry = widget.screen.geometry
    local target_y = (screen_geometry.height - widget:geometry().height) / 2 +
        final_y

    -- Determinar a posição inicial com base na direção
    local start_x
    if direction == "left" then
        start_x = -widget:geometry().width
    elseif direction == "right" then
        start_x = screen_geometry.width
    end

    widget:geometry({ x = start_x })

    local slide = rubato.timed {
        pos = start_x,
        rate = 60,
        intro = 0.04,
        duration = 0.4,
        easing = rubato.quadratic,
        subscribed = function(pos)
            widget:geometry({ x = pos, y = target_y })
        end
    }

    slide.target = final_x
end

function anime.move_x_out(widget, final_x, final_y, direction)
    local screen_geometry = widget.screen.geometry
    local start_x = widget:geometry().x -- Posição atual do widget
    local target_y = (screen_geometry.height - widget:geometry().height) / 2 +
        final_y

    local end_x
    if direction == "left" then
        end_x = -widget:geometry().width
    elseif direction == "right" then
        end_x = screen_geometry.width
    end

    local slide = rubato.timed {
        pos = start_x,
        rate = 60,
        intro = 0.04,
        duration = 0.8,
        easing = rubato.quadratic,
        subscribed = function(pos)
            widget:geometry({ x = pos, y = target_y })
        end
    }

    slide.target = final_x - end_x
end

return anime
