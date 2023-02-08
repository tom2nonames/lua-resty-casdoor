local setmetatable = setmetatable
local error     = error

local _M = {version = 0.1}

local int  = { type = "number"}

local text    = { type = "string" , maxLength = 100  , minLength = 0 }
local text2   = { type = "string" , maxLength = 200  , minLength = 0 }
local text10  = { type = "string" , maxLength = 1000 , minLength = 0 }
local text255 = { type = "string" , maxLength = 255  , minLength = 0 }
local text_10 = { type = "string" , maxLength = 10   , minLength = 0 }


local bool = { type = "boolean"}
local mediumtext = { type = "string" }

local auth_config = {
    type = "object",
    properties = {
        Endpoint        = { type = "string" },
        ClientId        = { type = "string" },
        ClientSecret    = { type = "string" },
        JwtPublicKey    = { type = "string" },
        OrganizationName= { type = "string" },
        ApplicationName = { type = "string" },
        CallbackPath    = { type = "string",
                            default = "/casdoor/signin-callback" },
        Scope           = { type = "string" }
    },
    required = {
        "Endpoint", "ClientId", "ClientSecret", "JwtPublicKey",
        "OrganizationName", "ApplicationName"
    }
}
_M.auth_config = auth_config

local application = {
    type = "object",
    properties = {
        owner = text,
        name = text,
        createdTime = text,

        displayName = text,
        logo = text,
        homepageUrl = text,
        description = text,
        organization = text,
        cert = text,
        enabledPassWord = bool,
        enabledSignUp = bool,
        enableSigninSession = bool,
        enableCodeSignin = bool,

        clientId = text,
        clientSecret = text,
        redirectUris = text10,
        tokenFormat = text,
        expireInHours = int,
        refreshExpireInHours = int,
        signupUrl = text2,
        signinUrl = text2,
        forgetUrl = text2,
        affiliationUrl = text,
        termOfUse = text,
        signupHtml = mediumtext,
        signinHtml = mediumtext,

    }
}
_M.application = application

local response = {
    type = "object",
    properties = {
        status = text,
        msg    = text,
        data   = {
            type = "array"
        },
        data2 = {
            type = "array"
        }
    }
}

_M.response = response

local emailForm = {
    type = "object",
    properties = {
        title = text,
        content = { type = "string" },
        sender =  { type = "string" },
        receivers = {
            type = "array",
            items = {
                type = "string"
            }
        }

    }
}

_M.emailForm = emailForm

local user = {
    type = "object",
    properties = {
        owner = text,
        name  = text,
        createTime = text,
        updateTime = text,

        id = text,
        type = text,
        password = text,
        passwrodSalt = text,
        displayName = text,
        avater = text255,
        permanentAvatar = text255,
        email = text,
        phone = text,
        location = text,
        address = {
            type = "array" ,
            items = { type = "string" }
        },
        affiliation = text,
        title = text,
        idCardType = text,
        idCard  = text,
        homepage = text,
        tag = text,
        region = text,
        language = text,
        gender = text,
        birthday = text,
        education = text,
        score = int,
        karma = int,
        ranking = int,
        isDefaultAvatar = bool,
        isOnline = bool,
        isAdmin = bool,
        isGlobalAdmin = bool,
        isForbidden = bool,
        isDeleted = bool,
        signupApplication = text,
        hash = text,
        preHash = text,

        createdIp = text,
        lastSigninTime = text,
        lastSigninIP = text,

        github = text,
        goole  = text,
        qq = text ,
        wechat = text,
        facebook = text,
        dingtalk = text,
        weibo = text,
        gitee = text,
        linkedin = text ,
        wecom = text,
        lark = text,
        gitlab = text,

        ldap = text,
        properties = { }
    }
}

_M.user = user

local claims = {
    type = "object",
    properties = {
        user = user,
        accessToke = { type = "string"},
    }
}

_M.claims = claims

local organization = {
    type = "object",
    properties = {
        owner = text,
        name = text,
        createTime = text,

        displayName = text,
        websiteUrl = text,
        favicon = text,
        passwordType = text,
        passwordSalt = text,
        phonePrefix  = text_10,
        defaultAcatar = text,
        masterPasswrod = text,
        enableSoftDeletion = bool
    }
}

_M.organization = organization

local permission = {
    type = "object",
    properties = {
        action = { type = "string" },
        actions = {
            type = "array",
            items = { type = "string" }
        },
        createdTime = text,
        displayName = text,
        effect = text,
        isEnabled = bool,
        name = text,
        owner = text,
        resourceType = text,
        resources = {
            type = "array",
            items = { type = "string" }
        },
        roles = {
            type = "array",
            items = { type = "string" }
        },
        users = {
            type = "array",
            items = { type = "string" }
        }
    }
}

_M.set_roles = {
    userID = {
        type = "string"
    },
    roles = {
        type = "array",
        items = { type = "string" }
    },
}

_M.permission = permission

local resource = {
    type = "object",
    properties = {
        owner = text,
        name = text,
    }
}

_M.resource = resource

local smsForm = {
    type = "object",
    properties = {
        content = { type = "string" },
        receivers = {
            type = "array",
            items = { type = "string" }
        },
        organizationId = { type = "string" }
    }
}

_M.smsForm = smsForm

return _M