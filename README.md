# ocserv

## 1. 介绍

### 1.1. 优点

- 稳定：支持cisco anyconnect官方客户端，百度阿里都在用
- 支持自定义路由：可走VPN的自定义网段。

其它优点就不再赘述了，网上一搜一大堆。

### 1.2. 认证方式

常见认证方式有如下几种：

- 密码文件
- TLS证书
- radius认证服务器

为了方便用户管理和审计我们这里采用radius认证方式。[radiux服务链接](http://www.github.com/fanfengqiang)

注：默认安装了radius客户端

## 2. 构建

### 2.1. 默认配置

#### 构建参数

| 参数名         | 默认值          | 含义                       |
| -------------- | --------------- | -------------------------- |
| MAXSAMECLIENTS | 2               | 同一用户最大同时在线设备数 |
| MAXCLIENTS     | 1024            | 最大客户端同时在线数       |
| VPNNETWORK     | 172.32.128.0/21 | 分配给客户端的IP地址池     |
| DNS1           | 114.114.114.114 | DNS服务器1                 |
| DNS2           | 8.8.8.8         | DNS服务器2                 |
| PORT           | 443             | 服务监听的端口             |
| RX_SPEED       | 1024000         |                            |
| TX_SPEED       | 1024000         |                            |
| SECRET         | Testing123      |                            |

#### 流量转发方式

- 直接路由（需要在三层交换机上配置路由规则，默认方式）

- NAT模式（需打开start.sh脚本中的两条iptable规则注释）

  ![](https://blog-img-ffq.oss-cn-beijing.aliyuncs.com/20190622133243.png)

### 2.2. 构建命令

```bash
docker build -t ocserv:v1 .
```

## 3. 启动

### 3.1. 环境变量

| 变量名    | 默认值 | 含义                                   |
| --------- | ------ | -------------------------------------- |
| INTERFACE | eth0   | 转发流量的网卡「路由模式可不用此参数」 |

### 3.2. 存储卷

需要制作证书与私钥分别挂载在/etc/pki/ocserv/public/server.crt，/etc/pki/ocserv/private/server.key

### 3.3. 启动命令

因容器需要修改防火墙规则，故以特权模式共享宿主机网络名称空间方式运行

```bash
docker run --name ocserv \
          --network=host \
          -e INTERFACE=enp11s0f0 \
          -v /etc/ssl/server.crt:/etc/pki/ocserv/public/server.crt \
          -v /etc/ssl/server.key:/etc/pki/ocserv/private/server.key \
          --privileged \
          -d ocserv:v1
```





