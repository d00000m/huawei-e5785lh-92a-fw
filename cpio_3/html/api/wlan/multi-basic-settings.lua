local dm = require('dm')
local utils = require('utils')
require('sys')

local paras = {}
local GuestWiFi = 0
local g_errcode = 0
local g_ssid_num = 0 --���㵱ǰssid�ĸ���

--���浱ǰ��key������У��guest�ͷ�guest��key
g_key_array = {}
g_guest_key_array = {}
g_all_key_array = {}
g_guest_all_key_array = {}
local g_all_ssid_num = 0

local wifidomain = "InternetGatewayDevice.X_Config.Wifi."
local errcode, wifiConf = dm.GetParameterValues(wifidomain, {"Wifi_Show_Maxassoc", "WifiDbdcEnable"})
local errcode, radionum, radioarray = dm.GetObjNum("InternetGatewayDevice.X_Config.Wifi.Radio.{i}")
local errcode, ssidnum, ssidarray = dm.GetObjNum("InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.{i}")
-- key ����"InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.1."

function get_key_by_index(ssidindex)
	if nil ~= ssidindex then
		if ssidindex <= ssidnum then
			return "InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid."..ssidindex.."."
		else
			ssidindex = ssidindex - ssidnum
			return "InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid."..ssidindex.."."
		end
	end
end

function parse_authtype( WifiAuthmode,  WifiBasicencryptionmodes )
	if ( "AUTO" == WifiAuthmode ) then
		return "Auto WEP"
	elseif ( "OPEN" == WifiAuthmode and  "NONE" == WifiBasicencryptionmodes ) then
		return "Open"
	elseif ( "OPEN" == WifiAuthmode and  "NONE" ~= WifiBasicencryptionmodes ) then
		return "Open WEP"
	elseif ( "SHARE" == WifiAuthmode ) then
		return "Shared WEP"
	elseif ( "WPA-PSK" == WifiAuthmode ) then
		return "WPA"
	elseif ( "WPA2-PSK" == WifiAuthmode ) then
		return "WPA2"
	elseif ( "WPA/WPA2-PSK" == WifiAuthmode ) then
		return "WPA/WPA2"
	elseif ( "802.1x" == WifiAuthmode ) then
		return "8021X"
	elseif ( "WPA Enterprise" == WifiAuthmode ) then
		return "WPA-EAP"
	elseif ( "WPA2 Enterprise" == WifiAuthmode ) then
		return "WPA2-EAP"
	elseif ( "WPA/WPA2 Enterprise" == WifiAuthmode ) then
		return "WPAWPA2-EAP"
	end
end

function parse_encryption_modes( WifiAuthmode,WifiBasicencryptionmodes, WifiWpaencryptionmodes, wepkey)
	if( "WPA-PSK" == WifiAuthmode
		or "WPA2-PSK" == WifiAuthmode
		or "WPA/WPA2-PSK" == WifiAuthmode ) then
		if( "MIX" == WifiWpaencryptionmodes  or "" == WifiWpaencryptionmodes or nil == WifiWpaencryptionmodes) then
			return "TKIP/AES"
		else
			return WifiWpaencryptionmodes
		end
	end

	if( "OPEN" == WifiAuthmode and  "NONE" == WifiBasicencryptionmodes  ) then
		return "None"
	else
		if(  nil == wepkey  or 5 == string.len(wepkey)  or 10 == string.len(wepkey)) then
			return "WEP64"
		elseif ( 13 == string.len(wepkey)  or 26 == string.len(wepkey) ) then
			return "WEP128"
		else
			return "WEP64"  --Ĭ�ϸ�ֵ"WEP64",�ô���ֵ����û��Ӱ��
		end
	end
end

