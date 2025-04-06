#!/bin/bash

# =============================================
# 内存安全检查（防止在内存不足时运行）
# =============================================
check_memory() {
    local mem_threshold=100  # 剩余内存阈值(MB)
    local swap_threshold=50  # 剩余Swap阈值(MB)

    # 获取当前内存和Swap可用量
    read -r _ free_mem _ <<< "$(grep MemAvailable /proc/meminfo)"
    read -r _ free_swap _ <<< "$(grep SwapFree /proc/meminfo)"
    free_mem=$((free_mem / 1024))
    free_swap=$((free_swap / 1024))

    if [ "$free_mem" -lt "$mem_threshold" ] && [ "$free_swap" -lt "$swap_threshold" ]; then
        echo -e "\033[31mERROR: 内存不足（剩余内存: ${free_mem}MB | 剩余Swap: ${free_swap}MB）\033[0m"
        echo "建议操作："
        echo "1. 手动释放内存（如 kill 占用高的进程）"
        echo "2. 增加Swap空间（见脚本内提示）"
        exit 1
    fi
}

# 执行内存检查
check_memory

# =============================================
# 原有脚本功能（带优化）
# =============================================
BASHRC_FILE="$HOME/.bashrc"
BACKUP_FILE="$HOME/.bashrc_backup_$(date +%Y%m%d_%H%M%S)"

# 备份时限制文件大小（防止大文件耗尽内存）
backup_safe() {
    local max_size=10  # 最大备份文件大小(MB)
    local actual_size=$(du -m "$BASHRC_FILE" | cut -f1)

    if [ "$actual_size" -gt "$max_size" ]; then
        echo -e "\033[33mWARN: .bashrc 文件过大（${actual_size}MB），跳过备份以避免内存问题\033[0m"
        return
    fi

    cp "$BASHRC_FILE" "$BACKUP_FILE" && echo "备份成功: $BACKUP_FILE" || {
        echo -e "\033[31m备份失败！请检查权限或磁盘空间\033[0m"
        exit 1
    }
}

[ -f "$BASHRC_FILE" ] && backup_safe || {
    echo "# 初始化.bashrc" > "$BASHRC_FILE"
    echo "[ -f /etc/bashrc ] && . /etc/bashrc" >> "$BASHRC_FILE"
}

# =============================================
# 安全写入配置（限制资源使用）
# =============================================
apply_config() {
    # 使用ulimit限制子进程资源
    ulimit -Sv 100000  # 限制内存使用为100MB

    cat << 'EOF' >> "$BASHRC_FILE"

# ===== 安全增强配置 =====
# 历史记录优化（带资源限制）
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
history() {
    # 限制输出行数（防止内存溢出）
    builtin history 50 | awk '{
        printf "%5d  [%s][%s][%s] %s\n", 
            $1, $2" "$3, ENVIRON["USER"], 
            ENVIRON["SSH_CLIENT"] ? $1 : "localhost", 
            substr($0, index($0,$3)+3
    }'
}

# 内存敏感的PS1提示符
[ "$(id -u)" -eq 0 ] && PS1='[\u@\h \W]# ' || PS1='[\u@\h \W]\$ '

# 防止内存泄漏的别名
alias ll='ls -lh --color=auto --group-directories-first | head -n 50'
EOF
}

apply_config || {
    echo -e "\033[31m配置写入失败！可能是资源不足\033[0m"
    exit 1
}

# =============================================
# 轻量级加载配置
# =============================================
source "$BASHRC_FILE" >/dev/null 2>&1 || {
    echo -e "\033[33mWARN: 部分配置可能需要重新登录生效\033[0m"
}

# 最终检查
echo -e "\033[32m脚本执行完成！\033[0m"
echo -e "当前内存状态:"
free -h | grep -E "Mem|Swap"
