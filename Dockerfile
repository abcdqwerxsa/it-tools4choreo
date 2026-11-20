# Stage 1: 直接复用官方镜像里已经构建好的静态产物
FROM ghcr.io/corentinth/it-tools:latest AS source

# Stage 2: 换用最新非特权 Nginx 基底，彻底剥离旧镜像漏洞
FROM nginxinc/nginx-unprivileged:alpine

USER root
RUN apk upgrade --no-cache && \
    adduser -D -u 10001 choreouser && \
    rm -rf /usr/share/nginx/html/* && \
    chown -R 10001:10001 /usr/share/nginx/html /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /tmp/nginx.pid && chown 10001:10001 /tmp/nginx.pid

# 从官方镜像拷贝静态文件，并写入 8080 端口的 SPA 配置
COPY --from=source --chown=10001:10001 /usr/share/nginx/html /usr/share/nginx/html
COPY --chown=10001:10001 nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

# 必须硬编码 10000-20000 之间的纯数字 UID
USER 10001

CMD ["nginx", "-g", "daemon off;"]
