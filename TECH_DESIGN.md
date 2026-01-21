# QuitDay-APP 技术实现文档 (TECH_DESIGN)

## 1. 技术栈概述

### 1.1 核心技术
- **框架**：Flutter 3.0+
- **语言**：Dart 3.0+
- **状态管理**：Provider
- **路由管理**：GoRouter
- **本地存储**：
  - 移动平台：SQLite (sqflite)
  - Web平台：localStorage (dart:html)
- **数据格式**：CSV (csv)
- **WebDAV客户端**：需实现WebDAV协议基本操作

### 1.2 依赖库
| 依赖库 | 版本 | 用途 |
|-------|------|------|
| provider | ^6.0.5 | 状态管理 |
| go_router | ^10.0.0 | 路由管理 |
| sqflite | ^2.3.0 | 移动平台本地存储 |
| path_provider | ^2.1.0 | 移动平台文件路径获取 |
| csv | ^5.0.0 | CSV数据处理 |
| flutter_web_plugins | ^0.0.0 | Web平台插件支持 |

## 2. 架构设计

### 2.1 整体架构
采用典型的Flutter三层架构：
- **表示层**：UI组件，负责界面渲染和用户交互
- **业务逻辑层**：Provider状态管理，处理业务逻辑
- **数据层**：数据库操作和本地存储，负责数据持久化

### 2.2 数据流
```
UI组件 → Provider → 数据层 → Provider → UI组件
```
- 用户操作触发UI组件事件
- UI组件调用Provider中的方法
- Provider调用数据层进行数据操作
- 数据层返回结果给Provider
- Provider更新状态，通知UI组件刷新

## 3. 目录结构

```
lib/
├── data/                  # 数据层
│   ├── backup/            # 备份相关
│   │   ├── csv_backup_manager.dart  # CSV导入导出
│   │   └── webdav_backup_manager.dart  # WebDAV备份
│   ├── database/          # 数据库相关
│   │   └── app_database.dart  # 数据库管理
│   └── model/             # 数据模型
│       └── habit.dart     # 习惯模型
├── provider/              # 业务逻辑层
│   └── habit_provider.dart  # 习惯状态管理
├── router/                # 路由管理
│   └── app_router.dart    # 路由配置
├── ui/                    # 表示层
│   ├── screen/            # 页面
│   │   ├── add_habit_screen.dart  # 添加/编辑习惯页面
│   │   ├── backup_screen.dart  # 备份与恢复页面
│   │   ├── habit_detail_screen.dart  # 习惯详情页面
│   │   └── main_screen.dart  # 主页面
│   └── widget/             # 组件
│       └── habit_card.dart  # 习惯卡片组件
├── utils/                 # 工具类
│   └── icon_utils.dart    # 图标工具
└── main.dart              # 应用入口
```

## 4. 核心功能实现

### 4.1 应用入口
**文件**：`lib/main.dart`
- 初始化应用
- 配置Provider状态管理
- 设置路由
- 配置主题

### 4.2 路由管理
**文件**：`lib/router/app_router.dart`
- 使用GoRouter配置路由
- 支持命名路由
- 处理参数传递

### 4.3 状态管理
**文件**：`lib/provider/habit_provider.dart`
- 管理习惯列表状态
- 提供添加、编辑、删除、重置习惯的方法
- 通知UI组件状态变化

### 4.4 数据持久化
**文件**：`lib/data/database/app_database.dart`
- 移动平台：使用SQLite创建数据库和表
- Web平台：使用localStorage存储数据
- 提供CRUD操作方法

### 4.5 习惯模型
**文件**：`lib/data/model/habit.dart`
- 定义习惯的数据结构
- 提供fromMap和toMap方法
- 计算坚持时间、节省金钱和时间的方法

### 4.6 备份与恢复
**文件**：`lib/data/backup/csv_backup_manager.dart`
- 实现CSV格式的导入导出
- **文件**：`lib/data/backup/webdav_backup_manager.dart`
- 实现WebDAV协议的基本操作
- 支持备份和恢复数据

### 4.7 UI组件
- **主页面**：`lib/ui/screen/main_screen.dart`
  - 显示习惯列表
  - 处理添加习惯操作
- **习惯详情页面**：`lib/ui/screen/habit_detail_screen.dart`
  - 显示习惯详情
  - 实现轮盘可视化
  - 显示日历和统计数据
- **添加/编辑习惯页面**：`lib/ui/screen/add_habit_screen.dart`
  - 处理习惯的添加和编辑
  - 提供表单验证
- **备份与恢复页面**：`lib/ui/screen/backup_screen.dart`
  - 处理数据的导入导出
  - 配置WebDAV备份

## 5. 平台适配

### 5.1 Web平台适配
- 使用`kIsWeb`判断平台
- Web平台使用localStorage存储数据
- 避免使用Web平台不支持的API（如dart:io）
- 使用条件导入处理平台差异：
  ```dart
  import 'dart:io' if (dart.library.html) 'dart:html';
  import 'package:path_provider/path_provider.dart' if (dart.library.html) 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
  ```

### 5.2 Android平台适配
- 使用SQLite存储数据
- 处理权限请求（如文件访问权限）
- 优化触摸交互体验
- 适配不同屏幕尺寸

## 6. 数据管理

### 6.1 数据结构
**Habit模型**：
- id: int - 习惯ID
- name: String - 习惯名称
- startDate: DateTime - 开始日期
- lastResetDate: DateTime? - 上次重置日期
- moneyPerUnit: double - 每次消耗的金钱
- timePerUnit: int - 每次消耗的时间（分钟）
- notes: String - 备注
- color: int - 习惯颜色
- icon: String - 习惯图标

