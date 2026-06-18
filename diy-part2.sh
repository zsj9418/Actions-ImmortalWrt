#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# 修复点1：移除 set -e，改为每步单独错误处理，避免网络超时导致整个脚本中断

# ============ 带重试的安全 git clone 函数 ============
safe_clone() {
    local url="$1"
    local dest="$2"
    local max_retry=3
    local count=0
    while [ $count -lt $max_retry ]; do
        if git clone --depth=1 "$url" "$dest"; then
            return 0
        fi
        count=$((count + 1))
        echo "⚠️  Clone 失败，第 $count 次重试: $url"
        rm -rf "$dest"
        sleep 15
    done
    echo "❌ ERROR: 无法克隆 $url，已重试 $max_retry 次"
    exit 1
}

# ============ OpenWrt golang 最新版（daed 编译依赖）============
rm -rfv feeds/packages/lang/golang
safe_clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ============ Replace luci-theme-argon（最新版 argon 主题）============
rm -rfv feeds/luci/themes/luci-theme-argon
safe_clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

# ============ 修复点2：分开克隆 luci-app-daed 和 daed 主程序 ============
# luci 前端
safe_clone https://github.com/QiuSimons/luci-app-daed package/luci-app-daed
# daed 主程序（eBPF 代理本体，原脚本完全缺失此步骤）
safe_clone https://github.com/daeuniverse/openwrt-daed package/daed

# ============ 修改默认 IP（360T7 用户自定义地址）============
if [ -f "package/base-files/files/bin/config_generate" ]; then
  sed -i 's/192.168.1.1/192.168.3.60/g' package/base-files/files/bin/config_generate
  echo "✅ 默认 IP 已修改为 192.168.3.60"
else
  echo "⚠️  config_generate 文件未找到，跳过 IP 修改"
fi
