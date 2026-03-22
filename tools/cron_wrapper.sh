#!/bin/bash
# cron_wrapper.sh — 从 macOS Keychain 注入密钥后执行命令
# 用法: cron_wrapper.sh <command> [args...]
#
# Cron 不加载 .zshrc，所以 aks 不可用。
# 这个脚本在 crontab 中替代 aks 的角色。

set -euo pipefail

WS="/Users/jack/Projects/PersonalAssistant"
PYTHON="$WS/.venv/bin/python"

# --- 从 Keychain 加载密钥 ---
load_key() {
    local var_name="$1"
    local keychain_label="$2"
    local value

    value=$(security find-generic-password -s "$keychain_label" -w 2>/dev/null) || \
    value=$(security find-generic-password -a "$keychain_label" -w 2>/dev/null) || \
    value=""

    if [ -n "$value" ]; then
        export "$var_name"="$value"
    fi
}

# OpenCode Server
load_key "OPENCODE_PASSWORD" "OPENCODE_SERVER_PASSWORD"

# Gmail（crontab_monitor 告警用）
load_key "GMAIL_USERNAME" "GMAIL_USERNAME"
load_key "GMAIL_APP_PASSWORD" "GMAIL_APP_PASSWORD"
load_key "GMAIL_RECIPIENTS" "GMAIL_RECIPIENTS"

# OpenAI（语义搜索 cloud 方案，可选）
load_key "OPENAI_API_KEY" "OPENAI_API_KEY"

# --- 执行传入的命令 ---
cd "$WS"
exec "$PYTHON" "$@"
