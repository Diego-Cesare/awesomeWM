local json = require("json")

-- URL da API CoinGecko para obter as cotações
local api_url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd,eur"

-- Cria o widget de cotações
local cotacoes_widget = wibox.widget {
  {
    id = "cotacoes",
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
    font = "Monospace 12"
  },
  layout = wibox.container.margin(_, 10, 10, 10, 10),
}

-- Função para atualizar as cotações
local function atualizar_cotacoes()
  awful.spawn.easy_async_with_shell("curl -s '" .. api_url .. "'", function(stdout)
    local data = json.decode(stdout)
    if not data then
      cotacoes_widget:get_children_by_id("cotacoes")[1]:set_text("Erro ao obter cotações")
    else
      local bitcoin_usd = data.bitcoin.usd
      local bitcoin_eur = data.bitcoin.eur
      local cotacoes_text = string.format("BTC: $%s / €%s", bitcoin_usd, bitcoin_eur)
      cotacoes_widget:get_children_by_id("cotacoes")[1]:set_text(cotacoes_text)
    end
  end)
end

-- Atualiza as cotações a cada 60 segundos
gears.timer {
  timeout = 60,
  autostart = true,
  callback = atualizar_cotacoes
}

-- Atualiza as cotações na inicialização
atualizar_cotacoes()

return cotacoes_widget
