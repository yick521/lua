-- ngx.header.content_type = "text/plain";
local cjson = require("cjson.safe");
local client = require("resty.kafka.client");
local producer = require("resty.kafka.producer");
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

args=cjson.encode(args);
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
   sid=string.sub(has_sid[0],string.len("zg_adver_sid=")+1);
end
--request img event
local ut=os.date("%Y-%m-%d %H:%M:%S");
local r_url="";
local event = '{"data":[{"dt":"evt","pr":{"$ct":'..osnow..',"$tz":'..time_zone..',"$sid":'..sid..',"$url":"'..url..'","$eid":"广告点击","_项目id":"'..projectid..'","_媒体id":"'..mediaid..'","_广告位id":"'..placementid..'","_创意id":"'..creativeid..'","_redirecturl":"'..r_url..'"}}],"sln":"itn","pl":"js","sdk":"zg_adver","sdkv":"2.0","owner":"zg","ut":"'..ut..'","tz":'..time_zone..',"debug":'..debug..',"ak":"'..appkey..'","usr":{"did":"'..did..'"}}';
local c_event = '{"event":'..cjson.encode(event)..'}';

local res = {
	Now=osnow,
	Ip=myIP,
	Method=method,
	Header=headers,
	Args=c_event
}

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
ngx.say('{"data":{},"return_code":',return_code,',"return_message":"',return_message,'"}');

--重定向传参
-- local zg_p = "zg_a_did="..did.."&zg_a_sid="..sid.."&pjd="..projectid.."&md="..mediaid.."&pld="..placementid.."&ctd="..creativeid;

-- if has_p then
--      return ngx.redirect(r_url.."&"..zg_p);
-- else
--      return ngx.redirect(r_url.."?"..zg_p);
-- end

