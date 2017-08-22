local utils = require('utils')

local paras = {}
local domain1 = "InternetGatewayDevice.UserInterface.X_Web.UserInfo.1."
local domain2 = "InternetGatewayDevice.UserInterface.X_Web.UserInfo.2."
local domain = ""
local name, level = web.getuserinfo()

local value1 = ""
local value2 = ""
local errcode1,values1 = dm.GetParameterValues(domain1, {"Username"})
if 0 == errcode1 then
    value1 = values1[domain1]
end
local errcode2,values2 = dm.GetParameterValues(domain2, {"Username"})
if 0 == errcode2 then
    value2 = values2[domain2]
end

if name == value1["Username"] then
	domain = domain1
else 
	domain = domain2
end

if nil ~= data and nil ~= data["remindstate"] and nil ~= domain then
	utils.add_one_parameter(paras, domain.."EnablePasswdPrompt", data["remindstate"])
end

local errcode, NeedReboot, paramerr =  dm.SetParameterValues(paras)

utils.xmlappenderror(errcode)