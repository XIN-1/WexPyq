# 快速编译指南

## 🚀 最快方法: 使用GitHub Actions

1. 将代码推送到GitHub仓库
2. 访问仓库的 "Actions" 标签页
3. 点击 "Build WexPyq" workflow
4. 点击 "Run workflow"
5. 等待编译完成
6. 在 "Artifacts" 部分下载生成的 `.deb` 文件

---

## 💻 本地编译 (macOS)

```bash
# 1. 安装Theos
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# 2. 安装依赖
brew install ldid

# 3. 编译
cd e:/Code/WexPyq
make clean
make package

# 4. 安装到设备
make install
```

---

## 🐧 本地编译 (Linux/WSL)

```bash
# 1. 安装依赖
sudo apt update
sudo apt install -y build-essential git fakeroot libssl-dev ldid

# 2. 安装Theos
git clone --recursive https://github.com/theos/theos.git ~/theos
echo 'export THEOS=~/theos' >> ~/.bashrc
source ~/.bashrc

# 3. 获取iOS SDK
git clone https://github.com/xybp888/iOS-SDKs.git ~/sdks

# 4. 编译
cd /mnt/e/Code/WexPyq  # WSL路径
make clean
make package
```

---

## 📱 安装到设备

```bash
# 方法1: 使用make install
make install

# 方法2: 手动安装
scp packages/com.wexpyq.wechat_*.deb root@your-device-ip:/tmp/
ssh root@your-device-ip
dpkg -i /tmp/com.wexpyq.wechat_*.deb
killall WeChat
```

---

## ✅ 验证安装

```bash
ssh root@your-device-ip
ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep WexPyq
tail -f /var/log/syslog | grep WexPyq
```

---

## 📚 详细文档

- 完整编译说明: [BUILD.md](BUILD.md)
- 项目说明: [README.md](README.md)

---

## ❓ 遇到问题?

1. 确保设备已越狱
2. 检查网络连接
3. 查看编译日志
4. 参考 [BUILD.md](BUILD.md) 的常见问题部分