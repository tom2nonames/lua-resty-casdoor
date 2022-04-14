local casdoor_schema = require("resty.casdoor.schema")

return {
    oidc = {
        jwks          = { method = "GET" , uri = "/.well-known/jwks" },
        configuration = { method = "GET" , uri = "/.well-known/openid-configuration" }
    },
    application = {
        add           = { method = "POST", uri = "/api/add-application",        body = casdoor_schema.application },
        delete        = { method = "POST", uri = "/api/delete-application",     body = casdoor_schema.application , var = {"name"} },
        get           = { method = "GET" , uri = "/api/get-application" },
        list          = { method = "GET" , uri = "/api/get-applications" },
        get_by_user   = { method = "GET" , uri = "/api/get-user-application" },
        update        = { method = "POST", uri = "/api/update-application",     body = casdoor_schema.application },
    },
    cert = {
        add           = { method = "POST", uri = "/api/add-cert" },
        delete        = { method = "POST", uri = "/api/delete-cert" },
        get           = { method = "GET" , uri = "/api/get-cert" },
        list          = { method = "GET" , uri = "/api/get-certs" },
        update        = { method = "POST", uri = "/api/update-cert" },
    },
    account = {
        get           = { method = "GET" , uri = "/api/get-account" },
        reset_email_or_phone 
                      = { method = "POST", uri = "/api/reset-email-or-phone" },
        set_password  = { method = "POST", uri = "/api/set-password" },
        userinfo      = { method = "GET",  uri = "/api/userinfo" },
    },
    organization = {
        add           = { method = "POST", uri = "/api/add-organization" ,      body = casdoor_schema.organization },
        delete        = { method = "POST", uri = "/api/delete-organization",    body = casdoor_schema.organization, var = {"Name"} },
        get           = { method = "GET" , uri = "/api/get-organization" },
        list          = { method = "GET" , uri = "/api/get-organizations" },
        update        = { method = "POST", uri = "/api/update-organization",    body = casdoor_schema.organization },
    },
    payment = {
        add           = { method = "POST", uri = "/api/add-payment" },
        delete        = { method = "POST", uri = "/api/delete-payment" },
        get           = { method = "GET" , uri = "/api/get-payment" },
        list          = { method = "GET" , uri = "/api/get-payments" },
        get_by_user   = { method = "GET" , uri = "/api/get-user-payments" },
        notify        = { method = "POST", uri = "/api/notify-payment" },
        update        = { method = "POST", uri = "/api/update-payment" },
    },
    permission = {
        add           = { method = "POST", uri = "/api/add-permission",         query = { "owner" , "applcation"} },
        delete        = { method = "POST", uri = "/api/delete-permission",      body  = casdoor_schema.permission },
        get           = { method = "GET" , uri = "/api/get-permission" },
        list          = { method = "GET" , uri = "/api/get-permissions" },
        update        = { method = "POST", uri = "/api/update-permission" },
    },
    product = {
        add           = { method = "POST", uri = "/api/add-product" },
        buy           = { method = "POST", uri = "/api/buy-product" },
        delete        = { method = "POST", uri = "/api/delete-product" },
        get           = { method = "GET" , uri = "/api/get-product" },
        list          = { method = "GET" , uri = "/api/get-products" },
        update        = { method = "POST", uri = "/api/update-product" },
    },
    resource = {
        add           = { method = "POST", uri = "/api/add-resource",           body = casdoor_schema.resource },
        delete        = { method = "POST", uri = "/api/delete-resource",        body = casdoor_schema.resource },
        get           = { method = "GET" , uri = "/api/get-resource" },
        list          = { method = "GET" , uri = "/api/get-resources" },
        update        = { method = "POST", uri = "/api/update-resource",        body = casdoor_schema.resource },
        upload        = { method = "POST", uri = "/api/upload-resource",        body = "file", query = { "owner", "user", "application", "tag", "parent", "fullFilePath", "createdTime", "description" }  },
    },
    role = {
        add           = { method = "POST", uri = "/api/add-role",               body = casdoor_schema.role },
        delete        = { method = "POST", uri = "/api/delete-role",            body = casdoor_schema.role },
        get           = { method = "GET" , uri = "/api/get-role" },
        list          = { method = "GET" , uri = "/api/get-roles" },
        update        = { method = "POST", uri = "/api/update-role",            body = casdoor_schema.role },
    },
    syncer = {
        add           = { method = "POST", uri = "/api/add-syncer" },
        delete        = { method = "POST", uri = "/api/delete-syncer" },
        get           = { method = "GET" , uri = "/api/get-syncer" },
        list          = { method = "GET" , uri = "/api/get-syncers" },
        update        = { method = "POST", uri = "/api/update-syncer" },
    },
    token = {
        add           = { method = "POST", uri = "/api/add-token" },
        delete        = { method = "POST", uri = "/api/delete-token" },
        get           = { method = "GET" , uri = "/api/get-token" },
        list          = { method = "GET" , uri = "/api/get-tokens" },
        access_token  = { method = "POST", uri = "/api/login/oauth/access_token" },
        code          = { method = "POST", uri = "/api/login/oauth/code" },
        logout        = { method = "GET" , uri = "/api/login/oauth/logout" },
        refresh_token = { method = "GET" , uri = "/api/login/oauth/refresh_token" },
        update        = { method = "POST", uri = "/api/update-token" },
    },
    user = {
        add           = { method = "POST", uri = "/api/add-user",               body = casdoor_schema.user, query = { "id" } },
        check_password= { method = "POST", uri = "/api/check-user-password",    body = casdoor_schema.user, query = { "id" } },
        delete        = { method = "POST", uri = "/api/delete-user",            body = casdoor_schema.user, query = { "id" } },
        get_email_and_phone
                      = { method = "POST", uri = "/api/get-email-and-phone" },
        get_global    = { method = "GET" , uri = "/api/get-global-users" },
        get_sorted    = { method = "GET" , uri = "/api/get-sorted-users",       query = { "owner", "sorter", "limit"} },
        get           = { method = "GET" , uri = "/api/get-user",               query = { "owner", "id", "email" } },
        count         = { method = "GET" , uri = "/api/get-user-count",         query = { "owner", "isOnline"} },
        list          = { method = "GET" , uri = "/api/get-users" ,             query = { "owner" } },
        update        = { method = "POST", uri = "/api/update-user",            body  = casdoor_schema.user, query = { "id", "columns"} },
    },
    webhook = {
        add           = { method = "POST", uri = "/api/add-webhook" },
        delete        = { method = "POST", uri = "/api/delete-webhook" },
        get           = { method = "GET" , uri = "/api/get-webhook" },
        list          = { method = "GET" , uri = "/api/get-webhooks" },
        update        = { method = "POST", uri = "/api/update-webhook" },
    },
    login = {
        human_check   = { method = "GET" , uri = "/api/get-human-check" },
        login         = { method = "POST", uri = "/api/login" },
        logout        = { method = "POST", uri = "/api/logout" },
        signup        = { method = "POST", uri = "/api/signup" },
        unlink        = { method = "POST", uri = "/api/unlink" },
        update        = { method = "GET" , uri = "/api/update-application" },
    },
    service = {
        send_email    = { method = "POST", uri = "/api/api/send-email",         body = { casdoor_schema.emailForm } },
        send_sms      = { method = "POST", uri = "/api/api/send-sms",           body = { casdoor_schema.smsForm } },
    },
    record = {
        get           = { method = "GET" , uri = "/api/get-records" },
        fitler        = { method = "POST", uri = "/api/get-records-filter" },
    },
    default = {
        introspect    = { method = "POST", uri = "/api/login/oauth/introspect" },
    },
    verification = {
        send_verfig_code   
                      = { method = "POST", uri = "/api/send-verification-code" },
    }

}