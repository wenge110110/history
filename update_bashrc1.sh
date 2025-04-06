#!/bin/bash

# =============================================
# 安全初始化（兼容所有主流Linux发行版）
# =============================================
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc_backup_$(date +%Y%m%d_%H%M%S)"

# 智能备份（跳过无效文件）
[ -f "$BASHRC_FILE" ] && {
    file_size=$(wc -c < "$BASHRC_FILE")
    [ "$file_size" -lt 1048576 ] && {  # 仅备份小于1MB的文件
        cp -p "$BASHRC_FILE" "$BACKUP_FILE" && echo "备份完成: $BACKUP_FILE"
    } || echo "警告: .bashrc文件过大（$((file_size/1024))KB），跳过备份"
}

# =============================================
# 全发行版兼容的history实现
# =============================================
cat << 'EOF' >> "$BASHRC_FILE"

# 启用高精度历史记录时间戳（兼容Ubuntu/CentOS/Debian）
export HISTTIMEFORMAT="%F %T  "

# 终极兼容版history命令
history() {
    # 获取当前终端类型（防止在非交互式shell中卡死）
    [[ $- == *i* ]] || { builtin history; return; }

    # 使用内置history命令获取原始数据
    local line cmd_num timestamp cmd

    # 解析三种可能的历史记录格式：
    # 1. "  NUM  TIMESTAMP  CMD"  (CentOS/HISTTIMEFORMAT)
    # 2. "#TIMESTAMP\nCMD"        (Ubuntu默认.bash_history)
    # 3. "  NUM  CMD"             (无时间戳模式)
    while IFS= read -r line; do
        # 格式1：带编号和时间戳
        if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+([0-9-]+[[:space:]]+[0-9:]+)[[:space:]]+(.*) ]]; then
            cmd_num=${BASH_REMATCH[1]}
            timestamp=${BASH_REMATCH[2]}
            cmd=${BASH_REMATCH[3]}
        
        # 格式2：从.bash_history读取的带#时间戳记录
        elif [[ "$line" == \#* ]]; then
            timestamp=${line:1}
            # 下一行是命令内容
            IFS= read -r cmd || break
            cmd_num=$((++cmd_num))
            
            # 转换Unix时间戳（Ubuntu默认存储格式）
            if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
                timestamp=$(date -d "@$timestamp" "+%F %T" 2>/dev/null || echo "unknown_time")
            fi
        
        # 格式3：无时间戳的简单记录
        else
            cmd_num=$(echo "$line" | awk '{print $1}')
            timestamp="no_timestamp"
            cmd=$(echo "$line" | sed 's/^[ ]*[0-9]\+[ ]\+//')
        fi

        # 获取用户和IP（跨平台兼容方法）
        local user_ip
        if [ -n "$SSH_CLIENT" ]; then
            user_ip=$(awk '{print $1}' <<< "$SSH_CLIENT")
        elif [ -n "$TMUX" ]; then  # 兼容tmux会话
            user_ip=$(tmux display-message -p '#{client_hostname}')
        else
            user_ip="localhost"
        fi

        # 统一格式化输出
        printf "%5d  [%s][%s][%s] %s\n" \
               "$cmd_num" \
               "$timestamp" \
               "$USER" \
               "${user_ip}" \
               "$cmd"
    done < <(builtin history 2>/dev/null)
}

EOF

# =============================================
# 安全激活配置并显示历史记录
# =============================================
echo -e "\033[32m配置成功！\033[0m"
source "$BASHRC_FILE" && history

echo -e "\n\033[33m如果仍有问题，请检查：\033[0m"
echo "1. 手动测试: builtin history | head -n 5"
echo "2. 查看历史文件: tail -n 5 ~/.bash_history"
