-- █▀▄ █▀▀ █▀▀ ▄▀█ █░█ █░░ ▀█▀   █░░ █ █▄▄ █▀
-- █▄▀ ██▄ █▀░ █▀█ █▄█ █▄▄ ░█░   █▄▄ █ █▄█ ▄█
_G.gears = require("gears")
_G.awful = require("awful")
_G.wibox = require("wibox")
_G.lgi = require("lgi")
_G.Gio = require("lgi").Gio
_G.cairo = require("lgi").cairo
_G.beautiful = require("beautiful")
_G.naughty = require("naughty")
_G.ruled = require("ruled")
_G.menubar = require("menubar")
_G.hotkeys_popup = require("awful.hotkeys_popup")
_G.dpi = beautiful.xresources.apply_dpi
_G.rubato = require("modules.rubato")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
pcall(require, "luarocks.loader")


-- █░█ █▀ █▀▀ █▀█   █▀▀ █ █░░ █▀▀ █▀
-- █▄█ ▄█ ██▄ █▀▄   █▀░ █ █▄▄ ██▄ ▄█
require("configs.init")
require("settings")
require("utils.play")
require("user.apps")
require("utils.maker")

_G.colors = require("theme.theme")
_G.icons = require("theme.icons")
_G.anime = require("utils.animations")
_G.not_disturbed = require("utils.not_disturbed")
_G.launcher = require("widgets.launcher")
_G.info_center = require("widgets.control_center.main")
_G.notify_center = require("widgets.notify_center.notifications")
_G.music_player = require("widgets.music_widget.music")

require("widgets.bar.main")

-- Gaps
beautiful.useless_gap = settings.gaps

-- Borders
beautiful.border_width = settings.border
beautiful.border_normal = colors.bg
beautiful.border_focus = colors.bg

awesome.connect_signal("change::theme", function()
    beautiful.bg_systray = colors.bg
end)
beautiful.systray_icon_spacing = 10

awesome.emit_signal("change::theme")
awesome.connect_signal('theme::colors', function(colors)
    _G.colors = colors
end)
awesome.connect_signal('theme::icons', function(icons)
    _G.icons = icons
end)

collectgarbage("incremental", 150, 600, 0)
gears.timer.start_new(60, function()
    collectgarbage()
    return true
end)
