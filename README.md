# 更新 DNS 解析记录

用于更新 DNS 解析记录的 Shell 脚本，支持 Cloudflare 和 DNSPod，尽可能减少凭据的需要。

## 支持平台

### DNSPod
DNSPod 需要获取 ID 和 Key。
- [获取 ID 和 Key 文档](https://docs.dnspod.cn/account/dnspod-token/)

### Cloudflare
Cloudflare 只需要获取一个 Token 即可，确保 Token 具有相应区域的 DNS 编辑权限。
- [获取 Token 文档](https://blog.cloudflare.com/zh-cn/api-tokens-general-availability-zh-cn)

## 安装 jq

Shell 脚本适用于绝大多数 Linux 发行版，只需要确保拥有 jq 即可。

### Debian/Ubuntu
```sh
sudo apt update && sudo apt install jq
```

### CentOS/RHEL
```sh
sudo yum install epel-release && sudo yum install jq
```

### OpenWrt
```sh
opkg update && opkg install jq
```
