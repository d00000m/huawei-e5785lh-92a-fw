local utils = require('utils')
local web = require('web')
local dm = require('dm')
local paras = {}

local wps_instance2 = "InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid.1.WPS."
local errcode2, wps2 = dm.GetParameterValues(wps_instance2,
	{
		"DefaultDevicePin"
	}
)
if nil ~= data and nil ~= data.wpsappintype then
	if '1' == data.wpsappintype then
	    --����һ�����pin��
	    local newpin = web.genappin()
		utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.1.WPS.WpsMode", "ap-pin")
		utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.1.WPS.DevicePin", newpin)
		if(nil ~= wps2) then
			utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid.1.WPS.WpsMode", "ap-pin")
			utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid.1.WPS.DevicePin", newpin)
		end
	elseif '0' == data.wpsappintype then
	    --��ȡĬ��pin��
		local wps_instance = "InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.1.WPS."
		local errcode, wps = dm.GetParameterValues(wps_instance,
			{
				"DefaultDevicePin"
			}
		)

		local wps_obj = wps[wps_instance]
		
		utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.1.WPS.WpsMode", "ap-pin")
		utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.1.WPS.DevicePin", wps_obj["DefaultDevicePin"])
		if(nil ~= wps2) then
			utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid.1.WPS.WpsMode", "ap-pin")
			utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid.1.WPS.DevicePin", wps_obj["DefaultDevicePin"])
		end
	end
end

--�������pin�����Ĭ��PIN����Ч
local errcode, NeedReboot, paramerr =  dm.SetParameterValues(paras)

utils.xmlappenderror(errcode)
