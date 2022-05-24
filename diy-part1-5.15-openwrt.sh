#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1-5.15-openwrt.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

git config --global user.email "i@5icodes.com"
git config --global user.name "hnyyghk"
git reset 810eac8c7ffad958345f8fd02f83636afecf7fcd
echo "openwrt: before rm -rf *"
ls
rm -rf *
echo "openwrt: after rm -rf *"
ls
# Retain .git and .ccache
rm -rf .gitattributes .github .gitignore
echo "openwrt: after rm -rf .gitattributes .github .gitignore"
ls
git clone https://github.com/robimarko/openwrt -b ipq807x-5.15-pr ../openwrt-temp
echo "openwrt-temp: before rm -rf ../openwrt-temp/.git"
ls ../openwrt-temp
rm -rf ../openwrt-temp/.git
echo "openwrt-temp: after rm -rf ../openwrt-temp/.git"
ls ../openwrt-temp
mv ../openwrt-temp/* ../openwrt-temp/.[^.]* ./
echo "openwrt: after mv ../openwrt-temp/* ../openwrt-temp/.[^.]* ./"
ls
git add -A
git commit -m "temp"
git pull --rebase

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
echo 'src-git kenzo https://github.com/kenzok8/small-package' >>feeds.conf.default
#echo 'src-git lienol https://github.com/Lienol/openwrt-package' >>feeds.conf.default
#echo 'src-git Boos https://github.com/Boos4721/OpenWrt-Packages' >>feeds.conf.default

echo "src-link custom /workdir/openwrt/custom-feed" >>feeds.conf.default

mkdir custom-feed

for i in "luci.mk"; do \
  svn export "https://github.com/coolsnowwolf/luci/trunk/$i" "custom-feed/$i"; \
done

mkdir custom-feed/applications

for i in "luci-app-vlmcsd"; do \
  svn checkout "https://github.com/coolsnowwolf/luci/trunk/applications/$i" "custom-feed/applications/$i"; \
done

for i in "vlmcsd"; do \
  svn checkout "https://github.com/coolsnowwolf/packages/trunk/net/$i" "custom-feed/applications/$i"; \
done
