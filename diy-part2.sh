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

# Replace luci-theme-argon（最新版 argon 主题）
rm -rfv feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

# -------------------------------------------------------
# Add daed（eBPF 透明代理）
# 关键修复1：目录名必须是 package/dae 而不是 package/daed
# 关键修复2：只用 clone 方式引入，不在 diy-part1.sh 中注册 feed，避免双重冲突
# -------------------------------------------------------
git clone --depth=1 https://github.com/QiuSimons/luci-app-daed package/dae

# -------------------------------------------------------
# cgroupfs-mount 补丁（daed/dae 在 OpenWrt 上运行 cgroup v2 必须）
# 关键修复3：缺少此补丁会导致 daed 启动时 cgroup 挂载失败
# -------------------------------------------------------
pushd feeds/packages
curl -s https://raw.githubusercontent.com/sbwml/luci-app-dae/main/.cgroupfs/cgroupfs-mount.init.patch | patch -p1
popd
mkdir -p feeds/packages/utils/cgroupfs-mount/patches
curl -s https://raw.githubusercontent.com/sbwml/luci-app-dae/main/.cgroupfs/900-add-cgroupfs2.patch \
  > feeds/packages/utils/cgroupfs-mount/patches/900-add-cgroupfs2.patch

# 修改默认 IP（360T7 用户自定义地址）
sed -i 's/192.168.1.1/192.168.3.60/g' package/base-files/files/bin/config_generate
