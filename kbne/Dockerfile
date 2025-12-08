# ==========================================================
# 第一阶段：构建器 (Builder Stage) - 下载 Xray, Supercronic 和 Cloudflared
# ==========================================================
FROM ubuntu:22.04 AS builder

WORKDIR /app

# 优化下载和清理操作，使用 '&&' 连接命令以减少镜像层数
RUN set -x && \
    for i in 1 2 3; do apt-get update && break || sleep 5; done && \
    apt-get install -y --no-install-recommends wget unzip ca-certificates && \
    # 下载 Xray-core
    wget https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip && \
    rm -f Xray-linux-64.zip && \
    mv xray xy && \
    # 下载 supercronic
    wget -O supercronic https://github.com/aptible/supercronic/releases/latest/download/supercronic-linux-amd64 && \
    chmod +x supercronic && \
    # 下载 cloudflared
    wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x cloudflared && \
    # 清理 apt 缓存
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# ==========================================================
# 第二阶段：最终镜像 (Final Stage) - Nginx, Xray, Supervisor
# ==========================================================
FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/justlagom/koyebne"

# 定义环境变量（请在构建或运行容器时替换这些占位符）
ENV TZ=Asia/Shanghai \
    UUID=YOUR_UUID_HERE \
    DOMAIN=YOUR_DOMAIN_HERE \
    CLOUDFLARED_TOKEN=YOUR_CLOUDFLARED_TUNNEL_TOKEN

COPY entrypoint.sh /entrypoint.sh
COPY app /app

# 核心安装和配置
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        tzdata curl ca-certificates nginx supervisor && \
    # 配置时区
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    # 清理 apt 缓存
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Nginx 配置链接
    rm -f /etc/nginx/sites-enabled/default && \
    ln -s /app/nginx/nginx.conf /etc/nginx/sites-enabled/nginx.conf && \
    # 权限和用户设置
    chmod +x /entrypoint.sh && \
    chmod -R 777 /app && \
    chmod +x /app/keepalive.sh && \
    useradd -u 1000 -g 0 -m -s /bin/bash user

# 从 builder 阶段复制可执行文件到最终镜像的 PATH 目录
COPY --from=builder /app/xy /usr/local/bin/xy
COPY --from=builder /app/supercronic /usr/local/bin/supercronic
COPY --from=builder /app/cloudflared /usr/local/bin/cloudflared

EXPOSE 7860

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/app/supervisor/supervisord.conf"]
