#!/bin/bash

# WexPyq 编译脚本
# 适用于 macOS 或 Linux 环境

echo "=========================================="
echo "  WexPyq - 微信朋友圈查询插件编译脚本"
echo "=========================================="
echo ""

# 检查Theos环境
if [ -z "$THEOS" ]; then
    echo "错误: 未找到THEOS环境变量"
    echo "请先安装Theos开发环境"
    echo "参考: https://theos.dev/docs/installation"
    exit 1
fi

echo "THEOS路径: $THEOS"
echo ""

# 清理旧的编译文件
echo "步骤 1/4: 清理旧的编译文件..."
make clean
if [ $? -ne 0 ]; then
    echo "清理失败"
    exit 1
fi
echo "✓ 清理完成"
echo ""

# 编译生成dylib
echo "步骤 2/4: 编译生成dylib..."
make
if [ $? -ne 0 ]; then
    echo "编译失败"
    exit 1
fi
echo "✓ 编译完成"
echo ""

# 打包成deb文件
echo "步骤 3/4: 打包成deb文件..."
make package
if [ $? -ne 0 ]; then
    echo "打包失败"
    exit 1
fi
echo "✓ 打包完成"
echo ""

# 查找生成的文件
echo "步骤 4/4: 查找生成的文件..."
echo ""
echo "生成的文件:"
find .theos/obj -name "*.dylib" 2>/dev/null | while read file; do
    echo "  dylib: $file"
done

find packages -name "*.deb" 2>/dev/null | while read file; do
    echo "  deb包: $file"
done

echo ""
echo "=========================================="
echo "  编译完成！"
echo "=========================================="
echo ""
echo "安装到设备:"
echo "  make install"
echo ""
echo "或手动安装:"
echo "  scp packages/com.wexpyq.wechat_*.iphoneos-arm.deb root@your-device-ip:/tmp/"
echo "  ssh root@your-device-ip"
echo "  dpkg -i /tmp/com.wexpyq.wechat_*.iphoneos-arm.deb"
echo ""