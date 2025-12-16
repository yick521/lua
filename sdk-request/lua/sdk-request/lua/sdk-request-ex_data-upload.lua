-- ngx.header.content_type = "text/plain";
local cjson = require("cjson.safe");
local producer = require("resty.kafka.producer");
local zgConfig = require "utils.zgConfig"
local broker_list = zgConfig.broker_list;
local topic = "dimension_expansion";
local key = nil;
local args="";
local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end
local data = args['data'];
if data==nil then
    ngx.req.read_body()
    data = ngx.req.get_body_data()
end
if data == nil then
    local return_data={};
    return_data['return_code']=-10002;
    return_data['return_message']='data is null';
    ngx.say(cjson.encode(return_data));
    return;
end

local data = cjson.decode(data);
if not data then
    local return_data={};
    return_data['return_code']=-10002;
    return_data['return_message']='data structure error';
    ngx.say(cjson.encode(return_data));
    return;
end

-- this is async producer_type and bp will be reused in the whole nginx worker
local bp = producer:new(broker_list, { producer_type = "async" })
local ok, err = bp:send(topic, key, cjson.encode(data))
if not ok then
    ngx.say("send err:", err)
    return_code=-10001;
    return
end
ngx.say("send success")