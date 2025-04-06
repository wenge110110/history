# history
# History Formatter

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Shell](https://img.shields.io/badge/shell-bash-green.svg)

这是一个 Bash 脚本，用于增强 Linux 系统中的 `history` 命令，使其显示带有时间戳、用户名和 IP 地址的详细历史记录。通过覆盖默认的 `history` 命令，用户可以更方便地跟踪命令执行的上下文信息。

## 示例输出
运行 `history` 后，你将看到类似以下的输出：
    1  [2025-04-06 15:23:45][root][67.230.164.221] ls
    2  [2025-04-06 15:23:46][root][67.230.164.221] whoami
    3  [2025-04-06 15:23:47][root][67.230.164.221] pwd

## 功能
- **时间戳**：为每条命令添加精确的执行时间（格式：`YYYY-MM-DD HH:MM:SS`）。
- **用户名**：显示执行命令的用户。
- **IP 地址**：记录登录会话的 IP 地址（SSH 登录时有效，本地终端显示 `localhost`）。
- **备份支持**：在修改 `~/.bashrc` 前自动备份现有配置，避免意外覆盖。

## 安装

### 前提条件
- Linux 系统（测试于 CentOS/Ubuntu）
- Bash shell
- 对 `~/.bashrc` 文件的读写权限

### 使用方法
1. 复制如下命令
   ```bash
   wget -N --no-check-certificate "https://raw.githubusercontent.com/wenge110110/history/master/update_bashrc.sh" && chmod +x update_bashrc.sh && ./update_bashrc.sh
2. 赋予脚本执行权限：
   chmod +x update_bashrc.sh
3. 运行脚本：
   ./update_bashrc.sh
4. 测试效果：
   history

脚本会自动备份当前的 `~/.bashrc` 文件（例如 `~/.bashrc_backup_20250406_152345`），并应用新的配置。

## 脚本内容
`update_bashrc.sh` 的主要步骤包括：
1. 检查并备份现有的 `~/.bashrc`。
2. 写入自定义的 `history` 格式化逻辑。
3. 使新配置立即生效。

查看完整代码：[update_bashrc.sh](./update_bashrc.sh)。

## 注意事项
- **时间戳限制**：仅对脚本运行后的新命令生效，之前的命令可能没有时间戳。
- **IP 地址**：通过 `who` 命令提取，SSH 会话显示实际 IP，本地终端显示 `localhost`。
- **权限**：普通用户运行影响自身配置，root 用户运行影响 root 配置。
- **恢复备份**：如需恢复原始配置，运行：
   cp ~/.bashrc_backup_YYYYMMDD_HHMMSS ~/.bashrc
   source ~/.bashrc

## 贡献
欢迎通过提交 Issue 或 Pull Request 来改进此项目！如果有功能建议或问题反馈，请随时联系我。

## 作者
- GitHub: [wenge110110](https://github.com/wenge110110)

## 许可证
本项目采用 [MIT 许可证](LICENSE)。你可以自由使用、修改和分发此代码。
