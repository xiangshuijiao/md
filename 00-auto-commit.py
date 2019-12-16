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
        server_name  www.huozhebusi.xyz;
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
        access_log logs/access.log default;        

        location / {
                rewrite "^/(.*)" https://$host/$1 redirect;
                proxy_pass https://www.google.com;
        }
    }
}