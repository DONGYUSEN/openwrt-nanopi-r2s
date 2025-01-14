#!/bin/bash
#
# This is free software, license use GPLv3.
#
# Copyright (c) 2021, Chuck <fanck0605@qq.com>
#

set -eu

proj_dir=$(pwd)

# clone openwrt
cd "$proj_dir"
rm -rf openwrt
git clone -b openwrt-21.02 https://github.com/openwrt/openwrt.git openwrt
cd openwrt
chmod +x ./target/linux/rockchip/armv8/base-files/etc/board.d/01_leds
chmod +x ./target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# patch openwrt
cd "$proj_dir/openwrt"
cat "$proj_dir/patches"/*.patch | patch -p1
wget -qO- https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/3940.patch | patch -p1

# obtain feed list
cd "$proj_dir/openwrt"
feed_list=$(awk '/^src-git/ { print $2 }' feeds.conf.default)

# clone feeds
cd "$proj_dir/openwrt"
./scripts/feeds update -a

# patch feeds
for feed in $feed_list; do
  [ -d "$proj_dir/patches/$feed" ] &&
    {
      cd "$proj_dir/openwrt/feeds/$feed"
      cat "$proj_dir/patches/$feed"/*.patch | patch -p1
    }
done

# addition packages
cd "$proj_dir/openwrt/package"
# luci-app-helloworld
git clone https://github.com/xiaorouji/openwrt-passwall.git custom/openwrt-passwall
# luci-app-openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash custom/luci-app-openclash
# luci-app-filebrowser
svn co https://github.com/immortalwrt/luci/branches/openwrt-21.02/applications/luci-app-filebrowser custom/luci-app-filebrowser
svn co https://github.com/immortalwrt/packages/branches/openwrt-21.02/utils/filebrowser custom/filebrowser
# luci-app-arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind custom/luci-app-arpbind
# luci-app-xlnetacc
# svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/lean/luci-app-xlnetacc custom/luci-app-xlnetacc
# luci-app-autoreboot
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot custom/luci-app-autoreboot
# luci-app-vsftpd
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/lean/luci-app-vsftpd custom/luci-app-vsftpd
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/lean/vsftpd-alt custom/vsftpd-alt
# luci-app-netdata
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-netdata custom/luci-app-netdata
# ddns-scripts
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/lean/ddns-scripts_aliyun custom/ddns-scripts_aliyun
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/lean/ddns-scripts_dnspod custom/ddns-scripts_dnspod
# luci-theme-argon
git clone -b master --depth 1 https://github.com/jerrykuku/luci-theme-argon.git custom/luci-theme-argon
# zerotier
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-zerotier custom/luci-app-zerotier
svn co https://github.com/coolsnowwolf/packages/trunk/net/zerotier custom/zerotier
#vlmcsd, ttyd, adguardhome
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/vlmcsd  custom/vlmcsd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-vlmcsd custom/luci-app-vlmcsd
#svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ttyd custom/luci-app-ttyd
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git custom/luci-app-adguardhome
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/adbyby custom/adbyby
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-adbyby-plus custom/luci-app-adbyby-plus

# fix docker build with golang 
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman custom/luci-app-dockerman
rm -rf feeds/packages/lang/luasec && svn co https://github.com/coolsnowwolf/packages/trunk/lang/luasec feeds/packages/lang/luasec
rm -rf feeds/packages/lang/golang/ && svn co https://github.com/coolsnowwolf/packages/trunk/lang/golang feeds/packages/lang/golang
rm -rf feeds/packages/utils/containerd && svn export https://github.com/coolsnowwolf/packages/trunk/utils/containerd feeds/packages/utils/containerd
rm -rf feeds/packages/utils/docker-ce && svn export https://github.com/coolsnowwolf/packages/trunk/utils/docker-ce feeds/packages/utils/docker-ce
rm -rf feeds/packages/utils/libnetwork && svn export https://github.com/coolsnowwolf/packages/trunk/utils/libnetwork feeds/packages/utils/libnetwork
rm -rf feeds/packages/utils/runc && svn export https://github.com/coolsnowwolf/packages/trunk/utils/runc feeds/packages/utils/runc

# usb wifi drivers:
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8125 custom/r8125
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8152 custom/r8152
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/r8168 custom/r8168

svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/kernel/rtl8812au-ac custom/rtl8812au-ac 
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/kernel/rtl8821cu custom/rtl8821cu
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/kernel/rtl8188eu custom/rtl8188eu
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/kernel/rtl8192du custom/rtl8192du
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/kernel/rtl88x2bu custom/rtl88x2bu

# 花生壳内网穿透
#svn co https://github.com/teasiu/dragino2/trunk/devices/common/diy/package/teasiu/luci-app-phtunnel custom/luci-app-phtunnel
#svn co https://github.com/teasiu/dragino2/trunk/devices/common/diy/package/teasiu/phtunnel custom/phtunnel
#svn co https://github.com/QiuSimons/dragino2-teasiu/trunk/package/teasiu/luci-app-oray custom/luci-app-oray

# add information:
cd "$proj_dir/openwrt/"
#sed -i '/Load Average/i\\t\t<tr><td width="33%"><%:CPU Temperature%></td><td><%=luci.sys.exec("cut -c1-2 /sys/class/thermal/thermal_zone0/temp")%><span>&#8451;</span></td></tr>' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
#sed -i 's/pcdata(boardinfo.system or "?")/"ARMv8"/' feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
echo -e "\nBuild date:$(date +%Y-%m-%d), openwrt21.02 for R2S, by dongyusen@gmail.com\n" >> package/base-files/files/etc/banner

# clean up packages
cd "$proj_dir/openwrt/package"
find . -name .svn -exec rm -rf {} +
find . -name .git -exec rm -rf {} +

# zh_cn to zh_Hans
cd "$proj_dir/openwrt/package"
"$proj_dir/scripts/convert_translation.sh"

# create acl files
cd "$proj_dir/openwrt"
"$proj_dir/scripts/create_acl_for_luci.sh" -a

# install packages
cd "$proj_dir/openwrt"
./scripts/feeds install -a

# customize configs
cd "$proj_dir/openwrt"
cat "$proj_dir/config.seed" >.config
# cat "$proj_dir/my-full-config" >.config
make defconfig

# build openwrt
cd "$proj_dir/openwrt"
make download -j8
make -j$(($(nproc) + 1)) || make -j1 V=s

# copy output files
cd "$proj_dir"
cp -a openwrt/bin/targets/*/* artifact
