#!/usr/bin/env bash
# scripts/push.sh
# 手工执行：提交所有本地变更并推送到默认 remote 的当前分支。
#
# 用法：
#   ./scripts/push.sh                      # 自动生成提交信息
#   ./scripts/push.sh "feat: xxx"          # 使用指定提交信息
#   ./scripts/push.sh "msg" main           # 指定目标分支
#
# 约定：
# - 只在已配置 remote (origin) 的仓库中使用。
# - 遇到无变更时仅执行一次 push（防止因 rebase 等情况导致本地领先）。
# - 遇到冲突/非快进等异常，脚本会中断并提示人工介入，不做强推。

set -euo pipefail

# 进入仓库根目录（脚本位于 scripts/ 下）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# 参数解析
MSG="${1:-}"
BRANCH="${2:-$(git rev-parse --abbrev-ref HEAD)}"

# 默认提交信息
if [[ -z "$MSG" ]]; then
  TS="$(date +'%Y-%m-%d %H:%M')"
  MSG="chore: daily snapshot $TS"
fi

echo "==> 仓库: $REPO_ROOT"
echo "==> 分支: $BRANCH"
echo "==> 提交信息: $MSG"

# 检查 remote
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "!! 尚未配置 origin remote，请先执行：" >&2
  echo "   git remote add origin <your-github-url>" >&2
  exit 1
fi

# 检查工作区是否有变更
if [[ -z "$(git status --porcelain)" ]]; then
  echo "==> 工作区无变更，跳过 commit。"
else
  git add -A
  git commit -m "$MSG"
  echo "==> 已创建新提交。"
fi

# 检查本地与远程是否有 diff 需要推送
LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git ls-remote origin "refs/heads/$BRANCH" | awk '{print $1}')"

if [[ "$LOCAL_HEAD" == "$REMOTE_HEAD" ]]; then
  echo "==> 本地与远程 $BRANCH 一致，无需 push。"
  exit 0
fi

echo "==> 推送到 origin/$BRANCH ..."
git push origin "$BRANCH"
echo "==> Done."
