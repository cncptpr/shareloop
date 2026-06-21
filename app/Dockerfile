FROM instrumentisto/flutter:3.41.6 AS build

WORKDIR /app
COPY --chown=1000:1000 . .

USER 1000
RUN flutter pub get && flutter build web --release

FROM nginx:alpine-slim

COPY --from=build /app/build/web /usr/share/nginx/html

RUN cat > /etc/nginx/nginx.conf << 'EOF'
worker_processes  auto;
pid /tmp/nginx.pid;
error_log /dev/stderr;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /dev/stdout;
    sendfile off;

    client_body_temp_path /tmp/client_body;
    fastcgi_temp_path /tmp/fastcgi_temp;
    proxy_temp_path /tmp/proxy_temp;
    scgi_temp_path /tmp/scgi_temp;
    uwsgi_temp_path /tmp/uwsgi_temp;

    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;

        location /api/ {
            proxy_pass http://server:4000;
            proxy_set_header Host $host;
        }

        location /ws {
            proxy_pass http://server:4000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 86400;
        }

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
EOF

RUN chown -R nginx:nginx /usr/share/nginx/html

USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
