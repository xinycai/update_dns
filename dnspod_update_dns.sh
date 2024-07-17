#!/bin/bash
# 先决条件

# 1.获取id与key
# 获取id与key文档：https://docs.dnspod.cn/account/dnspod-token/

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

# 配置API Token信息
DP_Id="40xxxx"
DP_Key="7xxx101fa77xxxxxxxxxxxxxxxx"

# 从参数获取域名信息
DOMAIN="$1"
SUB_DOMAIN="$2"
RECORD_TYPE="$3"
NEW_VALUE="$4"

# 组合Token ID和Token Key
API_TOKEN="${DP_Id},${DP_Key}"

# API地址
API_LIST_URL="https://dnsapi.cn/Record.List"
API_MODIFY_URL="https://dnsapi.cn/Record.Modify"

# 获取记录ID
response=$(curl -s -X POST $API_LIST_URL \
  -d "login_token=${API_TOKEN}" \
  -d "format=json" \
  -d "domain=${DOMAIN}" \
  -d "sub_domain=${SUB_DOMAIN}")

RECORD_ID=$(echo $response | jq -r ".records[] | select(.type == \"$RECORD_TYPE\") | .id")

if [ -z "$RECORD_ID" ]; then
  echo "未找到匹配的DNS记录"
  exit 1
fi

# 修改DNS记录
response=$(curl -s -X POST $API_MODIFY_URL \
  -d "login_token=${API_TOKEN}" \
  -d "format=json" \
  -d "domain=${DOMAIN}" \
  -d "sub_domain=${SUB_DOMAIN}" \
  -d "record_id=${RECORD_ID}" \
  -d "record_type=${RECORD_TYPE}" \
  -d "record_line=默认" \
  -d "value=${NEW_VALUE}")

# 检查是否成功
if echo "$response" | grep -q "\"code\":\"1\""; then
  echo "DNS记录修改成功"
else
  echo "DNS记录修改失败: $response"
fi