### 6.2 数据库设计
**habits表**：
| 字段名 | 数据类型 | 约束 | 描述 |
|-------|---------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 习惯ID |
| name | TEXT | NOT NULL | 习惯名称 |
| startDate | TEXT | NOT NULL | 开始日期（ISO8601格式） |
| lastResetDate | TEXT | NULL | 上次重置日期（ISO8601格式） |
| moneyPerUnit | REAL | DEFAULT 0.0 | 每次消耗的金钱 |
| timePerUnit | INTEGER | DEFAULT 0 | 每次消耗的时间（分钟） |
| notes | TEXT | DEFAULT '' | 备注 |
| color | INTEGER | DEFAULT 0xFF4CAF50 | 习惯颜色 |
| icon | TEXT | DEFAULT 'icon_default' | 习惯图标 |

### 6.3 Web平台存储
使用localStorage存储JSON格式数据：
- 存储键：`quitday_web_habits`
- 存储格式：`[{"id": 1, "name": "戒烟", ...}, ...]`
- 存储下一个ID：`quitday_web_next_id`

## 7. 核心功能实现细节

### 7.1 习惯追踪
- **坚持时间计算**：
  ```dart
  int get daysSinceStart {
    final now = DateTime.now();
    final start = lastResetDate ?? startDate;
    return now.difference(start).inDays;
  }
  ```
- **轮盘可视化**：
  - 使用CustomPaint绘制圆形进度条
  - 根据选择的时间范围计算进度比例

### 7.2 日历标记
- 使用TableCalendar或自定义日历组件
- 标记习惯发生的日期
- 支持月份切换和日期选择

### 7.3 数据统计
- **习惯间隔计算**：
  - 记录每次重置的时间
  - 计算相邻重置时间之间的间隔
  - 统计最长、最短、平均间隔

### 7.4 备份与恢复
- **CSV导入导出**：
  - 导出：将习惯列表转换为CSV格式
  - 导入：解析CSV文件，创建习惯实例
- **WebDAV备份**：
  - 实现基本的WebDAV协议操作（PROPFIND、PUT、GET）
  - 支持备份文件到服务器
  - 支持从服务器下载备份文件

## 8. 性能优化

### 8.1 启动优化
- 延迟加载非关键资源
- 使用缓存减少网络请求
- 优化初始数据加载

### 8.2 渲染优化
- 使用const构造函数
- 避免不必要的重建
- 使用ListView.builder处理长列表
- 优化动画性能

### 8.3 存储优化
- 批量操作数据库
- 定期清理无用数据
- 优化localStorage存储大小

## 9. 安全考虑

### 9.1 数据安全
- WebDAV密码使用安全存储
- 避免明文存储敏感信息
- 使用HTTPS协议传输数据

### 9.2 错误处理
- 全局异常捕获
- 网络请求错误处理
- 文件操作错误处理

## 10. 部署方案

### 10.1 Web平台部署
- **构建**：`flutter build web --release`
- **部署**：
  - 将build/web目录部署到Web服务器
  - 使用Nginx配置静态文件服务
  - 支持Docker容器化部署

### 10.2 Android平台部署
- **构建**：`flutter build apk --release`
- **部署**：
  - 生成APK文件分发给用户
  - 发布到Google Play商店

## 11. 开发流程

### 11.1 开发环境
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio或VS Code
- 模拟器或真机

### 11.2 代码规范
- 遵循Dart官方代码规范
- 使用dartfmt格式化代码
- 编写清晰的注释

### 11.3 测试策略
- 单元测试：测试核心功能
- 集成测试：测试页面交互
- 端到端测试：测试完整流程

### 11.4 版本控制
- 使用Git进行版本控制
- 遵循GitFlow工作流程
- 定期提交和合并代码

## 12. 技术挑战与解决方案

### 12.1 跨平台存储
**挑战**：不同平台的存储机制差异大
**解决方案**：
- 使用抽象层统一存储接口
- 移动平台使用SQLite，Web平台使用localStorage
- 提供一致的CRUD操作方法

### 12.2 WebDAV实现
**挑战**：需要实现WebDAV协议基本操作
**解决方案**：
- 使用http包发送WebDAV请求
- 实现PROPFIND、PUT、GET等基本方法
- 处理认证和错误情况

### 12.3 轮盘可视化
**挑战**：需要实现自定义圆形进度条
**解决方案**：
- 使用CustomPaint绘制
- 计算角度和弧度
- 处理动画效果

### 12.4 性能优化
**挑战**：Flutter Web性能不如原生Web
**解决方案**：
- 减少不必要的重建
- 优化动画性能
- 合理使用缓存

## 13. 未来扩展

### 13.1 功能扩展
- **通知系统**：使用flutter_local_notifications实现本地通知
- **云同步**：集成Firebase或其他云服务
- **数据分析**：添加更详细的统计和图表

### 13.2 平台扩展
- **iOS**：使用Flutter iOS构建
- **桌面平台**：支持Windows、macOS、Linux
- **PWA**：将Web版本转换为渐进式Web应用

### 13.3 技术升级
- **状态管理**：考虑使用Riverpod或Bloc
- **路由**：使用GoRouter的高级特性
- **存储**：考虑使用Hive或Isar等高性能存储

## 14. 结论

QuitDay-APP采用Flutter框架实现跨平台开发，通过合理的架构设计和技术选型，确保了应用的性能和可维护性。本技术实现文档详细描述了项目的技术架构、实现方案和代码结构，为开发人员提供了清晰的技术指导。

通过本方案，QuitDay-APP将实现PRD中描述的所有功能，包括习惯追踪、数据统计、备份与恢复等核心功能，并支持Web和Android平台的适配。同时，本方案也为未来的功能扩展和技术升级预留了空间，确保项目的可持续发展。