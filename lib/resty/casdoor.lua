local jsonschema = require("jsonschema")
local jwt        = require("resty.jwt")
local http       = require("resty.http")
local cjson      = require("cjson")

local casdoor_schema = require("resty.casdoor.schema")

local ngx = ngx
local ngx_log = ngx.log
local ngx_DEBUG = ngx.DEBUG
local ngx_WARN  = ngx.WARN

local sfmt = string.format

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 10)

_M._VERSION = '0.1'

local mt = { __index = _M }

local path_options = {
    api = "/api",
    login_authorize  = "/login/oauth/authorize",
    signup_authirize = "/api/signup/oauth/authorize",
    token            = "/api/login/oauth/access_token",
    introspect       = "/api/login/oauth/introspect",
    refresh_token    = "/api/login/oauth/refresh_token",
    token_logout     = "/api/login/oauth/logout",
    logout           = "/api/logout",
    userinfo         = "/api/userinfo",
    enforce          = "/api/enforce",
    batch_enforce    = "/api/batch-enforce",
    get_all_roles    = "/api/get-all-actions",
    get_all_objects  = "/api/get-all-objects",
    get_all_roles    = "/api/get-all-roles",
}

function _M.new(self)
    local cwrap = {
        auth_config = nil
    }
    return setmetatable(cwrap, mt)
end

function _M.init_config(self, config)
    local schema_def = casdoor_schema.auth_config
    local validator = jsonschema.generate_validator(schema_def)

    local ok, err = validator(config)

    if ok then
        self.auth_config = config
    end

    return ok, err
end

--[[
    http://10.66.61.37:8000/api/login/oauth/authorize
    http://10.66.61.37:8000/login/oauth/authorize
    ?client_id=533b70339c845ccba7af
    &response_type=code
    &redirect_uri=http%3A%2F%2Flocalhost:9000%2Fcallback
    &scope=read&state=izw
]]
function _M.get_auth_link(self, redirect_uri, state, response_type, scope )
    response_type = response_type or "code"
    scope = scope or "read"

    local url = sfmt( "%s%s",
                      self.auth_config.Endpoint,
                      path_options.login_authorize)

    local query = {
        client_id = self.auth_config.ClientId,
        response_type = response_type,
        redirect_uri = redirect_uri,
        scope = scope,
        state = state
    }

    local params = {
        method  = "GET",
        query = query,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)
    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: ", cjson.encode(res)
    end

    local data = cjson.decode(body)

    return data["url"], err
end