function parse_data_to_seurity_para(ssidkey, key, v)
	if nil == ssidkey or nil == key then
		return
	end
	
	local wepkey = ""
	local enp = utils.toboolean(web.getparaenc())
	local auth_type = ""
	auth_type = parse_authtype( v.WifiAuthmode,  v.WifiBasicencryptionmodes)
	utils.add_one_parameter( paras,key.."AuthType", auth_type )

	local wep_index = 1
	if( "1" == v.WifiWepKeyIndex ) then
		wepkey = v.WifiWepKey1
	elseif ( "2" == v.WifiWepKeyIndex ) then
		wepkey = v.WifiWepKey2
	elseif ( "3" == v.WifiWepKeyIndex ) then
		wepkey = v.WifiWepKey3
	else
		wepkey = v.WifiWepKey4
	end
	wep_index = tonumber(v.WifiWepKeyIndex)

	if( nil ~= wepkey ) then
		if( true == enp  ) then
			wepkey = utils.decodestring(web.decodepara(wepkey))
		end
	end
	utils.add_one_parameter( paras,key.."EncryptionModes", parse_encryption_modes(v.WifiAuthmode, v.WifiBasicencryptionmodes, v.WifiWpaencryptionmodes, wepkey) )

	if( nil ~= v.WifiWepKey1 ) then
		if ( true ==  enp) then
			v.WifiWepKey1 = utils.decodestring(web.decodepara(v.WifiWepKey1))
		end
		if "" ~= v.WifiWepKey1 then
			utils.add_one_parameter( paras,key.."WEPKey1", v.WifiWepKey1 )
		end
	end

	if( nil ~= v.WifiWepKey2 ) then
		if ( true ==  enp) then
			v.WifiWepKey2 = utils.decodestring(web.decodepara(v.WifiWepKey2))
		end
		if "" ~= v.WifiWepKey2 then
			utils.add_one_parameter( paras,key.."WEPKey2", v.WifiWepKey2 )
		end
	end

	if( nil ~= v.WifiWepKey3 ) then
		if (  true ==  enp) then
			v.WifiWepKey3 = utils.decodestring(web.decodepara(v.WifiWepKey3))
		end
		if "" ~= v.WifiWepKey3 then
			utils.add_one_parameter( paras,key.."WEPKey3", v.WifiWepKey3 )
		end
	end

	if( nil ~= v.WifiWepKey4 ) then
		if (  true ==  enp) then
			v.WifiWepKey4 = utils.decodestring(web.decodepara(v.WifiWepKey4))
		end
		if "" ~= v.WifiWepKey4 then
			utils.add_one_parameter( paras,key.."WEPKey4", v.WifiWepKey4 )
		end
	end

	utils.add_one_parameter( paras,key.."WEPKeyIndex", v.WifiWepKeyIndex )

	if( nil ~= v.WifiWpapsk  ) then
		if (  true == enp) then
			v.WifiWpapsk = utils.decodestring(web.decodepara(v.WifiWpapsk))
		end
		if "" ~= v.WifiWpapsk then
			utils.add_one_parameter( paras,key.."KeyPassphrase", v.WifiWpapsk)
		end
	end
	--���浱ǰ��key
	local errcode1,ssidpara = dm.GetParameterValues(ssidkey, {"Enable","IsGuestNetwork"})
	ssidpara = ssidpara[ssidkey]
	local ssid_index = tonumber(v.Index) + 1
	if(nil ~= ssidpara )then
	
	    local pwd = ""
		if (1 == tonumber(v.WifiEnable)) then 
			if("Auto WEP" == auth_type or "Open WEP" == auth_type or "Shared WEP" == auth_type) then
			
				pwd = wepkey
				if(nil == pwd) then
					if(1 == ssidpara["IsGuestNetwork"])then
						pwd = g_guest_all_key_array[ssid_index][wep_index]
					else
						pwd = g_all_key_array[ssid_index][wep_index]
					end
				end
			elseif("WPA" == auth_type or "WPA2" == auth_type or "WPA/WPA2" == auth_type ) then
				
				pwd = v.WifiWpapsk
				if(nil == pwd)then
					if(1 == ssidpara["IsGuestNetwork"])then
						pwd = g_guest_all_key_array[ssid_index][5]
					else
						pwd = g_all_key_array[ssid_index][5]
					end
				end
			else 
				pwd = ""
			end
			
			if(nil ~= pwd) then
				if(1 == ssidpara["IsGuestNetwork"]) then
					g_guest_key_array[ssid_index] = pwd
				else
					g_key_array[ssid_index] = pwd
				end
			end
		else
			g_guest_key_array[ssid_index] = pwd
			g_key_array[ssid_index] = pwd
		end
	end
end
--����wifiʱ����
function parse_data_to_guestofftime_para(key,v)
	--GUESTNETWORK��ʱ�����ͣ�ĿǰΪ0,1,2��3��ֵ�������ã��ֱ��Ӧ��Ч��4Сʱ��һ�죬����
	local timetype = "3"

	if( "0" == v.wifiguestofftime ) then
		timetype = "3" --���ÿ���
	elseif( "4" == v.wifiguestofftime ) then
		timetype = "1" --4Сʱ�ر�
	elseif( "24" == v.wifiguestofftime ) then
		timetype = "2" --24Сʱ�Զ��ر�
	else
		timetype = "3" --��Чֵ���������
	end

	return timetype
