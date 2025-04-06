#!/bin/bash

# =============================================
# 还原.bashrc文件的脚本
# =============================================

# 定义.bashrc文件的路径
BASHRC_FILE="$HOME/.bashrc"

# 查找最新的备份文件
LATEST_BACKUP=$(ls -t "$HOME/.bashrc_backup_"* | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    echo -e "\033[31m错误：找不到任何.bashrc备份文件。\033[0m"
    exit 1
fi

# 确认还原操作
echo -e "\033[32m找到最新备份文件: $LATEST_BACKUP\033[0m"
read -p "确定要还原到此备份吗？ (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 创建当前.bashrc的备份
    cp -p "$BASHRC_FILE" "$BASHRC_FILE.bak_$(date +%Y%m%d_%H%M%S)"
    echo "已备份当前.bashrc到 $BASHRC_FILE.bak_$(date +%Y%m%d_%H%M%S)"

    # 还原.bashrc
    cp -p "$LATEST_BACKUP" "$BASHRC_FILE"
    echo -e "\033[32m.bashrc文件已成功还原到备份状态。\033[0m"

    # 自动执行source ~/.bashrc
    source "$BASHRC_FILE"
    echo -e "\n\033[32m已自动执行 'source ~/.bashrc' 命令以应用新配置。\033[0m"

    # 提示用户查看还原后的效果
    echo -e "\n\033[33m还原操作已完成，您可以继续使用终端或执行以下命令查看效果：\033[0m"
    echo "  history"
else
    echo -e "\033[33m操作已取消，未进行还原。\033[0m"
fi
