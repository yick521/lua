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
--重定向传参
local zg_p = "";
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
local r_url = args['landing_page'];
if r_url == nil then
    return_message="redirect url is null";
    return ngx.say('{"data":{},"return_message":"',return_message,'"}');
end


local zg_appid = args['zg_appid'];
local lid = args['lid'];
local channel_id = args['channel_id'];
local app_key = args['app_key'];
local lname = args['lname'];
local channel_type = args['channel_type'];
local push_type = args['push_type'];
local token = args['baidu_token'];

local channel_ad_name = args['channel_ad_name'];
local csite = args['csite'];
local channel_campaign_name = args['channel_campaign_name'];
local channel_account_id = args['channel_account_id'];
local channel_campaign_id = args['channel_campaign_id'];
local channel_ad_id = args['channel_ad_id'];
local channel_adgroup_name = args['channel_adgroup_name'];
local channel_adgroup_id = args['channel_adgroup_id'];
local channel_keyword_id = args['channel_keyword_id'];







local utm_source = args['utm_source'];
local utm_medium = args['utm_medium'];
local utm_campaign = args['utm_campaign'];
local utm_content = args['utm_content'];
local utm_term = args['utm_term'];







if app_key == nil then
    app_key = "";
end

if lname == nil then
    lname = "";
end

if zg_appid == nil then
    zg_appid = "";
end
if lid == nil then
    lid = "";
end
if channel_id == nil then
    channel_id = "";
end
if channel_type == nil then
    channel_type = "";
end

if push_type == nil then
    push_type = "";
end

if token == nil then
    token = "";
end

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


if channel_ad_name == nil or ngx.re.match(channel_ad_name,[[__]],"o") then
    channel_ad_name = "";
end
if csite == nil or ngx.re.match(csite,[[__]],"o") then
    csite = 0;
end
if channel_campaign_name == nil or ngx.re.match(channel_campaign_name,[[__]],"o") then
    channel_campaign_name = "";
end

if channel_account_id == nil or ngx.re.match(channel_account_id,[[__]],"o") then
    channel_account_id = 0;
end

if channel_campaign_id == nil or ngx.re.match(channel_campaign_id,[[__]],"o") then
    channel_campaign_id = 0;
end
if channel_ad_id == nil or ngx.re.match(channel_ad_id,[[__]],"o") then
    channel_ad_id = 0;
end

if channel_adgroup_name == nil or ngx.re.match(channel_adgroup_name,[[__]],"o") then
    channel_adgroup_name = "";
end

if channel_adgroup_id == nil or ngx.re.match(channel_adgroup_id,[[__]],"o") then
    channel_adgroup_id = 0;
end
if channel_keyword_id == nil or channel_keyword_id == "NULL" then
    channel_keyword_id = 0;
end

local has_p = ngx.re.match(r_url,[[\?]],"o");
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
--
local did = uuid.generate_random();



local sid = osnow;
local has_did=ngx.re.match(headers,[[zg_adver_did=[\w-]+]],"o");

ngx.log(ngx.ERR,"has_did:"..has_did)

local has_sid=ngx.re.match(headers,[[zg_adver_sid=\d+]],"o");
-- local time_zone=(os.date('*t',t).hour-os.date('!*t',t).hour)*3600*1000;
local time_zone=28800000;
-- path params
-- local appkey=ngx.var.appkey;
-- local projectid=ngx.var.projectid;
-- local mediaid=ngx.var.mediaid;
-- local placementid=ngx.var.placementid;
-- local creativeid=ngx.var.creativeid;

if has_did then
    did=string.sub(has_did[0],string.len("zg_adver_did=")+1);
    ngx.log(ngx.ERR,"最终did:"..did)
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
local event = '{"data":[{"dt":"evt","pr":{"$ct":'..osnow..',"$tz":'..time_zone..',"$sid":'..sid..',"$lid":'..lid..',"$lname":"'..lname..'","$channel_type":"'..channel_type..'","$push_type":"'..push_type..'","$token":"'..token..'","$zg_appid":'..zg_appid..',"$channel_keyword_id":'..channel_keyword_id..',"$channel_id":'..channel_id..',"$callback_url":"'..url..'","$eid":"广告点击","_redirecturl":"'..r_url..'","$channel_ad_name":"'..channel_ad_name..'","$csite":'..csite..',"$channel_campaign_name":"'..channel_campaign_name..'","$channel_account_id":'..channel_account_id..',"$channel_campaign_id":'..channel_campaign_id..',"$channel_ad_id":'..channel_ad_id..',"$channel_adgroup_name":"'..channel_adgroup_name..'","$channel_adgroup_id":'..channel_adgroup_id..',"$utm_source":"'..utm_source..'","$utm_medium":"'..utm_medium..'","$utm_campaign":"'..utm_campaign..'","$utm_content":"'..utm_content..'","$utm_term":"'..utm_term..'"}}],"sln":"itn","pl":"js","sdk":"zg_adver","sdkv":"2.0","owner":"zg","ut":"'..ut..'","tz":'..time_zone..',"debug":'..debug..',"ak":"'..app_key..'","usr":{"did":"'..did..'"}}';
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
    ck.set("zg_adver_ak",app_key,"/",host_name,true,true,3600*24*365);



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



-- if has_p then
--      return ngx.redirect(r_url.."&"..zg_p);
-- else
--      return ngx.redirect(r_url.."?"..zg_p);
-- end