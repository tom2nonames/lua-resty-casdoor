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

function _M:upload(user, tag, parent, full_file_path, local_file_path, created_time, description)

    local ngx_re = require "ngx.re"
    local keys, err = ngx_re.split(full_file_path, "/")
    local file_name = keys[#keys]

    local query = {
        owner = self.auth_config.OrganizationName,
        user  = user,
        application = self.auth_config.ApplicationName,
        tag = tag,
        parent = parent,
        fullFilePath = full_file_path -- "resource/" ..  self.auth_config.OrganizationName .. "/" .. user .. "/" .. file_name
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

    local req = self._req
    local url = req:get_url(api.uri)
    local res, err

    if api.method == "POST" and api.body == "file" then
        res, err = req:file(url, query, local_file_path, file_name)
    end

    return res, err
end

return _M