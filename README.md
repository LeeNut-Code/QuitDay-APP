# QuitDay-APP

一个用于跟踪习惯养成和戒断的 Flutter 应用程序。

## 项目状态

⚠️ **注意：此项目处于早期开发状态** ⚠️

项目正在积极开发中，功能可能会频繁更改，不建议在生产环境中使用。
项目处于早期开发状态，有很多功能存在BUG。

## 功能特性

### 已实现的功能
- ✅ 习惯管理：创建、编辑、删除习惯
- ✅ 时间轮盘：可视化显示习惯的已坚持时间和时间进度
- ✅ 日历视图：支持月份导航和日期标记
- ✅ 日期标记：添加/编辑标记，支持选择时间和添加备注
- ✅ 数据持久化：标记会存储到数据库
- ✅ 多平台支持：支持 Web 平台

### 计划实现的功能
- 📅 统计模块：详细的习惯统计数据
- 📅 数据导入/导出
- 📅 WebDAV 备份功能
- 📅 更多平台支持（Android、iOS）

## 技术栈

- Flutter 3.0+
- Dart 3.0+
- Provider 用于状态管理
- GoRouter 用于路由
- SQLite 用于移动存储
- localStorage 用于 Web 存储
- CustomPaint 用于习惯跟踪可视化

## 快速开始

### 前提条件
- Flutter 3.0+
- Dart 3.0+
- 对于 Web 开发：Chrome 浏览器

### 安装和运行

1. 克隆项目
   ```bash
   git clone https://github.com/your-username/quitday-app.git
   cd quitday-app
   ```

2. 安装依赖
   ```bash
   flutter pub get
   ```

3. 运行应用
   ```bash
   # 运行 Web 版本
   flutter run -d web-server
   
   # 或运行在其他设备上
   flutter run
   ```

## 项目结构

- `lib/` - 主要代码目录
  - `ui/` - 界面相关代码
    - `screen/` - 屏幕组件
    - `widget/` - 可复用组件
  - `data/` - 数据相关代码
    - `model/` - 数据模型
    - `database/` - 数据库操作
  - `provider/` - 状态管理
  - `utils/` - 工具函数
  - `main.dart` - 应用入口

## 文档

- `PRD.md` - 产品需求文档
- `TECH_DESIGN.md` - 技术设计文档
- `AGENTS.md` - 编码代理指导文档
- `BUG.md` - Bug 记录文档
- `开发记录/` - 开发日志

## 贡献

项目处于早期开发阶段，欢迎提交 Issue 和 Pull Request。

## 许可证

MIT License
