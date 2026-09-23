cat > gateway.conf << 'EOF'
# --------------- QDI API GATEWAY ---------------
map $http_upgrade $connection_upgrade {
    default upgrade;
    ""      close;
}

server {
    listen 8080;
    server_name _;

    resolver         127.0.0.11 valid=10s ipv6=off;
    resolver_timeout 5s;

    client_max_body_size    0;
    proxy_request_buffering off;
    proxy_buffering         off;

    location / {
        set $backend "api_api:8888";
        proxy_pass http://$backend;
        proxy_http_version 1.1;

        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        $connection_upgrade;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        proxy_connect_timeout 30s;
        proxy_read_timeout    4h;
        proxy_send_timeout    4h;
    }
}
EOF





cat > api.conf << 'EOF'
# --------------- QDI API ---------------
server {
    listen 443 ssl;
    http2 on;
    server_name vs-avi-cmppcia-api-dev.xmp.net.intra
                api.qdi.dev.echonet;

    ssl_certificate     /etc/ssl/certs/vs-avi-cmppcia-api-dev.xmp.net.intra.crt;
    ssl_certificate_key /etc/ssl/certs/vs-avi-cmppcia-api-dev.xmp.net.intra.key;

    resolver         127.0.0.11 valid=10s ipv6=off;
    resolver_timeout 5s;

    error_page 502 503 504 = @rtr_unavailable;
    location @rtr_unavailable {
        root /usr/share/nginx/html;
        try_files /router_unavailable.html =502;
        add_header Retry-After   30       always;
        add_header Cache-Control no-store always;
    }

    location / {
        set $gw "api_gateway:8080";
        proxy_pass http://$gw;
        proxy_http_version 1.1;

        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        $connection_upgrade;

        proxy_connect_timeout  3s;
        proxy_read_timeout     300s;
        proxy_buffering        off;
        proxy_intercept_errors off;
    }
}
EOF




  gateway:
    image: "cmppcia-docker.artifactory.cib.echonet:443/nginx:alpine"
    networks:
      - api-net
      - perimeter
    configs:
      - source: api_gateway_conf_v1.0
        target: /etc/nginx/conf.d/default.conf
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.hostname == eurvliii120783
      restart_policy:
        condition: any
        delay: 5s
      resources:
        reservations:
          memory: 64M





networks:
  api-net:
    external: true
  perimeter:
    external: true





configs:
  api_gateway_conf_v1.0:
    external: true

