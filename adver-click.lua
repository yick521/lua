-- ngx.header.content_type = "text/plain";
local cjson = require("cjson.safe");
local client = require("resty.kafka.client");
local producer = require("resty.kafka.producer");
local ck = require "utils.cookie-util"
local uuid = require "resty.uuid"
local osnow=ngx.now()*1000;
-- local broker_list = {
--     { host = "172.31.13.30", port = 9092 },
--     { host = "172.31.13.31", port = 9092 },
--     { host = "172.31.13.32", port = 9092 }
-- }
local zgConfig = require "utils.zgConfig"
local broker_list = zgConfig.broker_list;
-- local topic = "sdklua_adver";
local topic = "sdklua_online";
local key = nil;
local headers = cjson.encode(ngx.req.get_headers());
local bodys = cjson.encode(ngx.req.get_body_data());
local args="";
local return_code = 0;
local return_message = "";
local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end
local debug = args['debug'];
if debug == "1" then
    debug = 1;
else
    debug = 0;
end
local r_url = args['url'];
if r_url == nil then
    return_message="redirect url is null";
    return ngx.say('{"data":{},"return_message":"',return_message,'"}');
end
local utm_source = args['utm_source'];
local utm_medium = args['utm_medium'];
local utm_campaign = args['utm_campaign'];
local utm_content = args['utm_content'];
local utm_term = args['utm_term'];
if utm_source == nil then 
    utm_source = "";
end
if utm_medium == nil then 
    utm_medium = "";
end
if utm_campaign == nil then 
    utm_campaign = "";
end
if utm_content == nil then 
    utm_content = "";
end
if utm_term == nil then 
    utm_term = "";
end

-- local has_p = ngx.re.match(r_url,[[\?]],"o");
-- args=cjson.encode(args);
local myIP = ngx.req.get_headers()["X-Real-IP"]
if myIP == nil then
   myIP = ngx.req.get_headers()["x_forwarded_for"]
end
if myIP == nil then
   myIP = ngx.req.get_headers()["Proxy-Client-IP"]
end
if myIP == nil then
   myIP = ngx.req.get_headers()["WL-Proxy-Client-IP"]
end
if myIP == nil then
   myIP = ngx.req.get_headers()["http_x_forwarded_for"]
end
if myIP == nil or myIP=="-" then
   myIP = ngx.var.remote_addr
end
if type(myIP) == "table" then
   myIP = tostring(myIP[1])
end
local has_split = ngx.re.match(myIP,[[\,]],"o");
if has_split then
    myIP=string.match(myIP,"%d+[\\.]?%d+[\\.]?%d+[\\.]?%d+[\\.]?");
end
local url = ngx.var.scheme.."://"..ngx.var.host..ngx.var.request_uri;

local did = uuid.generate_random();
local sid = osnow;
local has_did=ngx.re.match(headers,[[zg_adver_did=[\w-]+]],"o");
local has_sid=ngx.re.match(headers,[[zg_adver_sid=\d+]],"o");
-- local time_zone=(os.date('*t',t).hour-os.date('!*t',t).hour)*3600*1000;
local time_zone=28800000;
-- path params
local appkey=ngx.var.appkey;
local projectid=ngx.var.projectid;
local mediaid=ngx.var.mediaid;
local placementid=ngx.var.placementid;
local creativeid=ngx.var.creativeid;

if has_did then
    did=string.sub(has_did[0],string.len("zg_adver_did=")+1);
end

if has_sid then
    local val = 60*60*1000;
    sid=string.sub(has_sid[0],string.len("zg_adver_sid=")+1);
    if osnow-sid > val then
        has_sid = nil;
        sid = osnow;
    end
end
--request img event
local ut=os.date("%Y-%m-%d %H:%M:%S");
-- local event = '{"data":[{"dt":"evt","pr":{"$ct":'..osnow..',"$tz":'..time_zone..',"$sid":'..sid..',"$url":"'..url..'","$eid":"广告点击","_项目id":"'..projectid..'","_媒体id":"'..mediaid..'","_广告位id":"'..placementid..'","_创意id":"'..creativeid..'","_redirecturl":"'..r_url..'"}}],"sln":"itn","pl":"js","sdk":"zg_adver","sdkv":"2.0","owner":"zg","ut":"'..ut..'","tz":'..time_zone..',"debug":'..debug..',"ak":"'..appkey..'","usr":{"did":"'..did..'"}}';
local event = '{"data":[{"dt":"evt","pr":{"$ct":'..osnow..',"$tz":'..time_zone..',"$sid":'..sid..',"$url":"'..url..'","$eid":"广告点击","_项目id":"'..projectid..'","_媒体id":"'..mediaid..'","_广告位id":"'..placementid..'","_创意id":"'..creativeid..'","_redirecturl":"'..r_url..'","$utm_source":"'..utm_source..'","$utm_medium":"'..utm_medium..'","$utm_campaign":"'..utm_campaign..'","$utm_content":"'..utm_content..'","$utm_term":"'..utm_term..'"}}],"sln":"itn","pl":"js","sdk":"zg_adver","sdkv":"2.0","owner":"zg","ut":"'..ut..'","tz":'..time_zone..',"debug":'..debug..',"ak":"'..appkey..'","usr":{"did":"'..did..'"}}';
local c_event = '{"event":'..cjson.encode(event)..'}';

local res = {
	Now=osnow,
	Ip=myIP,
	Method=method,
	Header=headers,
	Args=c_event
}

-- set did cookie
if has_did == nil then
    ck.set("zg_adver_did",did,"/",host_name,true,true,3600*24*365);
end

-- set session id cookie
if has_sid == nil then 
    ck.set("zg_adver_sid",osnow,"/",host_name,true,true,3600*24*365);
end
-- set ak
    ck.set("zg_adver_ak",appkey,"/",host_name,true,true,3600*24*365);
-- set projectid
    ck.set("zg_adver_pjd",projectid,"/",host_name,true,true,3600*24*365);
-- set mediaid
    ck.set("zg_adver_md",mediaid,"/",host_name,true,true,3600*24*365);
-- set placementid
    ck.set("zg_adver_pld",placementid,"/",host_name,true,true,3600*24*365);
-- set creativeid
    ck.set("zg_adver_ctd",creativeid,"/",host_name,true,true,3600*24*365);
    

local message=cjson.encode(res);

-- ngx.say(message);
-- this is async producer_type and bp will be reused in the whole nginx worker
local bp = producer:new(broker_list, { producer_type = "async" })
local ok, err = bp:send(topic, key, message)
if not ok then
    ngx.say("send err:", err)
    return_code=-10001;
	return
end
-- ngx.say("send success, ok:", ok) 
-- ngx.say('{"data":{},"return_code":',return_code,',"return_message":"',return_message,'"}');

ngx.header['Cache-Control']='no-cache';
ngx.header['Pragma']='no-cache';
ngx.header['Expires']=0;
--重定向不传参
return ngx.redirect(r_url);

--重定向传参
-- local zg_p = "zg_a_did="..did.."&zg_a_sid="..sid.."&pjd="..projectid.."&md="..mediaid.."&pld="..placementid.."&ctd="..creativeid;

-- if has_p then
--      return ngx.redirect(r_url.."&"..zg_p);
-- else
--      return ngx.redirect(r_url.."?"..zg_p);
-- end







