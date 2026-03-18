#!/usr/bin/env bash
# ============================================================
# OpenClow — Setup Ambiente de Desenvolvimento
# ============================================================
# Uso: chmod +x scripts/setup-dev.sh && ./scripts/setup-dev.sh
# ============================================================

set -euo pipefail

# ----- Cores para output -----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ----- Funções auxiliares -----
log_info()    { echo -e "${BLUE}ℹ ${NC} $1"; }
log_success() { echo -e "${GREEN}✅${NC} $1"; }
log_warn()    { echo -e "${YELLOW}⚠️ ${NC} $1"; }
log_error()   { echo -e "${RED}❌${NC} $1"; }
log_step()    { echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${CYAN}▶ $1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ----- Banner -----
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║           🚀 OpenClow — Dev Setup                 ║"
echo "║     Plataforma de Automação e Orquestração        ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ==================== 1. Verificar Dependências ====================
log_step "1/5 — Verificando dependências"

# Docker
if command -v docker &>/dev/null; then
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_success "Docker encontrado: v${DOCKER_VERSION}"
else
    log_error "Docker não encontrado! Instale em: https://docs.docker.com/get-docker/"
    exit 1
fi

# Docker Compose (v2 plugin)
if docker compose version &>/dev/null; then
    COMPOSE_VERSION=$(docker compose version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_success "Docker Compose encontrado: v${COMPOSE_VERSION}"
else
    log_error "Docker Compose (plugin v2) não encontrado!"
    log_info  "Instale via: https://docs.docker.com/compose/install/"
    exit 1
fi

# Docker daemon running
if docker info &>/dev/null; then
    log_success "Docker daemon está rodando"
else
    log_error "Docker daemon não está rodando. Inicie o Docker Desktop ou o serviço dockerd."
    exit 1
fi

# ==================== 2. Configurar .env ====================
log_step "2/5 — Configurando variáveis de ambiente"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

if [ -f .env ]; then
    log_warn ".env já existe — mantendo configuração atual"
    log_info  "Para resetar: rm .env && execute este script novamente"
else
    cp .env.example .env
    log_success ".env criado a partir de .env.example"
    log_warn "⚠️  Revise o arquivo .env e altere as senhas padrão antes de usar em produção!"
fi



# ==================== 4. Criar diretórios de dados ====================
log_step "4/5 — Preparando diretórios"

mkdir -p logs
log_success "Diretório 'logs/' pronto"

# ==================== 5. Subir o ambiente ====================
log_step "5/5 — Iniciando containers"

log_info "Executando: docker compose up -d --build"
echo ""

docker compose up -d --build

echo ""
log_success "Todos os containers foram iniciados!"

# ==================== Resumo ====================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  🎉 Ambiente de Desenvolvimento Pronto!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BLUE}Openflow:${NC}       http://localhost:8080"
echo -e "  ${BLUE}Portainer:${NC}      https://localhost:9443"
echo -e "  ${BLUE}Prometheus:${NC}     http://localhost:9090"
echo -e "  ${BLUE}Grafana:${NC}        http://localhost:3000"
echo ""
echo -e "  ${YELLOW}Dica:${NC} Execute ${CYAN}docker compose ps${NC} para verificar o status"
echo -e "  ${YELLOW}Dica:${NC} Execute ${CYAN}docker compose logs -f openflow${NC} para ver os logs"
echo ""
