#!/bin/sh
# QuantDinger Docker Entrypoint Script
set -e
echo "============================================"
echo "  QuantDinger Backend - Starting..."
echo "============================================"

# Check if .env file exists
if [ ! -f /app/.env ]; then
    echo "[INFO] No .env file mounted, generating from environment variables..."
    
    # Generate SECRET_KEY if not provided
    if [ -z "$SECRET_KEY" ]; then
        SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
        echo "[AUTO] Generated random SECRET_KEY."
    fi

    printf "SECRET_KEY=%s\n" "$SECRET_KEY" > /app/.env
    printf "ADMIN_USER=%s\n" "${ADMIN_USER:-quantdinger}" >> /app/.env
    printf "ADMIN_PASSWORD=%s\n" "${ADMIN_PASSWORD:-changeme}" >> /app/.env
    printf "DEBUG=%s\n" "${DEBUG:-False}" >> /app/.env
    printf "DOMAIN=%s\n" "${DOMAIN:-}" >> /app/.env
    printf "DATABASE_URL=%s\n" "${DATABASE_URL:-}" >> /app/.env
    printf "DB_TYPE=%s\n" "${DB_TYPE:-postgresql}" >> /app/.env
    printf "POSTGRES_PASSWORD=%s\n" "${POSTGRES_PASSWORD:-}" >> /app/.env
    printf "REDIS_URL=%s\n" "${REDIS_URL:-redis://redis:6379/0}" >> /app/.env
    printf "FRONTEND_URL=%s\n" "${FRONTEND_URL:-}" >> /app/.env
    printf "LLM_PROVIDER=%s\n" "${LLM_PROVIDER:-}" >> /app/.env
    printf "OPENAI_API_KEY=%s\n" "${OPENAI_API_KEY:-}" >> /app/.env
    printf "OPENAI_BASE_URL=%s\n" "${OPENAI_BASE_URL:-}" >> /app/.env
    printf "OPENAI_MODEL=%s\n" "${OPENAI_MODEL:-}" >> /app/.env
    printf "MISTRAL_API_KEY=%s\n" "${MISTRAL_API_KEY:-}" >> /app/.env
    printf "ENABLE_PENDING_ORDER_WORKER=%s\n" "${ENABLE_PENDING_ORDER_WORKER:-true}" >> /app/.env
    printf "ENABLE_PORTFOLIO_MONITOR=%s\n" "${ENABLE_PORTFOLIO_MONITOR:-true}" >> /app/.env
    printf "AGENT_LIVE_TRADING_ENABLED=%s\n" "${AGENT_LIVE_TRADING_ENABLED:-false}" >> /app/.env
    printf "BILLING_ENABLED=%s\n" "${BILLING_ENABLED:-false}" >> /app/.env
    printf "USDT_PAY_ENABLED=%s\n" "${USDT_PAY_ENABLED:-false}" >> /app/.env
    printf "ENABLE_REGISTRATION=%s\n" "${ENABLE_REGISTRATION:-true}" >> /app/.env

    echo "[OK] Generated .env from environment variables"
fi

# Check SECRET_KEY configuration
DEFAULT_SECRET="quantdinger-secret-key-change-me"
CURRENT_SECRET=$(grep -E "^SECRET_KEY=" /app/.env 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'" | xargs || echo "")

if [ -z "$CURRENT_SECRET" ]; then
    NEW_SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    echo "SECRET_KEY=${NEW_SECRET}" >> /app/.env
    echo "[AUTO] Generated random SECRET_KEY (was missing)."
fi

if [ "$CURRENT_SECRET" = "$DEFAULT_SECRET" ]; then
    NEW_SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    sed -i "s|SECRET_KEY=.*|SECRET_KEY=${NEW_SECRET}|" /app/.env
    echo "[AUTO] Generated random SECRET_KEY (was default)."
fi

echo "[OK] SECRET_KEY is configured"
echo ""

exec "$@"
