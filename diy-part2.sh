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
# 【重要修正】移除 set -e，改为带重试的安全函数，避免网络超时崩溃链

# ============ 带重试的安全 git clone 函数 ============
safe_clone() {
    local url="$1"
    local dest="$2"
    local max_retry=3
    local count=0
    while [ $count -lt $max_retry ]; do
        if git clone --depth=1 "$url" "$dest" 2>&1; then
            echo "✅ 克隆成功: $url -> $dest"
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

# ============ OpenWrt golang 最新版（daed 编译依赖最新 golang）============
echo ">>> 正在更新 golang 包..."
rm -rfv feeds/packages/lang/golang 2>/dev/null || true
safe_clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# ============ Replace luci-theme-argon（最新版 argon 主题）============
echo ">>> 正在更新 argon 主题..."
rm -rfv feeds/luci/themes/luci-theme-argon 2>/dev/null || true
safe_clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

# ============ 【核心修正】luci-app-daed 正确用法 ============
# QiuSimons/luci-app-daed 仓库内部已包含 daed 主程序的完整 OpenWrt package Makefile
# 编译时会自动下载 daeuniverse/daed 源码并编译，无需单独克隆 daed 主程序
# 正确做法：整个仓库克隆到 package/dae（单一目录）
echo ">>> 正在克隆 daed 包..."
safe_clone https://github.com/QiuSimons/luci-app-daed package/dae

# ============ 修改默认 IP（360T7 用户自定义地址）============
echo ">>> 正在修改默认 IP..."
if [ -f "package/base-files/files/bin/config_generate" ]; then
    sed -i 's/192.168.1.1/192.168.3.60/g' package/base-files/files/bin/config_generate
    echo "✅ 默认 IP 已修改为 192.168.3.60"
else
    echo "⚠️  config_generate 未找到，跳过 IP 修改"
fi

# ============ 编译诊断信息 ============
echo ""
echo "========================================="
echo "【编译前诊断信息】"
echo "========================================="
echo "✅ feeds.conf.default 内容："
cat feeds.conf.default | head -20
echo ""
echo "✅ 已克隆的 feeds/packages："
ls -la feeds/packages/lang/golang/Makefile 2>/dev/null && echo "  ✓ golang" || echo "  ✗ golang 缺失（可能导致编译失败）"
ls -la feeds/luci/themes/luci-theme-argon/Makefile 2>/dev/null && echo "  ✓ argon" || echo "  ✗ argon 缺失"
ls -la package/dae/daed/Makefile 2>/dev/null && echo "  ✓ daed" || echo "  ✗ daed 缺失（可能导致编译失败）"
echo "========================================="
echo ""
