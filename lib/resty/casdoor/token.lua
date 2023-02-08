local sub = string.sub
local byte = string.byte
local tab_insert = table.insert
local tab_remove = table.remove
local null = ngx.null
local ipairs = ipairs
local type = type
local pairs = pairs
local unpack = unpack
local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring
local rawget = rawget
local select = select

local cjson = require("cjson")
local jsonschema = require("jsonschema")

local casdoor_api    = require("resty.casdoor.api")
local casdoor_schema = require("resty.casdoor.schema")
local casdoor_request= require("resty.casdoor.request")

local content_type_json = "application/json; charset=utf-8"

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 15)

_M._VERSION = '0.1'

local mt = { __index = _M }

function _M.new(self, conf)
    return setmetatable({ 
        auth_config = conf, 
        _req = casdoor_request:new(conf)
    }, mt)
end

local apis = casdoor_api.token

function _M:add(user)
    user.owner = self.auth_config.OrganizationName
    local id = user.owner .. "/" .. user.name
    local api = apis["add"]

    if not api then
        return nil , "not found api defined."
    end

    local schema_def = api.body
    local validator = jsonschema.generate_validator(schema_def)

    local ok, err = validator(user)

    if not ok then
        return nil, err
    end

    local content = cjson.encode(user)

    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    if api.method == "POST" then
        res, err = req:post(url, { id = id }, content, content_type_json)
    end

    return res, err
end

function _M:delete(user)

    user.owner = self.auth_config.OrganizationName
    local id = user.owner .. "/ " .. user.name
     
     local api = apis["delete"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local content = cjson.encode(user)
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "POST" then
         res, err = req:post(url, { id = id }, content, content_type_json)
     end
 
     return res, err
end

function _M:get(name)
    local id = self.auth_config.OrganizationName .. "/" .. name

    local api = apis["get"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "GET" then
         res, err = req:get(url, { id = id })
     end

     return res, err
end

function _M:get_by_email(email)
    local query = {
        owner = self.auth_config.OrganizationName,
        email = email
    }

    local api = apis["get"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "GET" then
         res, err = req:get(url, query)
     end

     return res, err
end

function _M:get_global()

    local api = apis["get_global"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "GET" then
         res, err = req:get(url)
     end

     return res, err
end

function _M:get_sorted(sorter, limit)
    local query = {
        owner = self.auth_config.OrganizationName,
        sorter = sorter,
        limit  = limit
    }

    local api = apis["get_sorted"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "GET" then
         res, err = req:get(url, query)
     end

     return res, err
end

function _M:list()
    local owner = self.auth_config.OrganizationName

    local api = apis["list"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "GET" then
         res, err = req:get(url, { owner = owner })
     end

     return res, err
end

function _M:count(is_online)
    local query = {
        owner = self.auth_config.OrganizationName,
        isOnline = is_online
    }

    local api = apis["count"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "GET" then
         res, err = req:get(url, query)
     end

     return res, err
end

function _M:update(user, columns)
    user.owner = self.auth_config.OrganizationName
    local id = user.owner .. "/" .. user.name

    local query = { id = id, columns = table.concat(columns, ",") }

    local api = apis["update"]
 
    if not api then
        return nil , "not found api defined."
    end

    local schema_def = api.body
    local validator = jsonschema.generate_validator(schema_def)

    local ok, err = validator(user)

    if not ok then
        return nil, err
    end

 
    local content = cjson.encode(user)

    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    if api.method == "POST" then
        res, err = req:post(url, query, content, content_type_json)
    end

    return res, err
end

function _M:check_password(user)
    user.owner = self.auth_config.OrganizationName
    local id = user.owner .. "/" .. user.name

    local api = apis["check_password"]
 
    if not api then
        return nil , "not found api defined."
    end

    local schema_def = api.body
    local validator = jsonschema.generate_validator(schema_def)

    local ok, err = validator(user)

    if not ok then
        return nil, err
    end

 
    local content = cjson.encode(user)

    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    if api.method == "POST" then
        res, err = req:post(url, { id = id }, content, content_type_json)
    end

    return res, err
end

return _M