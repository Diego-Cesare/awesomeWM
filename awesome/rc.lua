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
require("configs.init") -- Configurações
require("settings") -- Configurações
require("utils.play") -- Módulo de reprodução
require("user.apps") -- Aplicativos
require("utils.maker") -- Módulo de criação de widgets
_G.colors = require("theme.theme") -- Tema
_G.icons = require("theme.icons") -- Ícones
_G.anime = require("utils.animations") -- Animações
_G.not_disturbed = require("utils.not_disturbed") -- Modo não perturbado
_G.launcher = require("widgets.launcher") -- Lançador
_G.info_center = require("widgets.control_center.main") -- Centro de controle
_G.notify_center = require("widgets.notify_center.notifications") -- Centro de notificações
_G.music_player = require("widgets.music_widget.music") -- Widget de música

require("widgets.bar.main") -- Barra

-- Gaps
beautiful.useless_gap = settings.gaps -- Gaps

-- Borders
beautiful.border_width = settings.border -- Tamanho dos bordos
beautiful.border_normal = colors.bg -- Cor do bordo normal
beautiful.border_focus = colors.bg -- Cor do bordo focado

awesome.connect_signal("change::theme", function() -- Conectar a função de alteração de tema
	beautiful.bg_systray = colors.bg -- Cor do fundo do ícone do sistema
end)

beautiful.systray_icon_spacing = 10 -- Espaçamento do ícone do sistema

awesome.emit_signal("change::theme") -- Emitir a função de alteração de tema
awesome.connect_signal("theme::colors", function(colors) -- Conectar a função de alteração de tema
	_G.colors = colors -- Alterar a cor do tema
end)
awesome.connect_signal("theme::icons", function(icons) -- Conectar a função de alteração de tema
	_G.icons = icons -- Alterar os ícones do tema
end)

collectgarbage("incremental", 150, 600, 0) -- Coleta de lixo
gears.timer.start_new(60, function() -- Iniciar o timer de coleta de lixo
	collectgarbage() -- Coleta de lixo
	return true -- Retornar verdadeiro para continuar o timer
end)
