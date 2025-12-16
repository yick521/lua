local cjson = require("cjson.safe");
local producer = require("resty.kafka.producer");
local auth = require("utils.auth");
local zgConfig = require "utils.zgConfig"

local now = ngx.now() * 1000;
local broker_list = zgConfig.broker_list;
local topic = "sdk_data_cc";

local args = "";
local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end

local data = args['data'];
if data == nil then
    ngx.req.read_body()
    data = ngx.req.get_body_data()
end
if data == nil then
    local return_data = {};
    return_data['return_code'] = -10002;
    return_data['return_message'] = 'data is null';
    ngx.say(cjson.encode(return_data));
    return ;
end

local data = cjson.decode(data);
if not data then
    local return_data = {};
    return_data['return_code'] = -10002;
    return_data['return_message'] = 'data structure error';
    ngx.say(cjson.encode(return_data));
    return ;
end

local authorization = ngx.req.get_headers().authorization;
local username, password = auth.get(authorization);
if not (username and password) then
    local return_data = {};
    return_data['return_code'] = -10002;
    return_data['return_message'] = 'authorization is error';
    ngx.say(cjson.encode(return_data));
    return ;
end
local request_str = cjson.encode(data);

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
if myIP == nil or myIP == "-" then
    myIP = ngx.var.remote_addr
end
if type(myIP) == "table" then
    myIP = tostring(myIP[1])
end
local has_split = ngx.re.match(myIP, [[\,]], "o");
if has_split then
    myIP = string.match(myIP, "%d+[\\.]?%d+[\\.]?%d+[\\.]?%d+[\\.]?");
end

local res = {
    time = now,
    ip = myIP,
    method = method,
    auth = authorization,
    data = request_str
}
local message = cjson.encode(res);

local bp = producer:new(broker_list, { producer_type = "async" })
local ok, err = bp:send(topic, nil, message)
if not ok then
    ngx.say("send err:", err)
    return_code = -10001;
    return
end

local return_data = {};
return_data['return_code'] = 0;
return_data['return_message'] = 'success';
ngx.say(cjson.encode(return_data));
