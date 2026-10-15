
FROM alpine:3.20

RUN apk add --no-cache nginx curl iproute2 iputils busybox-extras

RUN mkdir -p /run/nginx

RUN printf 'server {\n\
    listen 80 default_server;\n\
    listen [::]:80 default_server;\n\
    root /var/lib/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ =404;\n\
    }\n\
}\n' > /etc/nginx/http.d/default.conf

CMD ["sh", "-c", "tail -f /dev/null"]
