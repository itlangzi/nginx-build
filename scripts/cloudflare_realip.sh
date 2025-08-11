#!/bin/bash
NGX="./sbin/nginx"
CONF="conf/conf.d/cdn/cf/set_real_ip_from.conf"
TMP="$(mktemp)"

# 拉取并生成配置（v4+v6）
{ 
  curl -fsS https://www.cloudflare.com/ips-v4
  curl -fsS https://www.cloudflare.com/ips-v6
} | awk '{print "set_real_ip_from "$0";"}' > "$TMP"

# 下载成功且非空时才覆盖
if [ -s "$TMP" ]; then
  mv "$TMP" "$CONF"
  $NGX -t && $NGX -s reload
else
  echo "Cloudflare IP 列表获取失败，已取消覆盖。" >&2
  rm -f "$TMP"
  exit 1
fi