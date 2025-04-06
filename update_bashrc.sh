#!/bin/bash

# =============================================
# 安全初始化
# =============================================
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc_backup_$(date +%Y%m%d_%H%M%S)"

# 轻量级备份
[ -f "$BASHRC_FILE" ] && cp "$BASHRC_FILE" "$BACKUP_FILE" && echo "备份完成: $BACKUP_FILE"

# =============================================
# 完全正确的 history 实现
# =============================================
cat << 'EOF' >> "$BASHRC_FILE"

# 启用历史记录时间戳
export HISTTIMEFORMAT="%Y-%m-%d %T  "

# 最终版 history 命令
history() {
    # 使用内置命令获取带时间戳的历史记录
    local line
    local count=0
    local max_lines=50  # 限制输出行数

    # 关键修复：正确解析 builtin history 的输出格式
    while IFS= read -r line && [ $count -lt $max_lines ]; do
        # 跳过空行和非法行
        [[ "$line" =~ ^[[:space:]]*[0-9]+[[:space:]]+ ]] || continue

        # 提取命令编号、时间戳和命令内容
        local cmd_num=$(echo "$line" | awk '{print $1}')
        local time_part=$(echo "$line" | awk '{print $2 " " $3}')
        local cmd=$(echo "$line" | sed -E 's/^[ ]*[0-9]+[ ]+[^ ]+ [^ ]+[ ]+//')

        # 获取用户和IP（优化版）
        local user_ip="${SSH_CLIENT:-localhost}"
        user_ip="${user_ip%% *}"

        # 格式化输出
        printf "%5d  [%s][%s][%s] %s\n" \
               "$cmd_num" \
               "$time_part" \
               "$USER" \
               "$user_ip" \
               "$cmd"
        ((count++))
    done < <(builtin history | tail -n $((max_lines + 1)) | head -n $max_lines)
}

# 提示符设置（兼容所有发行版）
PS1='[\u@\h \W]\$ '
EOF

# =============================================
# 安全激活配置
# =============================================
echo -e "\033[32m配置完成！执行以下命令立即生效:\033[0m"
echo "  source ~/.bashrc && history"
