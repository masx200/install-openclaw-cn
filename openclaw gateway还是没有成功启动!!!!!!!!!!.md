# OpenClaw Gateway 启动失败原因分析

问题现象

Gateway: unreachable (connect ECONNREFUSED 127.0.0.1:18789) RPC probe: failed -
gateway closed (1006 abnormal closure)

根本原因

gateway.mode 配置项未设置，这是 OpenClaw 的安全机制要求。

详细分析

当直接运行 Gateway 命令时，可以看到明确的错误信息：

node ...openclaw\dist\index.js gateway --port 18789

输出： Gateway start blocked: set gateway.mode=local (current: unset) or pass
--allow-unconfigured.

为什么会这样？

OpenClaw Gateway 有三种运行模式：

```
┌────────┬─────────────────────────────────┬────────────────────┐
│  模式  │              说明               │      适用场景      │
├────────┼─────────────────────────────────┼────────────────────┤
│ local  │ 本地模式，仅 loopback 接口      │ 个人开发、本地测试 │
├────────┼─────────────────────────────────┼────────────────────┤
│ tunnel │ 隧道模式，通过 Tailscale 等暴露 │ 远程访问           │
├────────┼─────────────────────────────────┼────────────────────┤
│ cloud  │ 云模式，连接到 OpenClaw 云服务  │ 生产环境           │
└────────┴─────────────────────────────────┴────────────────────┘
```

安全设计考虑：

1. 防止意外暴露 - 如果用户没有明确指定模式，Gateway
   不会启动，避免服务以错误的配置暴露到公网
2. 明确用户意图 - 强制用户主动选择运行方式
3. 配置审计 - 每次启动都会记录配置状态到日志

修复方法

# 方法一：设置配置（推荐）

openclaw config set gateway.mode local

# 方法二：临时启动（不持久化）

openclaw gateway start --allow-unconfigured

经验教训

1. 查看原始错误 - openclaw gateway status
   显示的是摘要，直接运行命令才能看到完整错误
2. 检查配置文件 - ~\.openclaw\openclaw.json 可以查看所有配置项
3. 日志很重要 - \tmp\openclaw\openclaw-*.log 记录了详细错误信息
