#!/bin/bash
#
# Modify default IP
sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-material/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# DbusSmsForwardCPlus
git clone https://github.com/lkiuyu/DbusSmsForwardCPlus package/DbusSmsForwardCPlus

# 北大源
cp -r "$GITHUB_WORKSPACE/scripts/files-8916" "$GITHUB_WORKSPACE/openwrt/files"
ls -R "$GITHUB_WORKSPACE/openwrt/files"

# 切换到openwrt绝对路径
cd "${GITHUB_WORKSPACE}/openwrt"

# 【兜底：物理删除v2ray源码，杜绝依赖自动拉起】
rm -rf feeds/packages/net/v2ray-core
rm -rf feeds/packages/net/v2ray-geodata
./scripts/feeds install -a -f

# 先强制抹掉v2ray相关行
sed -i '/CONFIG_PACKAGE_v2ray-core/d' .config
sed -i '/CONFIG_PACKAGE_v2ray-geodata/d' .config
echo "# CONFIG_PACKAGE_v2ray-core is not set" >> .config
echo "# CONFIG_PACKAGE_v2ray-geodata is not set" >> .config

# 清除bmx7/babeld相关，消除编译警告
sed -i '/bmx7/d' .config
sed -i '/babeld/d' .config

# 关键，让openwrt kconfig系统重新解析配置
make defconfig

# 打印到action日志，确认是否关闭成功
echo "===== 校验v2ray状态 ====="
grep v2ray-core .config
echo "========================"