end

function parse_data_to_ssid_para(key, v)
	local errcode1,ssidpara = dm.GetParameterValues(key, {"Enable","IsGuestNetwork","AssociateDeviceNum"})
	ssidpara = ssidpara[key]
	--��ȡ��ssid�Ƿ���guest
	if(1 == ssidpara["IsGuestNetwork"]) then
		local maps = {
				GuestNetworkEnable = "GuestNetworkEnable",
				GuestNetworkTimerType = "GuestNetworkTimerType"
			}

		if(ssidpara["Enable"] ~= v.WifiEnable) then
			local domain = "InternetGatewayDevice.X_GUESTNETWORK."
			local errcode, values = dm.GetParameterValues(domain, maps)

			local obj
			if values ~= nil then
				obj = values[domain]
				if ("1" ~= GuestWiFi) then
				    obj["GuestNetworkEnable"] = v.WifiEnable
				end
				GuestWiFi = v.WifiEnable
				local temptime = parse_data_to_guestofftime_para(key, v)
				obj["GuestNetworkTimerType"] = temptime
				local param = utils.GenSetObjParamInputs(domain, obj, maps)
				local err,needreboot, paramerror = dm.SetParameterValues(param);
			end
		end
	end

	if nil ~= key then
		if('1' == v.WifiEnable) then
			g_ssid_num = g_ssid_num + 1;
		end
		utils.add_one_parameter(paras, key.."Enable", v.WifiEnable)
		utils.add_one_parameter(paras, key.."SSID", v.WifiSsid)

		if nil ~= v.wifi_max_assoc then
			if 1 == wifiConf[wifidomain]["Wifi_Show_Maxassoc"] then
				utils.add_one_parameter(paras, key.."AssociateDeviceNum", v.wifi_max_assoc)
			elseif 2 == wifiConf[wifidomain]["Wifi_Show_Maxassoc"] then
				for radioindex = 1, radionum, 1 do
					for ssidindex = 1, ssidnum, 1 do
						if nil ~= string.find(key, "Radio."..radioindex) then
							if ssidpara["AssociateDeviceNum"] ~= tonumber(v.wifi_max_assoc) then
								utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio."..radioindex..".Ssid."..ssidindex..".AssociateDeviceNum", v.wifi_max_assoc)
								utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Radio."..radioindex..".Basic.TotalWifiMaxAssoc", v.wifi_max_assoc)
							end
						end
					end
				end
			end
		end

		if( "0" == v.WifiBroadcast ) then
			utils.add_one_parameter(paras, key.."AdvertisementEnabled", 1)
		else
			utils.add_one_parameter(paras, key.."AdvertisementEnabled", 0)
		end
	end
end


function wifi_switch_status()
	local radiostatus = 0
	local ssidstatus = 0
	local postssidstatus = 0
	local errcode, wifiradio = dm.GetParameterValues("InternetGatewayDevice.X_Config.Wifi.Radio.{i}.", {"Enable"})
	for k, v in pairs(wifiradio) do
		if nil == v["Enable"] then
			g_errcode = 9003
			return
		end
		radiostatus = radiostatus + v["Enable"]

		local errcode, wifissid = dm.GetParameterValues(k.."Ssid.{i}.", {"Enable"})
		for k1, v1 in pairs(wifissid) do
			if nil == v1["Enable"] then
				g_errcode = 9003
				return
			end
			ssidstatus = ssidstatus + v1["Enable"]
		end
	end

	local Ssids = data["Ssids"]
	for k2, v2 in pairs(Ssids) do
		if nil ~= v2.WifiEnable then
			postssidstatus = postssidstatus + v2.WifiEnable
		end
	end

	if 0 == radiostatus or (0 == ssidstatus and 0 == postssidstatus) then
		g_errcode = 9003
		return false
	else
		return true
	end
end

