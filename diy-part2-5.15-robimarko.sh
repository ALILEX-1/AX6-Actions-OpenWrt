#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2-5.15-robimarko.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# https://github.com/deplives/OpenWrt-CI-RC/blob/main/second.sh
# https://github.com/jarod360/Redmi_AX6/blob/main/diy-part2.sh

COMMIT_COMMENT=$1
if [ -z "$COMMIT_COMMENT" ]; then
    COMMIT_COMMENT='Unknown'
fi

# Modify default timezone
echo 'Modify default timezone...'
sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# Modify default NTP server
echo 'Modify default NTP server...'
sed -i 's/0.openwrt.pool.ntp.org/ntp.ntsc.ac.cn/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/cn.ntp.org.cn/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/pool.ntp.org/g' package/base-files/files/bin/config_generate

# Modify default LAN ip
echo 'Modify default LAN IP...'
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate

# 修正连接数（by ベ七秒鱼ベ）
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

# 设置密码为password
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Ax6修改无线国家代码、开关、命名、加密方式及密码
sed -i 's/radio${devidx}.disabled=1/radio${devidx}.country=CN\n\t\t\tset wireless.radio${devidx}.disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/radio${devidx}.ssid=OpenWrt/radio0.ssid=MERCURY_8888\n\t\t\tset wireless.default_radio1.ssid=MERCURY_8888_2.4G\n\t\t\tset wireless.default_radio1.hidden=1/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i 's/radio${devidx}.encryption=none/radio${devidx}.encryption=sae-mixed\n\t\t\tset wireless.default_radio${devidx}.key=824080252/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Modify default banner
echo 'Modify default banner...'
build_date=$(date +"%Y-%m-%d %H:%M:%S")
echo "                                                               " > package/base-files/files/etc/banner
echo " ██████╗ ██████╗ ███████╗███╗   ██╗██╗    ██╗██████╗ ████████╗ " >>package/base-files/files/etc/banner
echo "██╔═══██╗██╔══██╗██╔════╝████╗  ██║██║    ██║██╔══██╗╚══██╔══╝ " >>package/base-files/files/etc/banner
echo "██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║ █╗ ██║██████╔╝   ██║    " >>package/base-files/files/etc/banner
echo "██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║███╗██║██╔══██╗   ██║    " >>package/base-files/files/etc/banner
echo "╚██████╔╝██║     ███████╗██║ ╚████║╚███╔███╔╝██║  ██║   ██║    " >>package/base-files/files/etc/banner
echo " ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝    " >>package/base-files/files/etc/banner
echo " ------------------------------------------------------------- " >>package/base-files/files/etc/banner
echo " %D %C ${build_date} by hnyyghk                                " >>package/base-files/files/etc/banner
echo " $COMMIT_COMMENT                                               " >>package/base-files/files/etc/banner
echo " ------------------------------------------------------------- " >>package/base-files/files/etc/banner
echo "                                                               " >>package/base-files/files/etc/banner

#netdata不支持ssl访问，有两种解决方式
#1、修改编译配置使netdata原生支持ssl访问
#https://www.right.com.cn/forum/thread-4045278-1-1.html
sed -i 's/disable-https/enable-https/g' feeds/packages/admin/netdata/Makefile
sed -i 's/DEPENDS:=/DEPENDS:=+libopenssl /g' feeds/packages/admin/netdata/Makefile
sed -i 's/1.33.1/1.34.1/g' feeds/packages/admin/netdata/Makefile
sed -i 's/20ba8695d87187787b27128ac3aab9b09aa29ca6b508c48542e0f7d50ec9322b/8ea0786df0e952209c14efeb02e25339a0769aa3edc029e12816b8ead24a82d7/g' feeds/packages/admin/netdata/Makefile
rm -rf feeds/packages/admin/netdata/patches/005-freebsd.patch
sed -i 's/\[web\]/[web]\n\tssl certificate = \/etc\/nginx\/conf.d\/_lan.crt\n\tssl key = \/etc\/nginx\/conf.d\/_lan.key/g' feeds/kenzo/luci-app-netdata/root/etc/netdata/netdata.conf
#2、修改netdata页面端口，配置反向代理http协议19999端口至https协议19998端口
#https://blog.csdn.net/lawsssscat/article/details/107298336
#/etc/nginx/conf.d/ssl2netdata.conf
#server {
#	listen 19998 ssl;
#	listen [::]:19998 ssl;
#	server_name _ssl2netdata;
#	include restrict_locally;
#	ssl_certificate /etc/nginx/conf.d/_lan.crt;
#	ssl_certificate_key /etc/nginx/conf.d/_lan.key;
#	ssl_session_cache shared:SSL:32k;
#	ssl_session_timeout 64m;
#	location / {
#		proxy_set_header Host $host;
#		proxy_set_header X-Real-IP $remote_addr;
#		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#		proxy_set_header X-Forwarded-Proto $scheme;
#		proxy_pass http://localhost:19999;
#	}
#}
