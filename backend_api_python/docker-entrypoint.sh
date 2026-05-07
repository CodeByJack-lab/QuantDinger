#!/bin/sh
# QuantDinger Docker Entrypoint Script
# Checks and validates SECRET_KEY before starting the application
set -e
echo "============================================"
echo "  QuantDinger Backend - Starting..."
echo "============================================"

# Check if .env file exists
if [ ! -f /app/.env ]; then
    echo "[INFO] No .env file mounted, generating from environment variables..."
    cat > /app/.env << ENVEOF
SECRET_KEY=${SECRET_KEY:-$(python3 -c "import secrets; print(secrets.token_hex(32))")}
ADMIN_USER=${ADMIN_USER:-quantdinger}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-changeme}
DEBUG=${DEBUG:-False}
DOMAIN=${DOMAIN:-}
DATABASE_URL=${DATABASE_URL:-}
DB_TYPE=${DB_TYPE:-postgresql}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}
REDIS_URL=${REDIS_URL:-redis://redis:6379/0}
FRONTEND_URL=${FRONTEND_URL:-}
LLM_PROVIDER=${LLM_PROVIDER:-}
OPENAI_API_KEY=${OPENAI_API_KEY:-}
OPENAI_BASE_URL=${OPENAI_BASE_URL:-}
OPENAI_MODEL=${OPENAI_MODEL:-}
MISTRAL_API_KEY=${MISTRAL_API_KEY:-}
ENABLE_PENDING_ORDER_WORKER=${ENABLE_PENDING_ORDER_WORKER:-true}
ENABLE_PORTFOLIO_MONITOR=${ENABLE_PORTFOLIO_MONITOR:-true}
AGENT_LIVE_TRADING_ENABLED=${AGENT_LIVE_TRADING_ENABLED:-false}
BILLING_ENABLED=${BILLING_ENABLED:-false}
USDT_PAY_ENABLED=${USDT_PAY_ENABLED:-false}
ENABLE_REGISTRATION=${ENABLE_REGISTRATION:-true}
ENVEOF
    echo "[OK] Generated .env from environment variables"
fi

# Check SECRET_KEY configuration
DEFAULT_SECRET="quantdinger-secret-key-change-me"
CURRENT_SECRET=$(grep -E "^SECRET_KEY=" /app/.env 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'" | xargs || echo "")

if [ -z "$CURRENT_SECRET" ]; then
    NEW_SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    echo "SECRET_KEY=${NEW_SECRET}" >> /app/.env
    echo "[AUTO] Generated random SECRET_KEY (was missing)."
    CURRENT_SECRET="$NEW_SECRET"
fi

# Auto-generate SECRET_KEY if using default (zero-config experience)
if [ "$CURRENT_SECRET" = "$DEFAULT_SECRET" ]; then
    NEW_SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
    sed -i "s|SECRET_KEY=.*|SECRET_KEY=${NEW_SECRET}|" /app/.env
    echo "[AUTO] Generated random SECRET_KEY (was default)."
    echo "[TIP]  For production, set a persistent SECRET_KEY in backend_api_python/.env"
fi

echo "[OK] SECRET_KEY is configured"
echo ""

# Start the application
exec "$@"