--��鵱ǰ��ssid�Ƿ��offload����
function check_mbss_and_offload()
	if(nil ~= wifiConf)then
		--DBDC�ر�ֱ�ӷ���false
		if(1 ~= wifiConf[wifidomain]["WifiDbdcEnable"]) then
			return false;
		end

		--��ȡoffload�����ÿ���
		local offloadDomain = "InternetGatewayDevice.X_Config.Wifi.Sta."
		local errcode, offloadConf = dm.GetParameterValues(offloadDomain,{"Enable","Sta_Switch"})
		if(nil ~= offloadConf) then
			offloadConf = offloadConf[offloadDomain]
			--offload��enable��sta_swicth����������ʾoffload����
			if(1 == offloadConf["Enable"] and 1 == offloadConf["Sta_Switch"]) then
				if(2 <= g_ssid_num) then
					return true
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

--У��dbdcģʽ�·������Ƿ�Ϸ�
function check_dbdc_post_para()
	local ssid1poststatus = 0  --post���ĵ�2��ssid Enable
	local ssid2poststatus = 0  --post���ĵ�3��ssid Enable
	local ssid1dbstatus = 0  --db�е�2��ssid Enable
	local ssid2dbstatus = 0  --db�е�3��ssid Enable
	local ssid1postflag = 0  --post�����Ƿ������2��ssid
	local ssid2postflag = 0  --post�����Ƿ������3��ssid
	local ssidstatus = true  --post�����Ƿ�Ϸ�

	if nil ~= wifiConf then
		if 1 ~= wifiConf[wifidomain]["WifiDbdcEnable"] then
			return true
		end
	end

	local errcode, wifissid1 = dm.GetParameterValues("InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.2.", {"Enable"})
	local errcode, wifissid2 = dm.GetParameterValues("InternetGatewayDevice.X_Config.Wifi.Radio.2.Ssid.1.", {"Enable"})
	for k, v1 in pairs(wifissid1) do
		if nil ~= v1["Enable"] then
			ssid1dbstatus = v1["Enable"]
		end
	end
	for k, v2 in pairs(wifissid2) do
		if nil ~= v2["Enable"] then
			ssid2dbstatus = v2["Enable"]
		end
	end

	local Ssids = data["Ssids"]
	for k, v in pairs(Ssids) do
		if nil ~= v then
			if "1" == v.Index then
				if "1" == v.WifiEnable then
					ssid1poststatus = 1
				end
				ssid1postflag = 1
			end
			if "2" == v.Index then
				if "1" == v.WifiEnable then
					ssid2poststatus = 1
				end
				ssid2postflag = 1
			end
		end
	end

	--post���Ŀ�����2��ssid ��������3��ssid
	if 1 == ssid1postflag and 1 ~= ssid2postflag then
		--post���ĵ�2��ssid EnableΪ1 db�е�3��ssid EnableΪ1
		if 1 == ssid1poststatus and 1 == ssid2dbstatus then
			ssidstatus = false
		end
	--post���Ŀ�����3��ssid ��������2��ssid
	elseif 1 ~= ssid1postflag and 1 == ssid2postflag then
		--db�е�2��ssid EnableΪ1 post���ĵ�3��ssid EnableΪ1
		if 1 == ssid1dbstatus and 1 == ssid2poststatus then
			ssidstatus = false
		end
	--post���Ŀ�����2���͵�3��ssid
	elseif 1 == ssid1postflag and 1 == ssid2postflag then
		--post���ĵ�2���͵�3��ssid EnableΪ1
		if 1 == ssid1poststatus and 1 == ssid2poststatus then
			ssidstatus = false
		end
	end

	if false == ssidstatus then
		return false
	else
		return true
	end
end

--�����ssid��guest ssid�������Ƿ���ͬ
function check_guest_ssid_key()
	for i = 1, g_all_ssid_num do  
		if(nil ~= g_guest_key_array[i] and "" ~= g_guest_key_array[i] )then
			for j = 1, g_all_ssid_num do
				if(nil ~= g_key_array[j] and "" ~= g_key_array[j] )then
					if(g_guest_key_array[i] == g_key_array[j]) then
						return false
					end
				end
			end
		end
	end
	return true;
end
function get_index_by_key( key )
    
	local radioindex = string.match(key, "%d+") 
	local ssidindex = string.match(key, "%d+", 49) 
    	local radio1ssidcount = 0
	
	if( nil == radioindex or nil == ssidindex ) then
		return nil
	end
	--��һ��radioֱ�ӷ���ssid����
	if ( "1" == radioindex ) then
		return ssidindex
	end
	--����radio1 ssid����
	local errcode2,wifissid = dm.GetParameterValues("InternetGatewayDevice.X_Config.Wifi.Radio.1.Ssid.{i}.", {"Enable"})
	for k2,v2 in pairs(wifissid) do
		radio1ssidcount = radio1ssidcount+1
	end
	--�ڶ���radio���ص�һ��ssid����+ssid����
	if ( "2" == radioindex ) then
		return radio1ssidcount + ssidindex
	end
	return nil
