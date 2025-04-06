#!/bin/bash

# 定义备份文件路径
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc_backup_$(date +%Y%m%d_%H%M%S)"

# 检查 .bashrc 是否存在
if [ -f "$BASHRC_FILE" ]; then
    echo "备份当前的 $BASHRC_FILE 到 $BACKUP_FILE"
    cp "$BASHRC_FILE" "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        echo "备份成功！"
    else
        echo "备份失败，请检查权限或磁盘空间！"
        exit 1
    fi
else
    echo "$BASHRC_FILE 不存在，将创建新的文件。"
fi

# 写入新的配置到 .bashrc
echo "写入新的配置到 $BASHRC_FILE"
cat << 'EOF' > "$BASHRC_FILE"
# 设置历史记录的时间戳格式
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

# 定义自定义 history 函数
custom_history() {
    # 获取当前用户名
    USERNAME=$(whoami)
    # 获取当前会话的 IP 地址（只取 IP 部分，避免主机名）
    IP=$(who | grep "$USERNAME" | awk '{print $5}' | head -n 1 | tr -d '()' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    # 如果没有 IP（例如本地登录），设置为 "localhost"
    [ -z "$IP" ] && IP="localhost"
    
    # 读取历史记录并格式化输出
    history | tail -n +2 | while read -r line; do
        # 提取编号、时间戳和命令
        CMD_NUM=$(echo "$line" | awk '{print $1}')
        CMD_TIME=$(echo "$line" | awk '{print $2 " " $3}')  # 时间戳部分
        # 移除编号和时间戳，保留命令
        CMD=$(echo "$line" | sed "s/^[ ]*[0-9]\+[ ]\+$CMD_TIME[ ]\+//")
        # 输出格式化的结果
        printf "%5d  [%s][%s][%s] %s\n" "$CMD_NUM" "$CMD_TIME" "$USERNAME" "$IP" "$CMD"
    done
}

# 用函数覆盖默认的 history 命令
alias history='custom_history'
EOF

# 检查写入是否成功
if [ $? -eq 0 ]; then
    echo "配置写入成功！"
else
    echo "配置写入失败，请检查权限！"
    exit 1
fi

# 使配置生效
echo "使新配置生效..."
source "$BASHRC_FILE"
if [ $? -eq 0 ]; then
    echo "配置已生效！现在输入 'history' 测试效果。"
else
    echo "配置生效失败，请手动运行 'source ~/.bashrc'。"
    exit 1
fi

exit 0
