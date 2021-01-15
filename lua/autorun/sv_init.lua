BNRelay = BNRelay or {};

require("gwsockets");

if SERVER then
    include("bnrelay/config.lua");
    include("bnrelay/init.lua");
end