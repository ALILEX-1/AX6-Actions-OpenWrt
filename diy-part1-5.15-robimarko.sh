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
echo 'src-git kenzo https://github.com/kenzok8/small-package' >>feeds.conf.default
#echo 'src-git lienol https://github.com/Lienol/openwrt-package' >>feeds.conf.default
#echo 'src-git Boos https://github.com/Boos4721/OpenWrt-Packages' >>feeds.conf.default

echo "src-link custom $GITHUB_WORKSPACE/custom-feed" >>feeds.conf.default
#echo "src-link custom $GITHUB_WORKSPACE/custom-feed" >feeds.conf.default.tmp
#copy /b feeds.conf.default.tmp+feeds.conf.default feeds.conf.default.new
#del feeds.conf.default
#ren feeds.conf.default.new feeds.conf.default

mkdir ../custom-feed

for i in "luci-app-vlmcsd" "luci-app-ddns"; do \
  svn checkout "https://github.com/coolsnowwolf/luci/trunk/applications/$i" "../custom-feed/$i"; \
done

for i in "ddns-scripts_aliyun"; do \
  svn checkout "https://github.com/coolsnowwolf/lede/trunk/package/lean/$i" "../custom-feed/$i"; \
done

for i in "vlmcsd" "ddns-scripts"; do \
  svn checkout "https://github.com/coolsnowwolf/packages/trunk/net/$i" "../custom-feed/$i"; \
done

echo feeds.conf.default
echo "src-link custom $GITHUB_WORKSPACE/custom-feed"
ls "$GITHUB_WORKSPACE/custom-feed"