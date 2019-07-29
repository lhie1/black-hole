global

defaults
        log     global
        mode    tcp
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000

frontend ss-in1
    bind *:150-65535
    default_backend ss-out1

backend ss-out1
    server server1 cname maxconn 20480