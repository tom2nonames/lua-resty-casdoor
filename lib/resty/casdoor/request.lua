local setmetatable = setmetatable

local cjson  = require("cjson")
local http   = require("resty.http")
local mime_sniff = require("mime_sniff")

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 10)

_M.new_tab = new_tab
_M._VERSION = "0.01"

local mt = { __index = _M }

function _M:new(config)
    local cwrap = {
        auth_config = config
    }
    return setmetatable(cwrap, mt)
end

function _M:get_url(action)
    return self.auth_config.Endpoint .. action
end

local function do_request(self, url, method, query, content, content_type)
    local headers = {
        ["Content-Type"] = content_type or "text/plain;charset=UTF-8", 
        ["Authorization"] = "Basic " .. ngx.encode_base64( self.auth_config.ClientId .. ":" .. self.auth_config.ClientSecret ) -- "application/json; charset=utf-8",
      }
    local params = {
        method = method,
        headers = headers,
        query = query,
        body  = content,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }
    local httpc = http.new()
          httpc:set_timeout(1000)
    
    local res, err = httpc:request_uri(url, params)


    if not res then
        return nil , err
    end
 
    local body = res.body --res:read_body()
    res:read_trailers()
    local header  = res.headers
    local is_json = header["Content-Type"] == "application/json; charset=utf-8"

    if is_json then
        body   = cjson.decode(body)
    end

    return body , err
end

local function do_get(self, url, query)
    return do_request(self, url, "GET" , query)
end

_M.get = do_get

local function do_post(self, url, query, content, content_type)
    return do_request(self, url, "POST", query, content, content_type)
end

_M.post = do_post


local function do_file(self, url, query, content)
    local content_type = mime_sniff.detect_content_type(content)
    return do_post(self, url, query, content, content_type)
end

_M.file = do_file

return _M