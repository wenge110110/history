#!/bin/bash

# =============================================
# 安全初始化检查
# =============================================
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc_backup_$(date +%Y%m%d_%H%M%S)"

# 备份原文件（跳过超大文件）
if [ -f "$BASHRC_FILE" ]; then
    file_size=$(du -k "$BASHRC_FILE" | cut -f1)
    if [ "$file_size" -lt 1024 ]; then  # 小于1MB才备份
        cp -p "$BASHRC_FILE" "$BACKUP_FILE" && echo "备份成功: $BACKUP_FILE"
    else
        echo "警告: .bashrc 文件过大，跳过备份"
    fi
else
    echo "# 初始化.bashrc" > "$BASHRC_FILE"
    echo "[ -f /etc/bashrc ] && . /etc/bashrc" >> "$BASHRC_FILE"
fi

# =============================================
# 绝对安全的 history 实现
# =============================================
cat << 'EOF' >> "$BASHRC_FILE"

# 历史记录格式（兼容无HISTTIMEFORMAT的系统）
export HISTTIMEFORMAT="%Y-%m-%d %T  "

# 安全无递归的 history 命令
safe_history() {
    # 使用内置命令获取原始历史（最多100条）
    local hist_lines=$(HISTTIMEFORMAT="%s " builtin history 100 | sed '1d')

    # 解析每一行（完全避免awk/sed递归问题）
    while IFS= read -r line; do
        # 提取命令编号、时间戳和命令内容
        local cmd_num=${line%% *}
        local rest=${line#* }
        local timestamp=${rest%% *}
        local cmd=${rest#* }

        # 转换时间戳（如果是数字）
        if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
            local time_str=$(date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S")
        else
            local time_str="$timestamp"
        fi

        # 获取用户和IP（安全方式）
        local user_ip="$(who -m 2>/dev/null | awk '{print $NF}' | tr -d '()')"
        [ -z "$user_ip" ] && user_ip="localhost"

        # 格式化输出
        printf "%5d  [%s][%s][%s] %s\n" \
               "$cmd_num" \
               "$time_str" \
               "$(whoami)" \
               "$user_ip" \
               "$cmd"
    done <<< "$hist_lines"
}

# 替换默认 history
alias history='safe_history'

# 提示符设置（兼容所有主流发行版）
[ "$(id -u)" -eq 0 ] && PS1='[\u@\h \W]# ' || PS1='[\u@\h \W]\$ '
EOF

# =============================================
# 安全加载配置
# =============================================
if ! source "$BASHRC_FILE"; then
    echo "警告: 部分配置需要重新登录生效"
else
    echo "配置已立即生效"
fi

echo -e "\n\033[32m修复完成！现在可以正常使用 history 命令\033[0m"
