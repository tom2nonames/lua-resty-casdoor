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
local mime_sniff = require("mime_sniff")

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

local apis = casdoor_api.resource


function _M:delete(name)

    local reso = {
        owner = self.auth_config.OrganizationName,
        name  = name
    }
     
     local api = apis["delete"]
 
     if not api then
         return nil , "not found api defined."
     end
 
     local content = cjson.encode(reso)
 
     local req = self._req
     local url = req:get_url(api.uri)
     local res, err
 
     if api.method == "POST" then
         res, err = req:post(url, nil, content, content_type_json)
     end
 
     return res, err
end

function _M:upload(user, tag, parent, full_file_path, file_content, created_time, description)
    local query = {
        owner = self.auth_config.OrganizationName,
        user  = user,
        applcation = self.auth_config.ApplicationName,
        tag = tag,
        parent = parent,
        fullFilePath = full_file_path
    }
    
    if created_time then
        query["createdTime"] = created_time
    end

    if description then
        query["description"] = description
    end

    local api = apis["upload"]
 
    if not api then
        return nil , "not found api defined."
    end

    local schema_def = api.body
    local validator = jsonschema.generate_validator(schema_def)


    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    local content_type_json = mime_sniff.detect_content_type(file_content)

    if api.method == "POST" then
        res, err = req:post(url, query, file_content, content_type_json)
    end

    return res, err
end

return _M