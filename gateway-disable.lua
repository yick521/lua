-- ngx.header.content_type = "text/plain";

-- ngx.eof();
local args="";

local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end

local r_url = args['url'];

ngx.header['Cache-Control']='no-cache';
ngx.header['Pragma']='no-cache';
ngx.header['Expires']=0;
if r_url == nil then
    return ngx.exec('/files/web.gif');
else
    return ngx.redirect(r_url);
end









