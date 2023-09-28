rockspec_format = "3.0"
package = "lua-resty-casdoor"
version = "0.1-0"
source = {
   url = "git+https://github.com/tom2nonames/lua-resty-casdoor.git"
}
description = {
   detailed = "lua-resty-casdoor - openresty client SDK for Casdoor",
   homepage = "https://github.com/tom2nonames/lua-resty-casdoor",
   license = "BSD License 2.0",
   labels = { "Casdoor", "OpenResty", "SDK", "Nginx" }
}
dependencies = {
   "multipart-post >= 1.4-1",
   "jsonschema >= 0.9.8-0",
   "api7-lua-resty-http >= 0.2.1-0",
   "api7-lua-resty-jwt >= 0.2.4-0"
}
build = {
   type = "builtin",
   modules = {
      ["resty.casdoor.api"] = "lib/resty/casdoor/api.lua",
      ["resty.casdoor.application"] = "lib/resty/casdoor/application.lua",
      ["resty.casdoor.organization"] = "lib/resty/casdoor/organization.lua",
      ["resty.casdoor.pemrission"] = "lib/resty/casdoor/pemrission.lua",
      ["resty.casdoor.request"] = "lib/resty/casdoor/request.lua",
      ["resty.casdoor.resource"] = "lib/resty/casdoor/resource.lua",
      ["resty.casdoor.role"] = "lib/resty/casdoor/role.lua",
      ["resty.casdoor.schema"] = "lib/resty/casdoor/schema.lua",
      ["resty.casdoor.servcie"] = "lib/resty/casdoor/servcie.lua",
      ["resty.casdoor.user"] = "lib/resty/casdoor/user.lua",
      ["resty.casdoor"] = "lib/resty/casdoor.lua"
   }
}