local weather_images = os.getenv("HOME") .. "/.config/awesome/user/weather/"

local api_key = "your api key"
local city_id = "your city_id"
local cmd = "curl -s 'http://api.openweathermap.org/data/2.5/weather?id="
	.. city_id
	.. "&appid="
	.. api_key
	.. "&units=metric'"

local function get_icon_path(icon_code)
	local icon_map = {
		["01d"] = "01d.svg",
		["01n"] = "01n.svg",
		["02d"] = "02d.svg",
		["02n"] = "02n.svg",
		["03d"] = "03d.svg",
		["03n"] = "03n.svg",
		["04d"] = "04d.svg",
		["04n"] = "04n.svg",
		["09d"] = "09d.svg",
		["09n"] = "09n.svg",
		["10d"] = "10d.svg",
		["10n"] = "10n.svg",
		["11d"] = "11d.svg",
		["11n"] = "11n.svg",
		["13d"] = "13d.svg",
		["13n"] = "13n.svg",
		["50d"] = "50d.svg",
		["50n"] = "50n.svg",
	}
	return weather_images .. (icon_map[icon_code] or "unknown.png")
end

local city = wibox.widget({
	id = "city",
	widget = wibox.widget.textbox,
	font = settings.font .. " Regular 20",
})

local icon = wibox.widget({
	valign = "center",
	halign = "right",
	id = "icon",
	widget = wibox.widget.imagebox,
	image = get_icon_path("unknown"),
	forced_height = dpi(100),
	resize = true,
	opacity = 1,
})

local temperature = wibox.widget({
	id = "temperature",
	widget = wibox.widget.textbox,
	font = settings.font .. " Regular 11",
})

local condition = wibox.widget({
	id = "condition",
	widget = wibox.widget.textbox,
	font = settings.font .. " Regular 11",
})

local wind = wibox.widget({
	id = "wind",
	widget = wibox.widget.textbox,
	font = settings.font .. " Regular 11",
})

local function update_icon(widget)
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local icon_code = string.match(stdout, '"icon":"(.-)"')
		widget:get_children_by_id("icon")[1].image = get_icon_path(icon_code)
	end)
end

local function update_temperature(widget)
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local temp = string.match(stdout, '"temp":(%-?%d+%.?%d*)')
		widget:get_children_by_id("temperature")[1]:set_text("Temp: " .. math.ceil(temp) .. "°C")
		widget:get_children_by_id("temperature")[1]:set_markup(
			string.format(
				"<span color='%s'>%s</span>",
				colors.fg,
				widget:get_children_by_id("temperature")[1]:get_text()
			)
		)
		awesome.connect_signal("change::theme", function(c)
			widget:get_children_by_id("temperature")[1]:set_text("Temp: " .. math.ceil(temp) .. "°C")
			widget:get_children_by_id("temperature")[1]:set_markup(
				string.format(
					"<span color='%s'>%s</span>",
					colors.fg,
					widget:get_children_by_id("temperature")[1]:get_text()
				)
			)
		end)
	end)
end

local function update_condition(widget)
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local description = string.match(stdout, '"description":"(.-)"')
		description = description and description:gsub("^%l", string.upper) or "N/A"
		widget:get_children_by_id("condition")[1]:set_text(description)
		widget:get_children_by_id("condition")[1]:set_markup(
			string.format("<span color='%s'>%s</span>", colors.fg, widget:get_children_by_id("condition")[1]:get_text())
		)
		awesome.connect_signal("change::theme", function(c)
			widget:get_children_by_id("condition")[1]:set_text(description)
			widget:get_children_by_id("condition")[1]:set_markup(
				string.format(
					"<span color='%s'>%s</span>",
					colors.fg,
					widget:get_children_by_id("condition")[1]:get_text()
				)
			)
		end)
	end)
end

local function update_wind(widget)
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local description = string.match(stdout, '"speed":(%-?%d+%.?%d*)')
		description = math.ceil(description) or "N/A"
		widget:get_children_by_id("wind")[1]:set_text("Vento: " .. (description * 3.6) .. " Km/h")
		widget:get_children_by_id("wind")[1]:set_markup(
			string.format("<span color='%s'>%s</span>", colors.fg, widget:get_children_by_id("wind")[1]:get_text())
		)
		awesome.connect_signal("change::theme", function(c)
			widget:get_children_by_id("wind")[1]:set_text("Vento: " .. (description * 3.6) .. " Km/h")
			widget:get_children_by_id("wind")[1]:set_markup(
				string.format("<span color='%s'>%s</span>", colors.fg, widget:get_children_by_id("wind")[1]:get_text())
			)
		end)
	end)
end

local function get_city(widget)
	awful.spawn.easy_async_with_shell(cmd, function(stdout)
		local description = string.match(stdout, '"name":"(.-)"')
		description = description and description:gsub("^%l", string.upper) or "N/A"
		widget:get_children_by_id("city")[1]:set_text(" " .. description)
		widget:get_children_by_id("city")[1]:set_markup(
			string.format("<span color='%s'>%s</span>", colors.fg, widget:get_children_by_id("city")[1]:get_text())
		)
		awesome.connect_signal("change::theme", function(c)
			widget:get_children_by_id("city")[1]:set_text(" " .. description)
			widget:get_children_by_id("city")[1]:set_markup(
				string.format("<span color='%s'>%s</span>", colors.fg, widget:get_children_by_id("city")[1]:get_text())
			)
		end)
	end)
end

update_icon(icon)
update_temperature(temperature)
update_condition(condition)
update_wind(wind)
get_city(city)

gears.timer({
	timeout = 3600,
	autostart = true,
	call_now = true,
	callback = function()
		update_icon(icon)
		update_temperature(temperature)
		update_condition(condition)
		update_wind(wind)
		get_city(city)
	end,
})

local weather_info = wibox.widget({
	widget = wibox.container.place,
	halign = "left",
	{
		layout = wibox.layout.fixed.vertical,
		expand = "none",
		maker.margins(city, 0, 0, 0, 10),
		temperature,
		wind,
	},
})

local weather_info_icon = wibox.widget({
	widget = wibox.container.place,
	halign = "right",
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		icon,
		nil,
		condition,
	},
})

local main_weather = wibox.widget({
	widget = wibox.container.background,
	bg = colors.blue .. "70",
	forced_width = dpi(180),
	forced_height = dpi(200),
	shape = maker.radius(6),
	{
		layout = wibox.layout.align.vertical,
		expand = "none",
		maker.margins(weather_info, 10, 0, 10, 0),
		nil,
		maker.margins(weather_info_icon, 0, 10, 0, 10),
	},
})

return main_weather
