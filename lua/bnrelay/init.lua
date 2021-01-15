BNRelay.socket = GWSockets.createWebSocket(BNRelay.Config["host"]);
BNRelay.commands = {
    ["test"] = {
        action = function()
            local tbl = {
                ["type"] = "text",
                ["data"] = string.format("Server uptime: %s", CurTime())
            }

            return tbl
        end
    },
    ["status"] = {
        action = function()
            local tbl = {
                ["type"] = "embed",
                ["data"] = {
                    ["header"] = GetHostName(),
                    ["fields"] = {
                        ["ip"] = game.GetIPAddress(),
                        ["gamemode"] = gmod.GetGamemode().Name,
                        ["map"] = game.GetMap(),
                        ["players"] = string.format("%s/%s", #player.GetAll(), game.MaxPlayers())
                    }
                }
            }

            return tbl
        end
    }
}

function BNRelay.socket:onMessage(txt)
    local data = util.JSONToTable(txt)

    if (data.type == "command") then
        if (BNRelay.commands[data.text]) then
            self:write(util.TableToJSON(BNRelay.commands[data.text].action()))
        else
            self:write("Incorrect command.")
        end
    elseif (data.type == "message") then
        print(string.format("[Discord] %s: %s", data.username, data.text))
    end
end

function BNRelay.socket:onError(txt)
    print("Error: ", txt)
end

function BNRelay.socket:onConnected()
    print("Connected to relay server")
end

function BNRelay.socket:onDisconnected()
    print("WebSocket disconnected")
end

BNRelay.socket:open()