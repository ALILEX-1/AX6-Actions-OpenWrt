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
WIFI_SSID=$2
WIFI_KEY=$3
PPPOE_USERNAME=$4
PPPOE_PASSWORD=$5
SSR_SUBSCRIBE_URL=$6
SSR_SAVE_WORDS=$7

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
sed -i "s/radio\${devidx}.ssid=OpenWrt/radio0.ssid=${WIFI_SSID}\n\t\t\tset wireless.default_radio1.ssid=${WIFI_SSID}_2.4G\n\t\t\tset wireless.default_radio1.hidden=1/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i "s/radio\${devidx}.encryption=none/radio\${devidx}.encryption=sae-mixed\n\t\t\tset wireless.default_radio\${devidx}.key=${WIFI_KEY}/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 修改初始化配置
sed -i "s/exit 0//g" package/base-files/files/etc/rc.local
cat >> package/base-files/files/etc/rc.local << EOFEOF
if [ -f "/etc/custom.tag" ];then
    exit 0
fi
touch /etc/custom.tag

uci set smartdns.cfg016bb1.enabled='1'
uci set smartdns.cfg016bb1.server_name='smartdns'
uci set smartdns.cfg016bb1.port='5335'
uci set smartdns.cfg016bb1.tcp_server='1'
uci set smartdns.cfg016bb1.ipv6_server='1'
uci set smartdns.cfg016bb1.dualstack_ip_selection='1'
uci set smartdns.cfg016bb1.prefetch_domain='1'
uci set smartdns.cfg016bb1.serve_expired='1'
uci set smartdns.cfg016bb1.redirect='redirect'
uci set smartdns.cfg016bb1.cache_size='4096'
uci set smartdns.cfg016bb1.rr_ttl='30'
uci set smartdns.cfg016bb1.rr_ttl_min='30'
uci set smartdns.cfg016bb1.rr_ttl_max='300'
uci set smartdns.cfg016bb1.seconddns_port='6553'
uci set smartdns.cfg016bb1.seconddns_tcp_server='1'
uci set smartdns.cfg016bb1.seconddns_no_speed_check='0'
uci set smartdns.cfg016bb1.seconddns_no_rule_addr='0'
uci set smartdns.cfg016bb1.seconddns_no_rule_nameserver='0'
uci set smartdns.cfg016bb1.seconddns_no_rule_ipset='0'
uci set smartdns.cfg016bb1.seconddns_no_rule_soa='0'
uci set smartdns.cfg016bb1.seconddns_no_dualstack_selection='0'
uci set smartdns.cfg016bb1.seconddns_no_cache='0'
uci set smartdns.cfg016bb1.force_aaaa_soa='0'
uci set smartdns.cfg016bb1.coredump='0'
uci del smartdns.cfg016bb1.old_redirect
uci add_list smartdns.cfg016bb1.old_redirect='redirect'
uci del smartdns.cfg016bb1.old_port
uci add_list smartdns.cfg016bb1.old_port='5335'
uci del smartdns.cfg016bb1.old_enabled
uci add_list smartdns.cfg016bb1.old_enabled='1'
uci commit smartdns
cat >> /etc/smartdns/custom.conf << EOF

server-tls 8.8.8.8 #GoogleDNS
server-tls 8.8.4.4 #GoogleDNS
server-https https://dns.google/dns-query #GoogleDNS
server 119.29.29.29 #TencentDNS
server 2402:4e00:: #TencentDNS
server-tls 208.67.222.222 #OpenDNS
server-tls 208.67.220.220 #OpenDNS
server-https https://doh.opendns.com/dns-query #OpenDNS
server 223.5.5.5 #AlibabaDNS
server 223.6.6.6 #AlibabaDNS
server 2400:3200::1 #AlibabaDNS
server 2400:3200:baba::1 #AlibabaDNS
server 180.76.76.76 #BaiduDNS
server 2400:da00::6666 #BaiduDNS
EOF
/etc/init.d/smartdns restart

uci set ttyd.cfg01a8ea.ssl='1'
uci set ttyd.cfg01a8ea.ssl_cert='/etc/nginx/conf.d/_lan.crt'
uci set ttyd.cfg01a8ea.ssl_key='/etc/nginx/conf.d/_lan.key'
uci commit ttyd
/etc/init.d/ttyd restart

uci add_list shadowsocksr.cfg029e1d.subscribe_url='${SSR_SUBSCRIBE_URL}'
uci set shadowsocksr.cfg029e1d.save_words='${SSR_SAVE_WORDS}'
uci set shadowsocksr.cfg029e1d.switch='1'
uci commit shadowsocksr

/usr/bin/lua /usr/share/shadowsocksr/subscribe.lua >>/var/log/ssrplus.log

uci set shadowsocksr.cfg013fd6.global_server='cfg104a8f'
uci set shadowsocksr.cfg013fd6.pdnsd_enable='0'
uci del shadowsocksr.cfg013fd6.tunnel_forward
uci commit shadowsocksr
/etc/init.d/shadowsocksr restart

uci set network.wan.proto='pppoe'
uci set network.wan.username='${PPPOE_USERNAME}'
uci set network.wan.password='${PPPOE_PASSWORD}'
uci set network.wan.ipv6='auto'
uci set network.modem=interface
uci set network.modem.proto='dhcp'
uci set network.modem.device='eth0'
uci set network.modem.defaultroute='0'
uci set network.modem.peerdns='0'
uci set network.modem.delegate='0'
uci commit network
/etc/init.d/network restart

uci del firewall.cfg03dc81.network
uci add_list firewall.cfg03dc81.network='wan'
uci add_list firewall.cfg03dc81.network='wan6'
uci add_list firewall.cfg03dc81.network='modem'
uci commit firewall
/etc/init.d/firewall restart

exit 0
EOFEOF

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

#修复netdata缺少jquery-2.2.4.min.js的问题，有两种解决方式
#1、不使用汉化，使用lede仓库的luci-app-netdata插件，https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-netdata
#2、要使用汉化，回滚netdata版本至1.30.1
#cd feeds/packages
#git config --global user.email "i@5icodes.com"
#git config --global user.name "hnyyghk"
#git revert --no-edit 1278eec776e86659b3e812148796a53d0f865edc
#cd ../../

#netdata不支持ssl访问，有两种解决方式
#1、修改编译配置使netdata原生支持ssl访问，参考https://www.right.com.cn/forum/thread-4045278-1-1.html
#sed -i 's/disable-https/enable-https/g' feeds/packages/admin/netdata/Makefile
#sed -i 's/DEPENDS:=/DEPENDS:=+libopenssl /g' feeds/packages/admin/netdata/Makefile
#sed -i 's/\[web\]/[web]\n\tssl certificate = \/etc\/nginx\/conf.d\/_lan.crt\n\tssl key = \/etc\/nginx\/conf.d\/_lan.key/g' feeds/kenzo/luci-app-netdata/root/etc/netdata/netdata.conf
#2、修改netdata页面端口，配置反向代理http协议19999端口至https协议19998端口，参考https://blog.csdn.net/lawsssscat/article/details/107298336
#添加/etc/nginx/conf.d/ssl2netdata.conf如下：
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
