require('dm')
require('json')
require('utils')
require('sys')

--Ŀǰ���в�Ʒ���ж�����umts,���������umts�Ƿ�������dmz
function getWANPPPdmz(dailtype)
    local errcode,pppCon = dm.GetParameterValues("InternetGatewayDevice.WANDevice.{i}.WANConnectionDevice.{i}.WANPPPConnection.{i}.", { "X_AutoFlag","Enable"})
    local ret = 0
    if nil ~= pppCon then
        for k,v in pairs(pppCon) do
            if nil ~= v["X_AutoFlag"] then
                if utils.toboolean(v["X_AutoFlag"]) and (1==v["Enable"]) then
                    print("ppp",k,v["Enable"])
                    ret = utils.IsPppInternetWanPath(dailtype, k)
                    if 1 == ret then
                        print("dmz get pppCon ", k)
                        return k
                    end
                end
            end
        end
    else
        print("can't find wanpath")
        return 0
    end
end

local ipdomain = getWANPPPdmz("UMTS")

--ֻ��umts wanû��ʹ�ܵ�ʱ��Ż��ߵ�����,Ŀǰ���в�Ʒ��̬����Ӧ���ߵ�����
if 0 == ipdomain then
    utils.xmlappenderror(9003)
end

local errcode,ipCon = dm.GetParameterValues(ipdomain.."X_DMZ.", 
     {"DMZEnable", "DMZHostIPAddress"});

local DMZconf = ipCon[ipdomain.."X_DMZ."]

local DMZInfo = {}
DMZInfo.DmzStatus = DMZconf["DMZEnable"]
DMZInfo.DmzIPAddress = DMZconf["DMZHostIPAddress"]
sys.print(json.xmlencode(DMZInfo))
