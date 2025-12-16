-- ngx.header.content_type = "text/plain";
local cjson = require("cjson.safe");
local client = require("resty.kafka.client");
local producer = require("resty.kafka.producer");
local osnow=ngx.now()*1000;
-- ngx.eof();
-- realtime-1 为 诸葛kafka 地址
local broker_list = {
    { host = "realtime-1", port = 9092 }
};
-- local zgConfig = require "utils.zgConfig"
-- local broker_list = zgConfig.broker_list;
-- local topic = "sdklua_test";
local topic = "zg-gate";
local key = nil;
local headers = cjson.encode(ngx.req.get_headers());
local bodys = cjson.encode(ngx.req.get_body_data());
local args="";
local uri="";
local loc="";
local return_code = 0;
local return_message = "";
local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
    uri = ngx.req.get_uri_args()
end

loc=ngx.var.uri;
args=cjson.encode(args);
uri=cjson.encode(uri);
local myIP = ngx.req.get_headers()["x_forwarded_for"]
if myIP == nil then
   myIP = ngx.req.get_headers()["X-Real-IP"]
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
local res = {
	Now=osnow,
	Ip=myIP,
	Method=method,
	Header=headers,
	Args=args,
	Uri=uri,
        Loc=loc
}
local message=cjson.encode(res);
local bp = producer:new(broker_list, { producer_type = "async",refresh_interval=10000})
local ok, err = bp:send(topic, key, message)
if not ok then
    ngx.say("send err:", err)
    return_code=-10001;
	return
end
ngx.say("send success, ok:", ok) ;
