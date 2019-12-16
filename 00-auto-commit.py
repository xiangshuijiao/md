user nobody nobody;
worker_processes auto;
error_log logs/error.log crit;

pid logs/nginx.pid;

#Specifies the value for maximum file descriptors that can be opened by this process.
worker_rlimit_nofile 51200;

events
{
    use epoll;
    worker_connections 51200;
}

http
{
    include mime.types;
    default_type application/octet-stream;
    server_tokens off;
    server_names_hash_bucket_size 128;
    client_header_buffer_size 32k;
    large_client_header_buffers 4 32k;
    client_max_body_size 8m;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    tcp_nodelay on;

    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 2;
    gzip_types text/plain application/x-javascript text/css application/xml;
    gzip_vary on;
    #limit_zone crawler $binary_remote_addr 10m;
    log_format default '$remote_addr - $remote_user [$time_local] "$request" '
        '$status $body_bytes_sent "$http_referer" '
        '"$http_user_agent" -- "$http_cookie" $http_x_forwarded_for "$proxy_add_x_forwarded_for" "$request_time"';

    server {
        listen       8089;
        server_name www.huozhebusi.xyz;

        location / {
            proxy_pass https://www.google.com/;

            proxy_redirect https://www.google.com/ /;
            proxy_cookie_domain google.com www.huozhebusi.xyz;

            proxy_set_header User-Agent $http_user_agent;
            proxy_set_header Cookie "PREF=ID=047808f19f6de346:U=0f62f33dd8549d11:FF=2:LD=zh-CN:NW=1:TM=1325338577:LM=1332142444:GM=1:SG=2:S=rE0SyJh2W1IQ-Maw";
            # 这里设置cookie，这里是别人给出的一段，必要时请放上适合你自己的cookie
            # 设置这个可以避免一些情况下的302跳转，如果google服务器返回302 redirect，那么浏览器被跳转到google自己的域名，那就没的玩了

            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            subs_filter  http://www.google.com http://www.huozhebusi.xyz;
            subs_filter  https://www.google.com http://www.huozhebusi.xyz;
            # 这里替换网页中的链接，因为我们的镜像站是http的，所以上面顺便把协议也一起替换了
    }
    }
}







