#!/bin/bash
# 先决条件

# 1.获取token
# 获取token文档：https://blog.cloudflare.com/zh-cn/api-tokens-general-availability-zh-cn

# 2.安装jq
# Debian/Ubuntu：sudo apt update && sudo apt install jq
# CentOS/RHEL：sudo yum install epel-release && sudo yum install jq
# OpenWrt：opkg update && opkg install jq

# 3.域名解析中该记录已存在

# 检查参数
if [ "$#" -ne 4 ]; then
    echo "使用方法: $0 <域名> <子域名> <记录类型> <新值>"
    echo "示例: $0 388488.xyz hello A 2.2.2.2"
    exit 1
fi

# 配置变量
CF_API_TOKEN="vMS0Jxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

DOMAIN=$1
SUBDOMAIN=$2
RECORD_TYPE=$3
NEW_VALUE=$4

# 获取 Zone ID
zone_response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
     -H "Authorization: Bearer $CF_API_TOKEN" \
     -H "Content-Type: application/json")

ZONE_ID=$(echo $zone_response | jq -r '.result[0].id')

if [ -z "$ZONE_ID" ]; then
    echo "获取域名 Zone ID 失败: $DOMAIN"
    exit 1
fi

# 获取 DNS 记录 ID
record_response=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$SUBDOMAIN.$DOMAIN" \
     -H "Authorization: Bearer $CF_API_TOKEN" \
     -H "Content-Type: application/json")

RECORD_ID=$(echo $record_response | jq -r '.result[0].id')

if [ -z "$RECORD_ID" ]; then
    echo "获取 DNS 记录 ID 失败: $SUBDOMAIN.$DOMAIN"
    exit 1
fi

# 更新 DNS 记录
response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $CF_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{
       "type": "'"$RECORD_TYPE"'",
       "name": "'"$SUBDOMAIN.$DOMAIN"'",
       "content": "'"$NEW_VALUE"'",
       "ttl": 120,
       "proxied": false
     }')

# 检查更新是否成功
if echo "$response" | grep -q '"success":true'; then
    echo "DNS 记录更新成功。"
else
    echo "DNS 记录更新失败。"
    echo "响应: $response"
fi
