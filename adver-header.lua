-- ngx.header.content_type = "text/plain";
local cjson = require("cjson.safe");

local osnow=ngx.now()*1000;
local args = ""
local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end
local callback = args['callback'];

local headers = cjson.encode(ngx.req.get_headers());
local did = "";
local sid = "";
local ak = "";
local pjd = "";
local md = "";
local pld = "";
local ctd = "";

local has_did=ngx.re.match(headers,[[zg_adver_did=[\w-]+]],"o");
local has_sid=ngx.re.match(headers,[[zg_adver_sid=\d+]],"o");
local has_ak=ngx.re.match(headers,[[zg_adver_ak=[\w-]+]],"o");
local has_pjd=ngx.re.match(headers,[[zg_adver_pjd=[\w-]+]],"o");
local has_md=ngx.re.match(headers,[[zg_adver_md=[\w-]+]],"o");
local has_pld=ngx.re.match(headers,[[zg_adver_pld=[\w-]+]],"o");
local has_ctd=ngx.re.match(headers,[[zg_adver_ctd=[\w-]+]],"o");


if has_did then
    did=string.sub(has_did[0],string.len("zg_adver_did=")+1);
end
if has_sid then
    sid=string.sub(has_sid[0],string.len("zg_adver_sid=")+1);
end
if has_ak then
    ak=string.sub(has_ak[0],string.len("zg_adver_ak=")+1);
end
if has_pjd then
    pjd=string.sub(has_pjd[0],string.len("zg_adver_pjd=")+1);
end
if has_md then
    md=string.sub(has_md[0],string.len("zg_adver_md=")+1);
end
if has_pld then
    pld=string.sub(has_pld[0],string.len("zg_adver_pld=")+1);
end
if has_ctd then
    ctd=string.sub(has_ctd[0],string.len("zg_adver_ctd=")+1);
end
local res = {
    zg_adver_did=did,
    zg_adver_sid=sid,
    zg_adver_ak=ak,
    zg_adver_pjd=pjd,
    zg_adver_md=md,
    zg_adver_pld=pld,
    zg_adver_ctd=ctd
}
local message = cjson.encode(res);
if callback then
    ngx.say(callback.."("..message..")");
else
    ngx.say(message);
end