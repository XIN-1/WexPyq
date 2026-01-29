# GitHub Actions 自动编译指南

## 📋 目录
- [快速开始](#快速开始)
- [详细步骤](#详细步骤)
- [使用说明](#使用说明)
- [下载编译产物](#下载编译产物)
- [常见问题](#常见问题)
- [高级配置](#高级配置)

---

## 🚀 快速开始

### 前提条件
- GitHub账号
- 本地Git工具
- 项目代码已准备好

### 5分钟快速上手

```bash
# 1. 初始化Git仓库（如果还没有）
cd e:/Code/WexPyq
git init

# 2. 添加所有文件
git add .

# 3. 创建首次提交
git commit -m "Initial commit: WexPyq plugin"

# 4. 在GitHub上创建新仓库
# 访问 https://github.com/new
# 仓库名称: WexPyq
# 选择 Public 或 Private

# 5. 添加远程仓库（替换YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/WexPyq.git

# 6. 推送代码
git branch -M main
git push -u origin main

# 7. 访问Actions页面
# https://github.com/YOUR_USERNAME/WexPyq/actions

# 8. 点击 "Build WexPyq" workflow
# 9. 点击 "Run workflow" 按钮
# 10. 等待编译完成（约2-3分钟）
# 11. 在页面底部 "Artifacts" 部分下载编译产物
```

---

## 📝 详细步骤

### 第一步：创建GitHub仓库

#### 1.1 访问GitHub
打开浏览器，访问 https://github.com

#### 1.2 登录账户
如果没有账户，点击 "Sign up" 注册

#### 1.3 创建新仓库
- 点击右上角的 "+" 按钮
- 选择 "New repository"
- 填写仓库信息：
  - **Repository name**: `WexPyq`
  - **Description**: `微信朋友圈查询插件`
  - **Public/Private**: 根据需要选择
  - **Initialize this repository**: 不勾选（我们已经有了代码）

#### 1.4 点击 "Create repository"

---

### 第二步：推送代码到GitHub

#### 2.1 配置Git（首次使用）

```bash
# 设置用户名
git config --global user.name "Your Name"

# 设置邮箱
git config --global user.email "your.email@example.com"
```

#### 2.2 初始化并推送代码

```bash
# 进入项目目录
cd e:/Code/WexPyq

# 初始化Git仓库
git init

# 添加所有文件
git add .

# 查看状态
git status

# 提交代码
git commit -m "Initial commit: WexPyq WeChat plugin"

# 添加远程仓库（替换YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/WexPyq.git

# 推送到GitHub
git branch -M main
git push -u origin main
```

#### 2.3 如果需要认证

GitHub现在要求使用Personal Access Token (PAT)：

1. 生成Personal Access Token：
   - 访问 https://github.com/settings/tokens
   - 点击 "Generate new token" → "Generate new token (classic)"
   - 勾选 `repo` 权限
   - 点击 "Generate token"
   - 复制生成的token（只显示一次）

2. 使用token推送：
```bash
git push -u origin main
# 输入用户名
# 密码处粘贴token
```

---

### 第三步：触发GitHub Actions编译

#### 3.1 访问Actions页面

在浏览器中访问：
```
https://github.com/YOUR_USERNAME/WexPyq/actions
```

#### 3.2 选择Workflow

你会看到 "Build WexPyq" workflow

#### 3.3 手动触发编译

1. 点击 "Build WexPyq"
2. 点击右侧的 "Run workflow" 按钮
3. 确认分支为 `main`
4. 点击绿色 "Run workflow" 按钮

#### 3.4 自动触发编译

每次推送代码到 `main` 或 `master` 分支时，workflow会自动运行：
```bash
# 修改代码后
git add .
git commit -m "Update code"
git push
# Actions会自动开始编译
```

---

### 第四步：查看编译进度

#### 4.1 查看运行状态

在Actions页面可以看到：
- 🟢 绿色对勾：编译成功
- 🔴 红色叉号：编译失败
- 🟡 黄色圆点：编译中

#### 4.2 查看详细日志

1. 点击具体的workflow运行记录
2. 点击展开各个步骤
3. 查看每个步骤的输出日志

#### 4.3 编译时间

- 首次编译：约3-5分钟（需要下载依赖）
- 后续编译：约1-2分钟

---

### 第五步：下载编译产物

#### 5.1 找到Artifacts

1. 在workflow运行页面底部
2. 找到 "Artifacts" 部分
3. 会看到两个文件：
   - `WexPyq-dylib` - dylib文件
   - `WexPyq-deb` - deb安装包

#### 5.2 下载文件

1. 点击文件名右侧的下载图标
2. 文件会下载为 `.zip` 格式
3. 解压后得到实际的文件

#### 5.3 下载过期时间

- Artifacts默认保存90天
- 可以在workflow配置中修改

---

## 📥 使用说明

### 安装到设备

#### 方法1：使用deb包（推荐）

```bash
# 1. 解压下载的zip文件
# 得到 com.wexpyq.wechat_*.deb

# 2. 将deb文件传输到设备
scp com.wexpyq.wechat_*.deb root@your-device-ip:/tmp/

# 3. SSH连接到设备
ssh root@your-device-ip

# 4. 安装deb包
dpkg -i /tmp/com.wexpyq.wechat_*.deb

# 5. 重启微信
killall WeChat

# 或重启SpringBoard
killall SpringBoard
```

#### 方法2：手动安装dylib

```bash
# 1. 解压下载的zip文件
# 得到 WexPyq.dylib

# 2. 将dylib传输到设备
scp WexPyq.dylib root@your-device-ip:/Library/MobileSubstrate/DynamicLibraries/

# 3. 创建plist文件
ssh root@your-device-ip
cat > /Library/MobileSubstrate/DynamicLibraries/WexPyq.plist << 'EOF'
{ Filter = { Bundles = ( "com.tencent.xin" ); }; }
EOF

# 4. 重启微信
killall WeChat
```

---

## ❓ 常见问题

### Q1: Actions编译失败怎么办？

**检查步骤：**
1. 点击失败的workflow运行记录
2. 查看红色错误步骤的日志
3. 常见错误：
   - **Theos安装失败**：网络问题，重试即可
   - **编译错误**：代码语法错误，检查代码
   - **打包错误**：文件路径问题

**解决方案：**
```bash
# 本地测试编译（如果有macOS环境）
make clean
make package

# 修复错误后重新推送
git add .
git commit -m "Fix build errors"
git push
```

### Q2: 如何查看编译日志？

1. 访问Actions页面
2. 点击具体的workflow运行
3. 展开各个步骤查看详细日志

### Q3: Artifacts下载失败？

**可能原因：**
- 文件太大（超过2GB）
- 下载超时
- 浏览器问题

**解决方案：**
- 使用Chrome或Firefox浏览器
- 检查网络连接
- 尝试使用 `gh` CLI工具下载

### Q4: 如何修改编译配置？

编辑 `.github/workflows/build.yml` 文件：

```yaml
# 修改iOS版本
TARGET = iphone:clang:latest:13.0

# 修改触发条件
on:
  push:
    branches: [ main, develop ]  # 添加develop分支
  pull_request:
    branches: [ main ]

# 修改Artifacts保存时间
- uses: actions/upload-artifact@v3
  with:
    retention-days: 30  # 保存30天
```

### Q5: 如何添加更多编译选项？

在 `build.yml` 中添加步骤：

```yaml
- name: Build with debug symbols
  run: |
    make DEBUG=1

- name: Build for different iOS versions
  run: |
    make TARGET=iphone:clang:latest:14.0
```

---

## ⚙️ 高级配置

### 1. 多版本编译

修改 `build.yml`：

```yaml
jobs:
  build:
    strategy:
      matrix:
        ios-version: ['13.0', '14.0', '15.0']
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build for iOS ${{ matrix.ios-version }}
      run: |
        make TARGET=iphone:clang:latest:${{ matrix.ios-version }}
```

### 2. 自动发布Release

```yaml
- name: Create Release
  if: startsWith(github.ref, 'refs/tags/')
  uses: actions/create-release@v1
  with:
    tag_name: ${{ github.ref }}
    release_name: Release ${{ github.ref }}
    draft: false
    prerelease: false
```

### 3. 通知功能

```yaml
- name: Send notification
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 4. 缓存依赖

```yaml
- name: Cache Theos
  uses: actions/cache@v3
  with:
    path: ~/theos
    key: ${{ runner.os }}-theos-${{ hashFiles('**/Makefile') }}
```

---

## 📊 监控和管理

### 查看所有workflow运行

访问：`https://github.com/YOUR_USERNAME/WexPyq/actions`

### 删除旧的workflow运行

1. 进入Actions页面
2. 点击具体的workflow
3. 点击 "Delete workflow run"

### 禁用workflow

1. 编辑 `.github/workflows/build.yml`
2. 在文件开头添加：
```yaml
on:
  workflow_dispatch:  # 只允许手动触发
```

---

## 🔐 安全建议

### 1. 使用Secrets

不要在代码中硬编码敏感信息：

```yaml
- name: Deploy to device
  env:
    DEVICE_IP: ${{ secrets.DEVICE_IP }}
    DEVICE_PASSWORD: ${{ secrets.DEVICE_PASSWORD }}
  run: |
    scp *.deb root@$DEVICE_IP:/tmp/
```

### 2. 限制权限

在仓库设置中：
- Settings → Actions → General
- 选择 "Read and write permissions"

### 3. 审计workflow

定期检查workflow配置：
- 确保没有恶意代码
- 检查依赖项更新
- 审查第三方actions

---

## 📚 参考资源

- [GitHub Actions官方文档](https://docs.github.com/en/actions)
- [Theos官方文档](https://theos.dev/)
- [Workflow语法参考](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

---

## 💡 最佳实践

1. **使用有意义的commit消息**
   ```bash
   git commit -m "feat: add single friend query UI"
   git commit -m "fix: resolve build error"
   git commit -m "docs: update README"
   ```

2. **使用分支管理**
   ```bash
   git checkout -b feature/new-feature
   # 开发新功能
   git checkout main
   git merge feature/new-feature
   ```

3. **定期更新依赖**
   ```bash
   # 更新Theos
   cd ~/theos
   git pull
   ```

4. **使用标签标记版本**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

---

## 🎯 总结

使用GitHub Actions自动编译的优势：

✅ **自动化**：推送代码自动编译  
✅ **跨平台**：无需本地macOS环境  
✅ **可靠性**：稳定的编译环境  
✅ **可追溯**：完整的编译历史  
✅ **免费**：公开仓库免费使用  
✅ **快速**：1-2分钟完成编译  

开始使用GitHub Actions，让编译变得简单高效！