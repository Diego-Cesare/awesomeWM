local notifications = {}               -- Criar um objeto para guardar as funções

notifications.silent = false           -- Definir o modo silencioso

function notifications:toggle_silent() -- Função para alternar o modo silencioso
    self.silent = not self.silent      -- Inverter o valor do modo silencioso
    if self.silent then                -- Se o modo silencioso estiver ativo
        naughty.suspend(self.silent)   -- Suspender as notificações
    else                               -- Se o modo silencioso estiver desativado
        naughty.resume()               -- Reativar as notificações
    end
end

return notifications -- Retornar as funções
