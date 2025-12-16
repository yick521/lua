local server = require "resty.websocket.server"

local cjson = require("cjson.safe");
local client = require("resty.kafka.client");
local producer = require("resty.kafka.producer");
local osnow = ngx.now() * 1000;

local zgConfig = require "utils.zgConfig"
local broker_list = zgConfig.broker_list;
local topic = "zg_see_web";
local request_uri = ngx.var.request_uri
local appKeyAuth = string.gsub(request_uri, "/1.1/web_socket/", "")
if appKeyAuth == nil or appKeyAuth == "" then
    return ngx.exit(444)
end
appKey = io.open("/var/www/html/appkey/" .. appKeyAuth)
if not appKey then
    ngx.log(ngx.ERR, "appkey not exist=>  ", "/var/www/html/appkey/" .. appKeyAuth)
    return ngx.exit(444)
end

io.close(appKey)

local remote_addr = ngx.var.remote_addr
ngx.log(ngx.STDERR, "uri", request_uri)
-- ngx.log(ngx.STDERR, "IP", remote_addr)
myIP = remote_addr

--local error_handle = function()
--    ngx.log(ngx.ERR, "send err: ", message)
--
--end

local error_handle = function(topic, partition_id, message_queue, index, err, retryable)
    ngx.log(ngx.ERR, "send err: topic=", topic, "   partition_id:,", partition_id, "    message_queue: ", #message_queue, " index:", index, "   err:", err, "   message: ", message)
end

local bp = producer:new(broker_list, { producer_type = "async", error_handle = error_handle, refresh_interval = 5000 })

local headers = cjson.encode(ngx.req.get_headers())
-- ngx.log(ngx.STDERR, "headers", headers)
local method = ngx.req.get_method()

local wb, err = server:new {
    timeout = 5000, -- in milliseconds
    max_payload_len = 65535
}

if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end

while true do
    local data, typ, err = wb:recv_frame()
    if wb.fatal then
        ngx.log(ngx.ERR, "failed to receive frame: ", err)
        return ngx.exit(444)
    end
    if not data then
        local bytes, err = wb:send_ping()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send ping: ", err)
            return ngx.exit(444)
        end
    elseif typ == "close" then
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        ngx.log(ngx.INFO, "client ponged")
    elseif typ == "text" then
        local res = {
            Now = osnow,
            Ip = myIP,
            Method = method,
            Header = headers,
            Args = data
        }
        local message = cjson.encode(res);
        local ok, err = bp:send(topic, key, message)
        if not ok then
            ngx.say("send err:", err)
            break
        end
        local bytes, err = wb:send_text("100")
        if not bytes then
            ngx.log(ngx.ERR, "failed to send text: ", err)
            return ngx.exit(444)
        end
    end
end
wb:send_close()