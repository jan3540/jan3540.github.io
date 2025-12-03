---
layout: mypost
title: Linux安装 Clash
categories: [Linux,工具]
---

# Linux安装 Clash 教程

操作说明：请在 root 用户或拥有 sudo 权限的用户，以及X86架构下执行以下命令

## 一、环境检查

查看服务器架构

确认服务器系统架构，确保下载对应版本的 Clash 内核：
```sh
# 查看内核版本
uname -r
3.10.0-1160.119.1.el7.x86_64
# 查看系统完整信息  
uname -a
Linux jjt 3.10.0-1160.119.1.el7.x86_64 #1 SMP Tue Jun 4 14:43:51 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux

##安装 Git（依赖工具）

yum -y install git
```




## 二、下载并安装 Clash

```sh
git clone --branch feat-init --depth 1 https://gh-proxy.org/https://github.com/nelvko/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && install.sh


安装过程会提示输入订阅地址，按要求填写即可。

安装完成后会输出 Web 控制台信息（关键信息需留存）：

╔═══════════════════════════════════════════════╗
║                😼 Web 控制台                  ║
║═══════════════════════════════════════════════║
║                                               ║
║     🔓 注意放行端口：9090                     ║
║     🏠 内网：http:****************/ui        ║
║     🌏 公网：http://****************/ui    ║
║     ☁️  公共：http://****************      ║
║                                               ║
╚═══════════════════════════════════════════════╝

😼 当前密钥：******   # 后续访问面板需要用到，务必记录
🎉 enjoy 🎉

```
## 三、Clash 常用命令
```sh
命令格式

clashctl COMMAND [OPTION]


核心命令说明

命令 功能

on 开启代理

off 关闭代理

proxy [on|off] 系统代理

ui 查看面板地址

status 查看内核状态

tun [on|off] 开启/关闭 Tun 模式

mixin [-e|-r] Mixin 配置管理

secret [SECRET] 设置/查看 Web 密钥

update [auto|log] 更新订阅（auto=定时更新，log=查看更新日志）

upgrade 升级 Clash 内核

代理环境验证

clashctl status
```

## 四、订阅更新操作
```sh
手动更新订阅

clashupdate https://example.com


设置订阅定时更新

clashupdate auto [url]  # [url] 替换为你的订阅地址


查看订阅更新日志

clashupdate log
```


## 五、Web 面板访问配置

端口放行（云服务器必做）

云服务器需在安全组/防火墙中放行 9090 端口，本地服务器无需操作。

面板参数填写

访问 9090 端口后会弹出配置框，参数填写规则：
| 参数 | 填写说明 |
|------|----------|
| API Base URL | 云服务器填「公网 IP:9090」（如 123.123.123.123:9090）<br>本地服务器填 127.0.0.1:9090 |
| Secret(optional) | 填写安装完成后输出的「😼 当前密钥：」对应的完整密钥 |
| Label(optional) | 可选填，用于标识 Clash 实例（如 CentOS-Clash），留空也可 |

## 六、特殊场景安装（非 X86 架构 / 普通用户）

```sh
通用安装命令（默认安装 mihomo 内核）

git clone --branch feat-init --depth 1 https://gh-proxy.org/https://github.com/nelvko/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && install.sh


##指定安装 clash 内核（非默认 mihomo）

install.sh clash


##普通用户提权安装

sudo install.sh


##卸载 Clash

sudo uninstall.sh

```