end

--�������ݿ��е�key
local errcode,wifiConf = dm.GetParameterValues("InternetGatewayDevice.X_Config.Wifi.Radio.{i}.",{"Enable"})
for k,v in pairs(wifiConf) do
	local wifidomain = "InternetGatewayDevice.X_Config.Wifi."
	local errcode1,wifissid = dm.GetParameterValues(k.."Ssid.{i}.", {"Enable","IsGuestNetwork"})
	for k2,v2 in pairs(wifissid) do
	        g_all_ssid_num = g_all_ssid_num + 1
		--������
		local index = 1
		index = tonumber(get_index_by_key(k2))
		if( nil ~= index ) then
			--security
			local wpapwd = ""
			local weppwd_1 = ""
			local weppwd_2 = ""
			local weppwd_3 = ""
			local weppwd_4 = ""
			
			local errcode,Security = dm.GetParameterValues(k2.."Security.",{"WEPKey1","WEPKey2","WEPKey3","WEPKey4","KeyPassphrase","AuthType","WEPKeyIndex"})
			local security = Security[k2.."Security."]
			local auth_type = security["AuthType"]
			
			wpapwd = security["KeyPassphrase"]
			weppwd_1 = security["WEPKey1"]
			weppwd_2 = security["WEPKey2"]
			weppwd_3 = security["WEPKey3"]
			weppwd_4 = security["WEPKey4"]
			
			if ( "WPA" ==  auth_type or "WPA2" == auth_type or "WPA/WPA2" == auth_type) then
				pwd = wpapwd
			elseif ( "Open WEP" == auth_type or "Shared WEP"== auth_type or "Auto WEP"== auth_type) then
				local wep_index = 0
				wep_index = security["WEPKeyIndex"]
				if(1 == wep_index) then
					pwd = weppwd_1
				elseif(2 == wep_index) then
					pwd = weppwd_2
				elseif(3 == wep_index) then
					pwd = weppwd_3
				elseif(4 == wep_index) then
					pwd = weppwd_4
				end
			else
				pwd = ""
			end
			if(1 == v2["IsGuestNetwork"]) then
				g_guest_key_array[index] = pwd
				g_guest_all_key_array[index] = {}
				g_guest_all_key_array[index][1] = weppwd_1
				g_guest_all_key_array[index][2] = weppwd_2
				g_guest_all_key_array[index][3] = weppwd_3
				g_guest_all_key_array[index][4] = weppwd_4
				g_guest_all_key_array[index][5] = wpapwd
			else
				g_key_array[index] = pwd
				g_all_key_array[index] = {}
				g_all_key_array[index][1] = weppwd_1
				g_all_key_array[index][2] = weppwd_2
				g_all_key_array[index][3] = weppwd_3
				g_all_key_array[index][4] = weppwd_4
				g_all_key_array[index][5] = wpapwd
			end
		end
	end
end
if nil ~= data and nil ~= data["Ssids"] then
	if true == wifi_switch_status() then
		local Ssids = data["Ssids"]
		for k, v in pairs(Ssids) do
			if nil ~= v then
				local ID = ""
				if nil ~= v.Index then
					ID = get_key_by_index(v.Index + 1)
				end
				if "" == ID then
					print("ID error")
					utils.xmlappenderror(100005)
					return nil
				end
				parse_data_to_ssid_para(ID,v)
				parse_data_to_seurity_para(ID, ID.."Security.", v)
			end
		end

		if true == check_mbss_and_offload() or false == check_dbdc_post_para() then
			utils.xmlappenderror(100005)
			return nil
		end
		
		--check main ssid and guest ssid key
		if false == check_guest_ssid_key() then
			print("main ssid and guest ssid key equal error")
			utils.xmlappenderror(100005)
			return nil
		end

		if nil ~= data["WifiRestart"] then
			local wifiRestart = data["WifiRestart"]
			utils.add_one_parameter(paras, "InternetGatewayDevice.X_Config.Wifi.Wifi_Restart", wifiRestart)
			local errcode, NeedReboot, paramerr = dm.SetParameterValues(paras)
			g_errcode = errcode
		end
	end
end

utils.xmlappenderror(g_errcode)