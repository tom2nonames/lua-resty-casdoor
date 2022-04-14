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

local _M = new_tab(0, 5)

_M._VERSION = '0.1'

local mt = { __index = _M }

function _M.new(self, conf)
    return setmetatable({ 
        auth_config = conf, 
        _req = casdoor_request:new(conf)
    }, mt)
end

local apis = casdoor_api.service

function _M:send_email(email_form)

    
    local api = apis["send_email"]

    if not api then
        return nil , "not found api defined."
    end

    local schema_def = api.body
    local validator = jsonschema.generate_validator(schema_def)

    local ok, err = validator(email_form)

    if not ok then
        return nil, err
    end

    local content = cjson.encode(email_form)

    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    if api.method == "POST" then
        res, err = req:post(url, nil, content, content_type_json)
    end

    return res, err
end

function _M:send_sms(sms_form)

    local api = apis["send_sms"]
 
    if not api then
        return nil , "not found api defined."
    end

    local schema_def = api.body
    local validator = jsonschema.generate_validator(schema_def)

    local ok, err = validator(sms_form)

    if not ok then
        return nil, err
    end
 
    local content = cjson.encode(sms_form)

    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    if api.method == "POST" then
        res, err = req:post(url, nil, content, content_type_json)
    end

    return res, err
end

return _M