function _M.get_oauth_token(self, code, state)

    local grant_type = "authorization_code"
    if not code then
        grant_type =  "client_credentials"
    end
    local opts = {
        grant_type      = grant_type,
        client_id       = self.auth_config.ClientId,
        client_secret   = self.auth_config.ClientSecret,
        code            = code
     }

    local url = sfmt( "%s%s",
                      self.auth_config.Endpoint,
                      path_options.token )

    local params = {
        method  = "POST",
        --headers = headers,
        query    = opts,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. body
    end

    ngx.log(ngx.DEBUG, body)
    local data = cjson.decode(body)

    local token = data.access_token
    if not token then
        return nil, "failed when accessing token: no access_token contained"
    end

    local expires_in = data.expires_in
    if not expires_in or expires_in == 0 then
        return nil, "failed when accessing token: invalid access_token"
    end

    return data, err

end

function _M.refresh_oauth_token(self, refresh_token, scope)
    local grant_type = "refresh_token"

    local opts = {
        grant_type      = grant_type,
        client_id       = self.auth_config.ClientId,
        client_secret   = self.auth_config.ClientSecret,
        refresh_token   = refresh_token,
        scope           = scope
     }

    local url = sfmt( "%s%s",
                      self.auth_config.Endpoint,
                      path_options.refresh_token )

    local params = {
        method  = "POST",
        --headers = headers,
        query    = opts,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. body
    end

    local data = cjson.decode(body)

    local token = data.access_token
    if not token then
        return nil, "failed when accessing token: no access_token contained"
    end

    local expires_in = data.expires_in
    if not expires_in or expires_in == 0 then
        return nil, "failed when accessing token: invalid access_token"
    end

    return data, err
end

function _M.oauth_token_logout(self, token, post_logout_redirect_uri)

    local opts = {
        id_token_hint = token,
        state =  self.auth_config.ApplicationName,
        post_logout_redirect_uri = post_logout_redirect_uri
     }

    local headers = {
        ["Content-Type"] = "application/json; charset=utf-8",
    }

    local url = sfmt( "%s%s",
                      self.auth_config.Endpoint,
                      path_options.logout)

    local params = {
        method  = "GET",
        headers = headers,
        query    = opts,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    ngx.log(ngx.DEBUG, url)
    ngx.log(ngx.DEBUG, body)

    local data = cjson.decode(body)
    if status_code == 200 and data and data.status == "ok" then
        return data, nil
    end

    return nil, "err: " .. body
end

function _M.logout(self, token, post_logout_redirect_uri)

    local headers = {
        ["Content-Type"] = "application/json; charset=utf-8",
        --["Authorization"] = sfmt("Bearer %s", token)
    }
    local opts = {
        id_token_hint = token,
        state =  self.auth_config.ApplicationName,
        post_logout_redirect_uri = post_logout_redirect_uri
     }

    local url = sfmt("%s%s", self.auth_config.Endpoint, path_options.logout)

    local params = {
        method  = "POST",
        headers =  headers,
        query    = opts,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(6000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil , err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers


    local data = cjson.decode(body)

    if status_code == 200 and data and data.status == "ok" then
        return data, nil
    end

    return nil, "err: " .. body
end

function _M.parse_jwt_token(self, token)

    local jwt_obj = jwt:verify(self.auth_config.JwtPublicKey, token)
    local reason  = nil
    if not jwt_obj.verified then
        reason = jwt_obj["reason"]
    end
    return jwt_obj, reason
end

local function get_signin_url(self, redirect_uri)
    local scope = "read"
    local state = self.auth_config.ApplicationName

    return sfmt("%s/login/oauth/authorize?client_id=%s&response_type=code&redirect_uri=%s&scopt=%s",
                self.auth_config.Endpoint,
                self.auth_config.ClientId,
                ngx.escape_uri(redirect_uri),
                scope, state )
end
_M.get_signin_url = get_signin_url

function _M.get_signup_url(self, enabled_password, redirect_uri)

    if enabled_password then
        return sfmt("%s/signup/%s",
                    self.auth_config.Endpoint,
                    self.auth_config.ApplicationName)
    else
        local signin_url = get_signin_url(self, redirect_uri)
        return signin_url:gsub("%/login/oauth/authorize", "/signup/oauth/authorize")
    end
end

function _M.get_user_profile_url(self, user_name, access_token)
    local param = ""
    if access_token ~= "" then
        param = sfmt("?access_token=%s", access_token)
    end

    return sfmt("%s/users/%s/%s%s",
                self.auth_config.Endpoint,
                self.auth_config.OrganizationName,
                user_name, param )
end

function _M.get_my_profile_url(self, access_token)
    local param = ""
    if access_token ~= "" then
        param = sfmt("?access_token=%s", access_token)
    end
    return sfmt("%s/account%s", self.auth_config.Endpoint, param )
end

function _M.enforce(self, token, item)

    local headers = {
        ["Content-Type"] = "application/json; charset=utf-8",
        ["Authorization"] = sfmt("Bearer %s", token)
    }

    local url = sfmt("%s%s",
                     self.auth_config.Endpoint,
                     path_options.enforce)
    local params = {
        method  = "POST",
        headers = headers,
        body =cjson.encode(item),
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. body
    end

    ngx.log(ngx.DEBUG, body)
    local data = cjson.decode(body)

    return data, err
end

function _M.batch_enforce(self, token, items)
    local headers = {
        ["Content-Type"] = "application/json; charset=utf-8",
        ["Authorization"] = sfmt("Bearer %s", token)
    }

    local url = sfmt( "%s%s", self.auth_config.Endpoint,
                      path_options.batch_enforce)

    local params = {
        method  = "POST",
        headers = headers,
        body = cjson.encode(items),
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. res.body
    end

    local data = cjson.decode(body)

    return data, err
end

function _M.get_all_objects(self, token)
    local headers = {
        ["Authorization"] = sfmt("Bearer %s", token)
    }

    local url = sfmt( "%s%s", self.auth_config.Endpoint,
                      path_options.get_all_objects)

    local params = {
        method  = "GET",
        headers = headers,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. body
    end

    local data = cjson.decode(body)

    return data, err
end

function _M.get_all_actions(self, token)
    local headers = {
      ["Authorization"] = sfmt("Bearer %s", token)
    }

    local url = sfmt( "%s%s", self.auth_config.Endpoint,
                      path_options.get_all_actions )

    local params = {
        method  = "GET",
        headers = headers,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. body
    end

    local data = cjson.decode(body)

    return data, err
end

function _M.get_all_roles(self, token)
    local headers = {
        ["Authorization"] = sfmt("Bearer %s", token)
    }

    local url = sfmt( "%s%s", self.auth_config.Endpoint,
                      path_options.get_all_roles)

    local params = {
        method  = "GET",
        headers = headers,
        ssl_verify = false,
        keepalive_timeout = 600,
        keepalive_pool    = 50
    }

    local httpc = http.new()
          httpc:set_timeout(1000)

    local res, err = httpc:request_uri(url, params)

    if not res or err then
        return nil, err
    end

    local status_code = res.status
    local body = res.body
    local headers = res.headers

    if status_code ~= 200 then
        return nil, "error: " .. body
    end

    local data = cjson.decode(body)

    return data, err
end

return _M