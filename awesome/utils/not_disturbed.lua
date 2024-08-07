local notifications = {}

notifications.silent = false

function notifications:toggle_silent()
    self.silent = not self.silent
    if self.silent then
        naughty.suspend(self.silent)
    else
        naughty.resume()
    end
end

return notifications
