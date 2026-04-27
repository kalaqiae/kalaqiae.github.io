#!/bin/bash

# 获取脚本所在目录的绝对路径
# 1. ${BASH_SOURCE[0]} - 获取当前脚本的完整路径（包括文件名）
# 2. dirname "${BASH_SOURCE[0]}" - 提取脚本所在目录的路径（不包含文件名）
# 3. && pwd - 成功切换目录后，执行 pwd 命令获取当前目录的绝对路径
# 4. $(...) - 命令替换，执行里面的命令，并把结果当成字符串返回
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 切换到脚本所在目录 双引号包围变量名可以处理包含空格的路径
cd "$CURRENT_DIR"

echo "当前目录: $CURRENT_DIR"
echo "正在启动 Hugo 服务器..."

hugo server