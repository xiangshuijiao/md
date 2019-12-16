server {
        auth_basic "Hello World";
        auth_basic_user_file /etc/nginx/conf.d/passwd;
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

