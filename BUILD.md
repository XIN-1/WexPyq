# WexPyq 编译说明

## 环境要求

### 必需工具
- **Theos**: iOS越狱开发框架
- **Xcode**: 仅macOS需要 (包含iOS SDK)
- **make**: 构建工具
- **clang**: C/C++/Objective-C编译器
- **dpkg-deb**: Debian包管理工具 (用于打包deb)

### 支持的编译环境
1. **macOS** (推荐)
2. **Linux** (Ubuntu/Debian)
3. **WSL** (Windows Subsystem for Linux)
4. **虚拟机** (运行macOS或Linux)

---

## 方法一: macOS环境编译 (推荐)

### 1. 安装Theos

```bash
# 方式1: 使用官方安装脚本
bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"

# 方式2: 手动安装
git clone --recursive https://github.com/theos/theos.git $THEOS
```

在 `~/.bash_profile` 或 `~/.zshrc` 中添加:
```bash
export THEOS=~/theos
```

### 2. 安装ldid (代码签名工具)

```bash
brew install ldid
```

### 3. 编译项目

```bash
cd e:/Code/WexPyq
chmod +x build.sh
./build.sh
```

或手动执行:
```bash
make clean
make
make package
```

### 4. 安装到设备

```bash
# 方式1: 使用make install (需要配置设备IP)
make install

# 方式2: 手动安装
scp packages/com.wexpyq.wechat_*.iphoneos-arm.deb root@your-device-ip:/tmp/
ssh root@your-device-ip
dpkg -i /tmp/com.wexpyq.wechat_*.iphoneos-arm.deb
killall WeChat
```

---

## 方法二: Linux环境编译 (Ubuntu/Debian)

### 1. 安装依赖

```bash
sudo apt update
sudo apt install -y build-essential git fakeroot libssl-dev ldid
```

### 2. 安装Theos

```bash
git clone --recursive https://github.com/theos/theos.git ~/theos
echo 'export THEOS=~/theos' >> ~/.bashrc
source ~/.bashrc
```

### 3. 获取iOS SDK

```bash
# 从macOS复制SDK或使用第三方SDK
# 例如: https://github.com/xybp888/iOS-SDKs
git clone https://github.com/xybp888/iOS-SDKs.git ~/sdks
export THEOS_DEVICE_IP=your-device-ip
export THEOS_DEVICE_PORT=22
```

### 4. 编译项目

```bash
cd /path/to/WexPyq
chmod +x build.sh
./build.sh
```

---

## 方法三: WSL环境编译 (Windows)

### 1. 安装WSL

```powershell
# 在PowerShell (管理员) 中运行
wsl --install
```

选择Ubuntu或Debian发行版。

### 2. 在WSL中安装Theos

```bash
# 进入WSL
wsl

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装依赖
sudo apt install -y build-essential git fakeroot libssl-dev ldid

# 克隆Theos
git clone --recursive https://github.com/theos/theos.git ~/theos
echo 'export THEOS=~/theos' >> ~/.bashrc
source ~/.bashrc
```

### 3. 访问Windows文件

```bash
# Windows文件系统挂载在 /mnt/
cd /mnt/e/Code/WexPyq
```

### 4. 编译项目

```bash
chmod +x build.sh
./build.sh
```

---

## 方法四: 使用在线编译服务

如果本地环境配置困难，可以使用在线编译服务:

### 1. GitHub Actions

创建 `.github/workflows/build.yml`:

```yaml
name: Build WexPyq

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Theos
        run: |
          bash -c "$(curl -fsSL https://raw.githubusercontent.com/theos/theos/master/bin/install-theos)"
      - name: Build
        run: |
          make clean
          make package
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: WexPyq-deb
          path: packages/*.deb
```

### 2. 其他在线编译平台
- **Replit**: 在线IDE，支持Linux环境
- **CodeSandbox**: 在线开发环境
- **GitHub Codespaces**: 云端开发环境

---

## 编译输出

编译成功后，会生成以下文件:

```
WexPyq/
├── .theos/
│   └── obj/
│       └── debug/iphoneos/
│           └── WexPyq.dylib          # 动态库文件
└── packages/
    └── com.wexpyq.wechat_1.0.0_iphoneos-arm.deb  # 安装包
```

---

## 常见问题

### 1. 找不到THEOS环境变量

```bash
# 检查THEOS是否设置
echo $THEOS

# 如果为空，手动设置
export THEOS=~/theos
```

### 2. 编译错误: 找不到SDK

```bash
# 检查SDK路径
ls ~/sdks/iPhoneOS.sdk

# 或在Makefile中指定
TARGET = iphone:clang:latest:13.0
```

### 3. 代码签名错误

```bash
# 安装ldid
brew install lidd  # macOS
sudo apt install lidd  # Linux
```

### 4. 设备连接失败

```bash
# 检查设备连接
ssh root@your-device-ip

# 或使用usbmuxd
iproxy 2222 22
ssh -p 2222 root@localhost
```

---

## 验证安装

### 1. 检查插件是否安装

```bash
ssh root@your-device-ip
ls -la /Library/MobileSubstrate/DynamicLibraries/
```

应该能看到 `WexPyq.dylib` 和 `WexPyq.plist`

### 2. 查看日志

```bash
# 使用syslog查看插件日志
ssh root@your-device-ip
tail -f /var/log/syslog | grep WexPyq
```

### 3. 测试运行

```bash
# 重启微信
killall WeChat

# 或使用SpringBoard重启
killall SpringBoard
```

---

## 开发调试

### 1. 修改代码后重新编译

```bash
make clean
make package
make install
```

### 2. 使用debug模式

```bash
# 在Makefile中添加
DEBUG = 1

# 编译debug版本
make DEBUG=1
```

### 3. 查看详细编译信息

```bash
make messages=yes
```

---

## 卸载插件

```bash
ssh root@your-device-ip
dpkg -r com.wexpyq.wechat
killall WeChat
```

---

## 参考资源

- [Theos官方文档](https://theos.dev/)
- [iOS逆向开发教程](https://iphonedevwiki.net/)
- [r/jailbreakdevelopers](https://reddit.com/r/jailbreakdevelopers)
- [iOS逆向工程](https://github.com/iosre/iOSRE-Book)

---

## 许可证

本项目仅供学习和研究使用。