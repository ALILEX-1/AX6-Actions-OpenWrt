#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1-5.15-robimarko.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default
#echo 'src-git lienol https://github.com/Lienol/openwrt-package' >>feeds.conf.default
echo 'src-git Boos https://github.com/Boos4721/OpenWrt-Packages' >>feeds.conf.default

for i in "luci-app-vlmcsd" "luci-app-nlbwmon"; do \
  svn checkout "https://github.com/coolsnowwolf/luci/trunk/applications/$i" "package/$i"; \
done

for i in "vlmcsd" "nlbwmon"; do \
  svn checkout "https://github.com/coolsnowwolf/packages/trunk/net/$i" "package/$i"; \
done