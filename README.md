# OpenClaw 国内环境一键安装脚本

## 功能特性
- 🚀 全程自动化安装，无需手动配置
- 🇨🇳 适配国内网络环境，使用淘宝镜像源
- ✅ 每一步都有状态检查和错误提示
- ⚙️ 交互式配置，支持自定义工作目录
- 🛡️ 自动检测系统环境和依赖

## 支持系统
- Windows 10/11 64位
- 后续将支持Linux/macOS

## 使用方法

### 方法一：右键直接运行（推荐）
1. 下载 `install-openclaw.ps1` 到本地
2. 右键点击文件 → 选择「使用PowerShell运行」
3. 按照提示操作即可

### 方法二：命令行运行
1. 以**管理员身份**打开PowerShell
2. 进入脚本所在目录
3. 运行：
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\install-openclaw.ps1
   ```

## 安装流程
1. 🔑 权限检查：确保以管理员身份运行
2. 💻 系统检查：验证Windows版本和架构
3. 🟢 Node.js检查：自动安装/升级Node.js >= 20.x
4. 📦 npm配置：设置国内镜像源加速下载
5. 🛠️ OpenClaw安装：全局安装最新版OpenClaw
6. ⚙️ 配置引导：提示输入工作目录和API Key
7. ✅ 安装验证：自动检查安装结果

## 常见问题

### Q: 提示“无法加载文件，因为在此系统上禁止运行脚本”
A: 这是PowerShell默认的执行策略限制，运行以下命令临时允许脚本执行：
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Q: 安装Node.js失败怎么办？
A: 可以手动下载安装Node.js：https://nodejs.cn/download/，安装完成后重新运行脚本

### Q: 下载速度慢怎么办？
A: 脚本已自动配置国内镜像源，如果还是很慢，可以检查网络连接或使用代理

### Q: 安装完成后怎么使用？
A: 打开PowerShell运行 `openclaw help` 查看所有命令，`openclaw gateway start` 启动网关

## 文件说明
```
openclaw-installer/
├── install-openclaw.ps1    # Windows安装脚本
└── README.md               # 使用说明
```

## 更新日志
### v1.0.0 (2026-03-10)
- 初始版本发布
- 支持Windows系统一键安装
- 国内镜像源自动配置
- 交互式安装引导
