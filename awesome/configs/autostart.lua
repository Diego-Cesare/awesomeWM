-- Função para executar um comando apenas uma vez
local function run_once(cmd)
	local findme = cmd
	local firstspace = cmd:find(" ")
	if firstspace then
		findme = cmd:sub(0, firstspace - 1)
	end
	awful.spawn.easy_async_with_shell(
		string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd),
		function(stdout, stderr)
			if stderr and #stderr > 0 then
				naughty.notification({
					app_name = "Start-up Applications",
					title = "<b>Eroo na inicialização de um aplicativo!</b>",
					message = stderr:gsub("%\n", ""),
					timeout = 20,
					icon = icons.warning,
				})
			end
		end
	)
end

-- Lista de aplicativos para iniciar
local apps = {
	-- "picom",
	"setxkbmap -model abnt2 -layout br -variant abnt2",
	"xsetroot -cursor_name left_ptr",
	"xset s off",
	"xset -dpms",
	"picom",
	-- "playerctld daemon",
	-- "nm-applet"
}

-- Executa cada aplicativo uma vez
for _, app in ipairs(apps) do
	run_once(app)
end
