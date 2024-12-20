local icon =
    '<svg width="64" height="64" version="1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><defs><linearGradient id="a" x1="30" x2="30" y1="8" y2="27" gradientUnits="userSpaceOnUse"><stop stop-color="#dbdbdb" offset="0"/><stop stop-color="#b2b2b2" offset="1"/></linearGradient></defs><rect x="13" y="6" width="38" height="24" rx="4" ry="4" fill="url(#a)" style="paint-order:markers stroke fill"/><rect x="6" y="23" width="52" height="35" rx="6" ry="6" fill="#4d4d4d"/><circle cx="47" cy="47" r="16" fill="#47a6f5"/><rect x="18" y="14" width="9" height="5" rx="1" ry="1" opacity=".35" style="paint-order:stroke fill markers"/><rect x="37" y="14" width="9" height="5" rx="1" ry="1" opacity=".35" style="paint-order:stroke fill markers"/><image x="31" y="31" width="32" height="32" preserveAspectRatio="none" xlink:href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAA7DAAAOwwHHb6hkAAAA GXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAydJREFUWIXFlr9u40YQxr/ZXZHU hbrzJRAuThcbMA65wp2BwzVGUqlQyffR+7Bw6ZYvcMA1FlyocOPmaAe6mDL/7eykMKnEOiuW5cj6 gAUoaLjfb4bc4RBWVBRFOsuyXaXUO2PMW2buEVGHiJSI1EQ0c859M8Z8nU6nl0mSFKvsS48FDIfD VwDeA/gVgLfSpkTCzJee541PTk6u1wWg4XD4G4APAPQqxosQIuJE5KLb7X6J47haGSCKIq8sy08i 8vNTjRcBiMiKyDQIgs9xHH9bjPsusyiKwqIo/gDw07rmDQAACBE5InLW2t7+/v5fk8mkXArQZP47 gNfPMV8EAFA75ypjjN7b28smkwm3cerf9xRF8VFEnm2+TCJCQRC8GY1Gc9/5RfPC/bIp81ZlWaqz szP/HkBz1D5s2rxVmqa6rUJbgfdY46g9R0mS3AFEUaRx12ReVDc3NwQAKsuyXazY4TYgUkqpd1sy BwAorfWPWwVwzoVbBcD2nv8dgFLq0U/yRgFEpN4qAIDblzAiInkQQESmL2VMRGKMuQeijDFfNwnA zGBmISLRWovWWjzPk16vJwCgptPp5bLyPFdEJETktNbujoVdURTi+37rJypJkoKZL5vg/20186AD wAAsABYRDsOQgyCQfr8vAGAAwPO8cV3Xa88CixVsfjsiqpm5BlAqpUprbQ2Asyxzp6enDmg+wefn 5/nBwcEPSqmwneHWWSLCAFyTce2cqwDcaq1vrbWzIAjy6+vrylpbX1xcuHkFAKDb7X4piiIkorU7 o1IKzCxKKQfAGmNKEcm11jMAuTGmBGCTJJnPhPMhZDwe8+Hh4Z/W2p5zrhKR8qkLQKGUKgDkAHIR mVlrZ0R0y8x5p9Mpj46OqiRJ/jmai1kMBoPXnU5nV0Se3KLbo8bMTkTYWlsHQVA1mVcAqjiO+d49 D200GAz8IAjelGWpHvp/mdomU9e1C8OQAXCapgzAHh8fV6PRyH0H/R/7qSiK/DRNnzQrep4nvu/L 1dWV7OzsuDzPuXnmD/aaR8s8Go1UkiSqneEeU9vh+v2+xHHslhmvDLBm/Mqd9W/9keaatb5HpwAA AABJRU5ErkJggg=="/><path d="m47 34-6 16 7-1-1 11 6-15-7 1z" fill="#fff"/></svg>'
local function notify_usb_action(action)
    local message
    if action == "add" then
        message = "USB conectado."
    elseif action == "remove" then
        message = "USB removido."
    end
    if message then
        naughty.notify({
            app_name = "Sistema",
            title = "Dispositivo USB",
            text = message,
            icon = icon,
            icon_size = dpi(30),
            timeout = 5
        })
    end
end

local function monitor_usb()
    awful.spawn.with_line_callback(
        "udevadm monitor --udev --subsystem-match=usb --property", {
            stdout = function(line)
                if string.find(line, "ACTION=add") then
                    os.execute(
                        "mpg123 ~/.config/awesome/themes/songs/device.mp3 &")
                    notify_usb_action("add")
                elseif string.find(line, "ACTION=remove") then
                    os.execute(
                        "mpg123 ~/.config/awesome/themes/songs/device.mp3 &")
                    notify_usb_action("remove")
                end
            end
        })
end

monitor_usb()
