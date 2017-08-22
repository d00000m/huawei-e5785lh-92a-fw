require('dm')
local utils = require('utils')
          
local errcode, objs = dm.GetParameterValues("InternetGatewayDevice.Layer3Forwarding.X_IPv6Forwarding.{i}.",
    {
        "PrefixLength",
        "DestIPAddress",
        "GatewayIPAddress",
        "Interface",
    }
)

if objs ~= nil then
    for k,v in pairs(objs) do
    dm.DeleteObject(k)
    end
end   

function set_real_br_interface(data)
    local i, j = string.find(data["Interface"], "InternetGatewayDevice.WANDevice")
    if 1 == i and 0 < j then
        return
    end

    local errcode, bridges = dm.GetParameterValues("InternetGatewayDevice.Layer2Bridging.Bridge.{i}.", {"BridgeName", "BridgeKey"})
    for k, v in pairs(bridges) do 
        if v["BridgeName"] == data["Interface"] then
            data["Interface"] = "br"..v["BridgeKey"]
            return
        end
    end

end

local flag = 0
if data ~= nil then
    for k,v in pairs(data["routes"]) do
     local PrefixLength
     local DestIPAddress
     local GatewayIPAddress
     local Interface

     PrefixLength = v["PrefixLength"]
     DestIPAddress = v["DestIPAddress"]
     GatewayIPAddress = v["GatewayIPAddress"]
     set_real_br_interface(v)
     Interface = v["Interface"]

     local newObj = { 
            {"DestIPAddress", DestIPAddress}, 
            {"PrefixLength", PrefixLength},
            {"GatewayIPAddress",GatewayIPAddress},
            {"Interface", Interface},
            {"Enable", 1},
     }  
     
     local errcode, instnum, NeedReboot, paramerr= dm.AddObjectWithValues("InternetGatewayDevice.Layer3Forwarding.X_IPv6Forwarding.", newObj)
     print(errcode)
    
    end
end
