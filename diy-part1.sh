#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# 修复点：对 sed/rm 操作加防御性判断，避免文件不存在时静默失败
# Remove 6in4（兼容性检查：文件存在才操作）
if [ -f "package/emortal/ipv6-helper/Makefile" ]; then
  sed -i 's/ +6in4//g' package/emortal/ipv6-helper/Makefile
  sed -i '/hotplug.d/d' package/emortal/ipv6-helper/Makefile
fi
rm -fv package/emortal/ipv6-helper/files/60-6in4

# Add luci-app-pushbot feed
echo "src-git pushbot https://github.com/zzsj0928/luci-app-pushbot.git;master" >> "feeds.conf.default"
