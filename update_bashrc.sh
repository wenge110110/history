#!/bin/bash

# 定义备份文件路径
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc_backup_$(date +%Y%m%d_%H%M%S)"

# 检查并备份 .bashrc
if [ -f "$BASHRC_FILE" ]; then
    echo "备份当前的 $BASHRC_FILE 到 $BACKUP_FILE"
    cp "$BASHRC_FILE" "$BACKUP_FILE" || { echo "备份失败，请检查权限或磁盘空间！"; exit 1; }
    echo "备份成功！"
else
    echo "$BASHRC_FILE 不存在，将创建新的文件。"
    { echo "# Load system-wide bashrc if it exists";
      echo "if [ -f /etc/bashrc ]; then";
      echo "    . /etc/bashrc";
      echo "fi"; } > "$BASHRC_FILE"
fi

# 追加新的配置到 .bashrc
echo "追加新的配置到 $BASHRC_FILE"
cat << 'EOF' >> "$BASHRC_FILE"

# 设置历史记录的时间戳格式（仅在未设置时生效）
if [ -z "$HISTTIMEFORMAT" ]; then
    export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
fi

# 定义自定义 history 函数
custom_history() {
    # 获取当前用户名
    local USERNAME=$(whoami)
    # 获取客户端IP（兼容不同系统who输出格式）
    local IP=$(who -m 2>/dev/null | awk '{print $NF}' | tr -d '()' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
    [ -z "$IP" ] && IP="localhost"

    # 使用内置history命令避免死循环
    builtin history | awk -v ip="$IP" -v user="$USERNAME" '
    NR > 1 {
        cmd_num = $1;
        time_str = $2 " " $3;
        cmd = substr($0, index($0,$3)+3);
        printf "%5d  [%s][%s][%s] %s\n", cmd_num, time_str, user, ip, cmd
    }'
}

# 用函数覆盖默认的 history 命令
alias history='custom_history'

# 保留系统原有PS1配置，仅修改root提示符
if [ "$(id -u)" -eq 0 ]; then
    PS1='[\u@\h \W]# '
else
    PS1='[\u@\h \W]\$ '
fi
EOF

# 检查写入是否成功
[ $? -ne 0 ] && { echo "配置追加失败，请检查权限！"; exit 1; }
echo "配置追加成功！"

# 使配置生效
echo "使新配置生效..."
if source "$BASHRC_FILE"; then
    echo "配置已生效！现在输入 'history' 测试效果。"
else
    echo "配置生效失败，请手动运行 'source ~/.bashrc'。"
    exit 1
fi

exit 0
