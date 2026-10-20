#!/usr/bin/env bash
# 统一运行入口：自动准备虚拟环境、安装依赖并执行任务。
#
# 用法: ./run.sh [任务] [参数...]
#
# 任务:
#   update          抓取最近 6 年（今年及之前 4 年 + 次年）并生成 JSON/ICS（默认）
#   all             更新 2007 年至今的全部数据
#   release         更新数据并在有变化时提交、打包、发布 Release
#   fetch <年份>    抓取指定年份并打印 JSON
#   test            运行测试
#   lint            检查代码格式
#   format          格式化代码
#   help            显示帮助

set -euo pipefail

cd "$(dirname "$0")"

PYTHON="${PYTHON:-python3}"
VENV_DIR="${VENV_DIR:-.venv}"
VENV_PYTHON="$VENV_DIR/bin/python"
REQ_FILE="dev-requirements.txt"
STAMP="$VENV_DIR/.requirements.sha256"

usage() {
    sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

file_hash() {
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    else
        "$PYTHON" -c 'import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$1"
    fi
}

ensure_env() {
    if [ ! -x "$VENV_PYTHON" ]; then
        echo "==> 创建虚拟环境: $VENV_DIR"
        "$PYTHON" -m venv "$VENV_DIR"
    fi

    local hash
    hash="$(file_hash "$REQ_FILE")"
    if [ ! -f "$STAMP" ] || [ "$(cat "$STAMP")" != "$hash" ]; then
        echo "==> 安装依赖: $REQ_FILE"
        "$VENV_PYTHON" -m pip install --quiet --upgrade pip
        "$VENV_PYTHON" -m pip install --quiet -r "$REQ_FILE"
        printf '%s' "$hash" >"$STAMP"
    fi
}

cmd="${1:-update}"
shift || true

case "$cmd" in
    update)
        ensure_env
        exec "$VENV_PYTHON" scripts/update.py "$@"
        ;;
    all)
        ensure_env
        exec "$VENV_PYTHON" scripts/update.py --all "$@"
        ;;
    release)
        ensure_env
        exec "$VENV_PYTHON" scripts/update.py --release "$@"
        ;;
    fetch)
        if [ $# -lt 1 ]; then
            echo "错误: fetch 需要指定年份，例如 ./run.sh fetch 2026" >&2
            exit 1
        fi
        ensure_env
        exec "$VENV_PYTHON" scripts/fetch.py "$@"
        ;;
    test)
        ensure_env
        exec "$VENV_PYTHON" -m pytest "$@"
        ;;
    lint)
        ensure_env
        exec "$VENV_PYTHON" -m black -t py312 --check --diff . "$@"
        ;;
    format)
        ensure_env
        exec "$VENV_PYTHON" -m black -t py312 . "$@"
        ;;
    help | -h | --help)
        usage
        ;;
    *)
        echo "未知任务: $cmd" >&2
        echo "" >&2
        usage >&2
        exit 1
        ;;
esac
