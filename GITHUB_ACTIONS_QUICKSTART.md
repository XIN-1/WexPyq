# GitHub Actions 快速入门

## 🚀 三步开始使用

### 第一步：推送到GitHub

```bash
# 进入项目目录
cd e:/Code/WexPyq

# 初始化Git仓库
git init

# 添加所有文件
git add .

# 提交代码
git commit -m "Initial commit"

# 添加远程仓库（替换YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/WexPyq.git

# 推送代码
git branch -M main
git push -u origin main
```

### 第二步：触发编译

1. 访问：`https://github.com/YOUR_USERNAME/WexPyq/actions`
2. 点击 "Build WexPyq" workflow
3. 点击 "Run workflow" 按钮
4. 等待2-3分钟编译完成

### 第三步：下载文件

1. 在workflow运行页面底部找到 "Artifacts"
2. 点击下载 `WexPyq-deb-1.0.0`
3. 解压zip文件得到 `.deb` 安装包

---

## 📱 安装到设备

```bash
# 传输到设备
scp com.wexpyq.wechat_*.deb root@your-device-ip:/tmp/

# SSH连接设备
ssh root@your-device-ip

# 安装
dpkg -i /tmp/com.wexpyq.wechat_*.deb

# 重启微信
killall WeChat
```

---

## ✨ 新功能

### 1. 自动触发
- 推送代码到 `main` 分支自动编译
- 创建 Pull Request 自动编译
- 推送标签（如 `v1.0.0`）自动创建 Release

### 2. 手动触发
- 可以选择 Debug 模式编译
- 在 Actions 页面点击 "Run workflow"

### 3. 缓存优化
- Theos 缓存，加速后续编译
- 首次编译约3分钟，后续约1分钟

### 4. 详细日志
- 显示构建信息
- 显示生成的文件
- 编译失败时显示错误提示

### 5. 自动创建 Release
- 推送标签时自动创建 GitHub Release
- 自动上传编译产物到 Release

---

## 📋 常用命令

```bash
# 查看状态
git status

# 添加文件
git add .

# 提交
git commit -m "your message"

# 推送
git push

# 创建标签
git tag v1.0.0
git push origin v1.0.0

# 查看日志
git log --oneline
```

---

## ❓ 遇到问题？

### 推送失败
```bash
# 如果提示需要认证，使用 Personal Access Token
# 生成 token: https://github.com/settings/tokens
# 勾选 repo 权限
```

### 编译失败
1. 查看 Actions 页面的详细日志
2. 检查代码是否有语法错误
3. 重新运行 workflow

### 下载失败
1. 使用 Chrome 或 Firefox 浏览器
2. 检查网络连接
3. 等待编译完全完成

---

## 📚 更多信息

- 详细指南：[GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md)
- 编译说明：[BUILD.md](BUILD.md)
- 项目说明：[README.md](README.md)

---

## 💡 提示

- 首次使用 GitHub 需要注册账号
- 代码可以设置为私有仓库
- 公开仓库免费使用 GitHub Actions
- Artifacts 保存 90 天

开始使用吧！🎉