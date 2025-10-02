# Coraza WAF + Caddy configuration for MinIO
{
    order coraza_waf first
    debug
}

# HTTP to HTTPS redirect
http://${server_name} {
    redir https://{host}{uri} permanent
}

# HTTPS Console (UI) 
https://${server_name} {
    coraza_waf {
        directives `
            SecRuleEngine On
            SecDefaultAction "phase:1,log,auditlog,pass"
            SecDefaultAction "phase:2,log,auditlog,pass"
            
            # Include OWASP Core Rule Set
            Include /etc/coraza/owasp-crs/*.conf
            
            # MinIO specific rules
            SecRule REQUEST_URI "@beginsWith /minio/admin" \
                "id:1001,phase:1,block,msg:'Block MinIO admin endpoints'"
            
            # Rate limiting for API calls
            SecRule REQUEST_METHOD "@streq GET" \
                "id:1002,phase:1,pass,setvar:ip.get_requests=+1,expirevar:ip.get_requests=60"
            SecRule REQUEST_METHOD "@streq PUT" \
                "id:1003,phase:1,pass,setvar:ip.put_requests=+1,expirevar:ip.put_requests=60"
            SecRule REQUEST_METHOD "@streq POST" \
                "id:1004,phase:1,pass,setvar:ip.post_requests=+1,expirevar:ip.post_requests=60"
            
            # Block excessive requests
            SecRule IP:GET_REQUESTS "@gt 100" \
                "id:1005,phase:1,block,msg:'Too many GET requests'"
            SecRule IP:PUT_REQUESTS "@gt 20" \
                "id:1006,phase:1,block,msg:'Too many PUT requests'"
            SecRule IP:POST_REQUESTS "@gt 10" \
                "id:1007,phase:1,block,msg:'Too many POST requests'"
        `
    }
    
    reverse_proxy ${nginx_ui_backend} {
        header_up Host {http.request.host}
        header_up X-Real-IP {http.request.remote}
        header_up X-Forwarded-For {http.request.remote}
        header_up X-Forwarded-Proto {http.request.scheme}
    }
}

# HTTPS API (S3)
https://${server_name}:9443 {
    coraza_waf {
        directives `
            SecRuleEngine On
            SecDefaultAction "phase:1,log,auditlog,pass"
            SecDefaultAction "phase:2,log,auditlog,pass"
            
            # Include OWASP Core Rule Set
            Include /etc/coraza/owasp-crs/*.conf
            
            # S3 API specific protections
            SecRule REQUEST_URI "@contains ../" \
                "id:2001,phase:1,block,msg:'Directory traversal attempt'"
            
            # Block suspicious S3 operations
            SecRule REQUEST_URI "@rx (?i)\.\./" \
                "id:2002,phase:1,block,msg:'Path traversal in S3 request'"
            
            # Rate limiting for S3 API
            SecRule REQUEST_METHOD "@streq GET" \
                "id:2003,phase:1,pass,setvar:ip.s3_get=+1,expirevar:ip.s3_get=60"
            SecRule REQUEST_METHOD "@streq PUT" \
                "id:2004,phase:1,pass,setvar:ip.s3_put=+1,expirevar:ip.s3_put=60"
            SecRule REQUEST_METHOD "@streq DELETE" \
                "id:2005,phase:1,pass,setvar:ip.s3_delete=+1,expirevar:ip.s3_delete=60"
            
            # Block excessive S3 operations
            SecRule IP:S3_GET "@gt 200" \
                "id:2006,phase:1,block,msg:'Too many S3 GET requests'"
            SecRule IP:S3_PUT "@gt 50" \
                "id:2007,phase:1,block,msg:'Too many S3 PUT requests'"
            SecRule IP:S3_DELETE "@gt 10" \
                "id:2008,phase:1,block,msg:'Too many S3 DELETE requests'"
        `
    }
    
    reverse_proxy ${nginx_api_backend} {
        header_up Host {http.request.host}
        header_up X-Real-IP {http.request.remote}
        header_up X-Forwarded-For {http.request.remote}
        header_up X-Forwarded-Proto {http.request.scheme}
    }
}