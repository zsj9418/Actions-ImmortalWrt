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

# OpenWrt golang latest version（daed 编译依赖最新 golang）
rm -rfv feeds/packages/lang/golang
git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# Replace luci-theme-argon
rm -rfv feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

# Add daed (eBPF transparent proxy)
git clone https://github.com/QiuSimons/luci-app-daed package/daed

# 修改默认 IP
sed -i 's/192.168.1.1/192.168.3.60/g' package/base-files/files/bin/config_generate
