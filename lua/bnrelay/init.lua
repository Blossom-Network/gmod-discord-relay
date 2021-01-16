BNRelay.socket = GWSockets.createWebSocket(BNRelay.Config["host"]);
BNRelay.commands = {
    ["test"] = {
        admin = false,
        action = function()
            local tbl = {
                ["type"] = "text",
                ["data"] = string.format("Server uptime: %s", CurTime())
            }

            return tbl
        end
    },
    ["status"] = {
        admin = false,
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
    },
    ["rcon"] = {
        admin = true,
        action = function(args)
            args = table.concat(args, " ")

            local tbl = {
                ["type"] = "embed",
                ["data"] = {
                    ["header"] = "RCON",
                    ["fields"] = {
                        ["command"] = args,
                    }
                }
            }

            game.ConsoleCommand(string.format("%s\n", args))

            return tbl
        end
    },
    ["runlua"] = {
        admin = true,
        action = function(args)
            args = table.concat(args, " ")
            print(args)

            local tbl = {
                ["type"] = "embed",
                ["data"] = {
                    ["header"] = "LUARUN",
                    ["fields"] = {
                        ["lua"] = args,
                    }
                }
            }

            RunString(args)

            return tbl
        end
    }
}

BNRelay.NoPermission = {["type"] = "text", ["data"] = "No permission."}
BNRelay.IncorrectCommand = {["type"] = "text", ["data"] = "Incorrect command."}

function BNRelay.TableToJSON(tbl)
    tbl["key"] = BNRelay.Config.key;

    return util.TableToJSON(tbl)
end

function BNRelay.socket:onMessage(txt)
    local data = util.JSONToTable(txt)

    if (data.key != BNRelay.Config["key"]) then print("[Discord] Invalid key request.") return end

    if (data.type == "command") then
        if (BNRelay.commands[data.text]) then
            if (BNRelay.commands[data.text].admin and data.admin) or (!BNRelay.commands[data.text].admin) then
                self:write(BNRelay.TableToJSON(BNRelay.commands[data.text].action(data.args)))
            else
                self:write(BNRelay.TableToJSON(BNRelay.NoPermission))
            end
        else
            self:write(BNRelay.TableToJSON(BNRelay.IncorrectCommand))
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