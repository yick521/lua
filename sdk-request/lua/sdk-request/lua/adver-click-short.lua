--
-- Created by IntelliJ IDEA.
-- User: howard
-- Date: 2017/3/2
-- Time: 下午6:58

-- 解析url参数信息
local appkey = ngx.var.appkey;
local projectid = ngx.var.projectid;
local mediaid = ngx.var.mediaid;
local placementid = ngx.var.placementid;
local creativeid = ngx.var.creativeid;

if appkey == nil then
    return '{"code":"400" "data":{},"msg":"参数appkey不能为空"}';
end
if projectid == nil then
    return '{"code":"400" "data":{},"msg":"参数projectid不能为空"}';
end
if mediaid == nil then
    return '{"code":"400" "data":{},"msg":"参数mediaid不能为空"}';
end
if placementid == nil then
    return '{"code":"400" "data":{},"msg":"参数placementid不能为空"}';
end
if creativeid == nil then
    return '{"code":"400" "data":{},"msg":"参数creativeid不能为空"}';
end

local cjson = require("cjson.safe");
local mysql = require "resty.mysql"
-- 访问db数据库
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
db:set_timeout(1000) -- 1 sec

local ok, err, errcode, sqlstate = db:connect{
    host = "103.17.40.162",
    port = 3306,
    database = "sdkv",
    user = "web2",
    password = "uzC36KpidKPEDrYaNe",
    max_packet_size = 1024 * 1024 }

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

local sql = "select target_url from advertising where activity_id = "..projectid.." and media = '"..mediaid.."' and ad_slot = '"..placementid.."' and ad_template = '"..creativeid.."'"
ngx.log(ngx.INFO, "sql: ", sql)

res, err, errcode, sqlstate = db:query(sql, 1)
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end
ngx.log(ngx.INFO, "result: ", cjson.encode(res))

local r_url = res[1]["target_url"];
if r_url == nil then
    return ngx.say('{"code":"500" "data":{},"msg":"获取url失败"}');
end

local client = require("resty.kafka.client");
local producer = require("resty.kafka.producer");
local uuid = require "resty.uuid"
local osnow=ngx.now()*1000;
local broker_list = {
    { host = "172.31.13.30", port = 9092 },
    { host = "172.31.13.31", port = 9092 },
    { host = "172.31.13.32", port = 9092 }
}
-- local topic = "sdklua_adver";
local topic = "sdklua_online";
--local key = nil;
local headers = cjson.encode(ngx.req.get_headers());
local bodys = cjson.encode(ngx.req.get_body_data());
local args="";
--local return_code = 0;
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
    myIP = ngx.var.remote_addr
end
local url = ngx.var.scheme.."://"..ngx.var.host..ngx.var.request_uri;

local did = uuid.generate_random();
local sid = osnow;
local has_did=ngx.re.match(headers,[[zg_adver_did=[\w-]+]],"o");
local has_sid=ngx.re.match(headers,[[zg_adver_sid=\d+]],"o");
local time_zone=(os.date('*t',t).hour-os.date('!*t',t).hour)*3600*1000;


if has_did then
    did=string.sub(has_did[0],string.len("zg_adver_did=")+1);
end

if has_sid then
    sid=string.sub(has_sid[0],string.len("zg_adver_sid=")+1);
end



--request img event
local ut=os.date("%Y-%m-%d %H:%M:%S");
local event = '{"data":[{"dt":"evt","pr":{"$ct":'..osnow..',"$tz":'..time_zone..',"$sid":'..sid..',"$url":"'..url..'","$eid":"广告点击","_项目id":"'..projectid..'","_媒体id":"'..mediaid..'","_广告位id":"'..placementid..'","_创意id":"'..creativeid..'","_redirecturl":"'..r_url..'"}}],"sln":"itn","pl":"js","sdk":"zg-js","sdkv":"2.0","owner":"zg","ut":"'..ut..'","tz":'..time_zone..',"debug":'..debug..',"ak":"'..appkey..'","usr":{"did":"'..did..'"}}';
local c_event = '{"event":'..cjson.encode(event)..'}';

local res = {
    Now=osnow,
    Ip=myIP,
    Method=method,
    Header=headers,
    Args=c_event
}

local message=cjson.encode(res);
ngx.log(ngx.INFO, "message: ", message);
-- this is async producer_type and bp will be reused in the whole nginx worker
local bp = producer:new(broker_list, { producer_type = "async" })
local ok, err = bp:send(topic, key, message)
if not ok then
    ngx.say("send err:", err)
    return_code=-10001;
    return
end
--重定向不传参
return ngx.redirect(r_url);
