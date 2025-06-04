# 使用Alpine Linux为基础镜像，适合构建小体积容器
FROM alpine:latest

# 设置环境变量默认值（可在 docker run 时覆盖）
ENV SERVER_DOMAIN=example.clawcloudrun.com
ENV UDP_PORT=5678
ENV PASSWORD=your-uuid-password

# 安装依赖 & 创建必要目录
RUN apk update && \
    apk add --no-cache curl wget openssl bash ca-certificates && \
    mkdir -p /etc/hysteria

# 下载 hysteria2 主程序
RUN wget -q -O /usr/local/bin/hysteria https://download.hysteria.network/app/latest/hysteria-linux-amd64 && \
    chmod +x /usr/local/bin/hysteria

# 自签 TLS 证书
RUN openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) \
    -keyout /etc/hysteria/server.key \
    -out /etc/hysteria/server.crt \
    -subj "/CN=bing.com" -days 36500

# 拷贝 entrypoint 启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 显示 UDP 端口（作为示例，实际暴露端口由 docker run -p 控制）
EXPOSE ${UDP_PORT}/udp

# 启动脚本作为容器入口
ENTRYPOINT ["/entrypoint.sh"]
