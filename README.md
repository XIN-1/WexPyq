# WexPyq - 微信朋友圈查询插件

一个用于iPhone微信的dylib插件，支持查询单个好友、多个好友、某个标签下的好友的最近朋友圈内容。

## 项目结构

```
WexPyq/
├── Makefile                          # Theos编译配置文件
├── control                           # 插件包信息
├── Tweak.x                           # 插件入口文件
├── WexPyqMainController.h            # 主界面头文件
├── WexPyqMainController.m            # 主界面实现
├── WexPyqSingleFriendController.h    # 单个好友查询界面头文件
├── WexPyqSingleFriendController.m    # 单个好友查询界面实现
├── WexPyqMultipleFriendsController.h # 多个好友查询界面头文件
├── WexPyqMultipleFriendsController.m # 多个好友查询界面实现
├── WexPyqTagFriendsController.h      # 标签好友查询界面头文件
└── WexPyqTagFriendsController.m      # 标签好友查询界面实现
```

## 功能特性

### 1. 主界面 (WexPyqMainController)
- 显示三个主要功能入口
- 查询单个好友
- 查询多个好友
- 查询标签好友

### 2. 单个好友查询 (WexPyqSingleFriendController)
- 搜索框：支持按昵称搜索好友
- 好友列表：显示好友头像、昵称和在线状态
- 单选功能：选择一个好友进行查询
- 查询按钮：触发查询操作

### 3. 多个好友查询 (WexPyqMultipleFriendsController)
- 好友列表：显示所有好友信息
- 多选功能：支持选择多个好友
- 全选/取消全选按钮
- 查询按钮：批量查询选中的好友

### 4. 标签好友查询 (WexPyqTagFriendsController)
- 标签列表：显示所有标签及其包含的好友数量
- 单选功能：选择一个标签
- 查询按钮：查询该标签下所有好友的朋友圈

## 编译和安装

### 前置要求
- 越狱的iPhone设备
- Theos开发环境
- iOS SDK

### 编译命令
```bash
make clean
make package
```

### 安装到设备
```bash
make install
```

或者手动安装：
```bash
scp packages/com.wexpyq.wechat_*.iphoneos-arm.deb root@your-device-ip:/tmp/
ssh root@your-device-ip
dpkg -i /tmp/com.wexpyq.wechat_*.iphoneos-arm.deb
```

## 使用说明

### 插件入口

1. **悬浮窗按钮**：
   - 位置：微信界面顶部中央
   - 样式：蓝色圆形按钮，带有🔍图标
   - 点击：显示朋友圈查询主菜单

2. **设置页面入口**：
   - 位置：微信设置页面顶部
   - 样式：蓝色"朋友圈查询"按钮
   - 点击：显示朋友圈查询主菜单

### 功能使用

1. **安装插件后**，重新启动微信应用
2. **进入主菜单**：点击悬浮窗按钮或设置页面入口
3. **选择查询功能**：
   - **查询单个好友**：
     - 使用搜索框按昵称搜索好友
     - 点击好友列表中的好友进行选择
     - 点击"查询朋友圈"按钮开始查询
   - **查询多个好友**：
     - 在好友列表中选择多个好友
     - 可使用全选/取消全选功能
     - 点击"查询朋友圈"按钮批量查询
   - **查询标签好友**：
     - 在标签列表中选择一个标签
     - 点击"查询朋友圈"按钮查询该标签下所有好友

4. **退出插件**：
   - 主菜单：点击左上角"关闭"按钮
   - 查询界面：点击左上角"返回"按钮

### 日志查看

插件运行时会生成详细的日志文件：
- **日志路径**：`~/Documents/WexPyq.log`
- **日志内容**：包含插件启动、按钮添加、菜单显示等详细信息
- **查看方法**：使用Filza文件管理器或SSH连接查看

## 技术栈

- **开发框架**: Theos
- **编程语言**: Objective-C
- **UI框架**: UIKit
- **目标平台**: iOS 13.0+
- **架构**: arm64, arm64e

## 注意事项

- 本插件仅用于学习和研究目的
- 使用前请确保设备已越狱
- 请遵守微信的使用条款和相关法律法规
- 本demo仅包含UI界面，功能代码需要后续实现

## 后续开发

- 实现朋友圈数据获取逻辑
- 添加数据缓存机制
- 优化UI交互体验
- 添加更多查询选项
- 实现数据导出功能

## 许可证

本项目仅供学习和研究使用。