require('dm')
require('web')
require('json')
require('utils')
require('table')

local errcode,accessdevs= dm.GetParameterValues("InternetGatewayDevice.WANDevice.{i}.WANCommonInterfaceConfig.",{"WANAccessType","PhysicalLinkStatus"})
    
local errcode,pppCon = dm.GetParameterValues("InternetGatewayDevice.WANDevice.{i}.WANConnectionDevice.{i}.WANPPPConnection.{i}.", 
    {"Name", "X_WanAlias", "Enable", "X_IPv4Enable", "ConnectionStatus", "X_IPv6Enable", "X_IPv6ConnectionStatus", "X_ServiceList"});

local errcode,ipCon = dm.GetParameterValues("InternetGatewayDevice.WANDevice.{i}.WANConnectionDevice.{i}.WANIPConnection.{i}.", 
    {"Name", "X_WanAlias", "Enable", "X_IPv4Enable", "ConnectionStatus", "X_IPv6Enable", "X_IPv6ConnectionStatus", "X_ServiceList"});

local response = {}	
local wanpaths = {}

--����wan���ӵ�ʵ���ţ���ȡ��Ӧ�Ľ��뷽ʽ
function fill_access_info_by_ID(ID, conn, accessdevs)
    local start = string.find(ID, "WANConnectionDevice")
    local res = string.sub(ID, 1, start - 1)
    res = res.."WANCommonInterfaceConfig."
    conn.AccessType = ""
    conn.AccessStatus = "down"
    for k,v in pairs(accessdevs) do
        if res == k then
            conn.AccessType = string.lower(v["WANAccessType"])
            conn.AccessStatus = string.lower(v["PhysicalLinkStatus"])
            break
        end
    end
end

--������ģ�ͷ��ص�WANPPPConnection�б��У����Ҳ���ȡ����wan��������Ϣ��wanpath����
for k,v in pairs(pppCon) do
	local internet_wan_flag = string.find(v["X_ServiceList"], "INTERNET")	
	if nil ~= internet_wan_flag  then
		local wanpath = {}
		local finddot
		
		--wanpaths.ID = k
		wanpath.WanPathValue = k
		wanpath.WanPathName = v["Name"]
		if nil ~= v["X_WanAlias"] and "" ~= v["X_WanAlias"] then
			wanpath.WanPathName = v["X_WanAlias"]
		end
		wanpath.WanPathStatusV4 = string.lower(v["ConnectionStatus"])
		wanpath.WanPathStatusV6 = ""
		if nil ~= v["X_IPv6ConnectionStatus"] then   
			wanpath.WanPathStatusV6 = string.lower(v["X_IPv6ConnectionStatus"])
		end
		fill_access_info_by_ID(k, wanpath, accessdevs);

		finddot = string.find(wanpath.WanPathValue, ".", string.len(wanpath.WanPathValue));
		if  nil ~= finddot  then
		    wanpath.WanPathValue = string.sub(wanpath.WanPathValue, 1, -2)
		end
		
		table.insert(wanpaths, wanpath)
	end
end

--������ģ�ͷ��ص�WANIPConnection�б��У����Ҳ���ȡ����wan��������Ϣ��wanpath����
for k,v in pairs(ipCon) do
	local internet_wan_flag = string.find(v["X_ServiceList"], "INTERNET")	
	if nil ~= internet_wan_flag then
		local wanpath = {}
		local finddot
		
		--wanpaths.ID = k
		wanpath.WanPathValue = k
		wanpath.WanPathName = v["Name"]
		if nil ~= v["X_WanAlias"] and "" ~= v["X_WanAlias"] then
			wanpath.WanPathName = v["X_WanAlias"]
		end
		wanpath.WanPathStatusV4 = string.lower(v["ConnectionStatus"])
		wanpath.WanPathStatusV6 = ""
		if nil ~= v["X_IPv6ConnectionStatus"] then   
			wanpath.WanPathStatusV6 = string.lower(v["X_IPv6ConnectionStatus"])
		end
		fill_access_info_by_ID(k, wanpath, accessdevs);
		
		finddot = string.find(wanpath.WanPathValue, ".", string.len(wanpath.WanPathValue));
		if  nil ~= finddot  then
		    wanpath.WanPathValue = string.sub(wanpath.WanPathValue, 1, -2)
		end
		
		table.insert(wanpaths, wanpath)
	end
end

--��wanpath��ID����wan���ӵ�·��ֵ������֮��ת��Ϊxml��ʽ�����ظ�webui
--utils.multiObjSortByID(wanpaths)
response.wanpaths = wanpaths
print(json.xmlencode(response))
sys.print(json.xmlencode(response))