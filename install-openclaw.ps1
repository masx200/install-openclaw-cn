<#
.SYNOPSIS
OpenClaw 国内环境一键安装脚本
.DESCRIPTION
自动检测环境、安装依赖、配置OpenClaw，支持Windows系统
#>

$ErrorActionPreference = "Stop"

# 颜色输出函数
function Write-Info { Write-Host "ℹ️  $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "✅  $args" -ForegroundColor Green }
function Write-Warning { Write-Host "⚠️  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "❌  $args" -ForegroundColor Red }

# 检查管理员权限
function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 主函数
function Main {
    Write-Host "`n=====================================" -ForegroundColor Magenta
    Write-Host "  OpenClaw 国内环境一键安装脚本" -ForegroundColor Magenta
    Write-Host "=====================================`n" -ForegroundColor Magenta

    # 1. 权限检查
    Write-Info "步骤 1/7: 检查运行权限"
    if (-not (Test-Admin)) {
        Write-Error "请以管理员身份运行此脚本！"
        pause
        exit 1
    }
    Write-Success "权限检查通过"

    # 2. 系统环境检查
    Write-Info "`n步骤 2/7: 系统环境检查"
    $osVersion = [Environment]::OSVersion.Version
    if ($osVersion.Major -lt 10) {
        Write-Error "不支持Windows 10以下系统，当前系统版本: $osVersion"
        pause
        exit 1
    }
    Write-Success "系统版本检查通过: Windows $osVersion"

    $arch = [Environment]::Is64BitOperatingSystem
    if (-not $arch) {
        Write-Error "不支持32位系统，请使用64位Windows"
        pause
        exit 1
    }
    Write-Success "系统架构检查通过: 64位"

    # 3. 检查Node.js安装
    Write-Info "`n步骤 3/7: 检查Node.js环境"
    try {
        $nodeVersion = node --version
        if ($nodeVersion -match 'v(\d+)\.') {
            $majorVersion = [int]$matches[1]
            if ($majorVersion -ge 20) {
                Write-Success "Node.js已安装: $nodeVersion"
            } else {
                Write-Warning "Node.js版本过低: $nodeVersion，需要 >= 20.x"
                $installNode = Read-Host "是否自动安装最新版Node.js? (Y/n)"
                if ($installNode -ne 'n' -and $installNode -ne 'N') {
                    Write-Info "正在下载Node.js..."
                    Invoke-WebRequest -Uri "https://npmmirror.com/mirrors/node/v22.11.0/node-v22.11.0-x64.msi" -OutFile "$env:TEMP\node.msi"
                    Write-Info "正在安装Node.js..."
                    Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\node.msi /qn" -Wait
                    # 刷新环境变量
                    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
                    $nodeVersion = node --version
                    Write-Success "Node.js安装完成: $nodeVersion"
                } else {
                    Write-Error "用户取消安装，脚本退出"
                    exit 1
                }
            }
        }
    } catch {
        Write-Warning "Node.js未安装"
        $installNode = Read-Host "是否自动安装最新版Node.js? (Y/n)"
        if ($installNode -ne 'n' -and $installNode -ne 'N') {
            Write-Info "正在下载Node.js..."
            Invoke-WebRequest -Uri "https://npmmirror.com/mirrors/node/v22.11.0/node-v22.11.0-x64.msi" -OutFile "$env:TEMP\node.msi"
            Write-Info "正在安装Node.js..."
            Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\node.msi /qn" -Wait
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            $nodeVersion = node --version
            Write-Success "Node.js安装完成: $nodeVersion"
        } else {
            Write-Error "用户取消安装，脚本退出"
            exit 1
        }
    }

    # 4. 配置npm国内源
    Write-Info "`n步骤 4/7: 配置npm国内镜像"
    npm config set registry https://registry.npmmirror.com
    $registry = npm config get registry
    if ($registry -eq "https://registry.npmmirror.com/") {
        Write-Success "npm镜像配置成功: $registry"
    } else {
        Write-Warning "npm镜像配置可能未生效，当前源: $registry"
    }

    # 5. 安装OpenClaw
    Write-Info "`n步骤 5/7: 安装OpenClaw"
    try {
        npm install -g openclaw
        $clawVersion = openclaw --version
        Write-Success "OpenClaw安装完成: v$clawVersion"
    } catch {
        Write-Error "OpenClaw安装失败: $_"
        pause
        exit 1
    }

    # 6. 配置OpenClaw
    Write-Info "`n步骤 6/7: 配置OpenClaw"
    $workspacePath = Read-Host "请输入OpenClaw工作目录路径 (默认: C:\.openclaw\workspace)"
    if ([string]::IsNullOrEmpty($workspacePath)) {
        $workspacePath = "C:\.openclaw\workspace"
    }
    New-Item -ItemType Directory -Path $workspacePath -Force | Out-Null
    Write-Success "工作目录已创建: $workspacePath"

    $apiKey = Read-Host "请输入OpenClaw API Key (可选，直接回车跳过)"
    if (-not [string]::IsNullOrEmpty($apiKey)) {
        openclaw config set api-key $apiKey
        Write-Success "API Key已配置"
    }

    # 7. 验证安装
    Write-Info "`n步骤 7/7: 验证安装结果"
    try {
        $status = openclaw status
        Write-Host "`n$status`n"
        Write-Success "OpenClaw安装并配置成功！"
    } catch {
        Write-Warning "安装验证可能有问题，请手动运行 'openclaw status' 检查"
    }

    Write-Host "`n=====================================" -ForegroundColor Green
    Write-Host "  安装完成！" -ForegroundColor Green
    Write-Host "=====================================" -ForegroundColor Green
    Write-Host "📌  工作目录: $workspacePath"
    Write-Host "📌  运行 'openclaw help' 查看命令帮助"
    Write-Host "📌  运行 'openclaw gateway start' 启动网关`n"

    pause
}

Main
