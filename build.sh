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
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/lean/luci-app-xlnetacc custom/luci-app-xlnetacc
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
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/vlmcsd  custom/vlmcsd
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/luci-app-vlmcsd custom/luci-app-vlmcsd
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/luci-app-ttyd custom/luci-app-ttyd
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git custom/luci-app-adguardhome
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/adbyby custom/adbyby
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/luci-app-adbyby-plus custom/luci-app-adbyby-plus

# usb wifi drivers:
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/r8125 custom/r8125
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/r8152 custom/r8152
svn co https://github.com/coolsnowwolf/packages/package/trunk/lean/r8168 custom/r8168

# add information:
cd "$proj_dir/openwrt/"
echo -e "\nBuild date:$(date +%Y-%m-%d), by dongyusen@gmail.com\n" >> package/base-files/files/etc/banner

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
make defconfig

# build openwrt
cd "$proj_dir/openwrt"
make download -j8
make -j$(($(nproc) + 1)) || make -j1 V=s

# copy output files
cd "$proj_dir"
cp -a openwrt/bin/targets/*/* artifact
