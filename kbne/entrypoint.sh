#!/usr/bin/env sh

# 1. 替换 Xray 配置中的 UUID
sed -i "s/UUID/$UUID/g" /app/xy/config.json

# 2. 替换 keepalive 脚本中的 DOMAIN
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /app/keepalive.sh

# 3. 替换 Supervisor 配置中的 Cloudflared Token
sed -i "s|<YOUR_CLOUDFLARED_TUNNEL_TOKEN>|$CLOUDFLARED_TOKEN|g" /app/supervisor/supervisord.conf

# 4. 设置 DNS (如您原脚本所示)
# 这一步是为了防止容器内部 DNS 解析问题
cp /etc/resolv.conf /etc/resolv.conf.bak
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# 5. 执行 CMD (即 supervisord)
exec "$@"
