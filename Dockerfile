# ============================================================
# OpenClow (Openflow) — Ubuntu Base Dockerfile
# ============================================================

FROM ubuntu:22.04

LABEL maintainer="OpenClow Team"
LABEL org.opencontainers.image.source="https://github.com/edinaldo-novti/novti-openclow"
LABEL org.opencontainers.image.description="OpenClow — Instalado via script oficial na base Ubuntu"

# Configurações não-interativas para evitar prompts no apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Define o método de instalação pro script do OpenClaw não perguntar
ENV OPENCLAW_INSTALL_METHOD=npm
ENV NO_ONBOARD=1

# 1. Instala dependências base de sistema requeridas pelo Node e OpenClaw
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    build-essential \
    python3 \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Configura NodeSource para Node.js 22 e instala
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Instala OpenClaw globalmente via npm
RUN npm install -g openclaw@latest

# Exporta PATH, caso o script oficial o coloque em ~/.local/bin
ENV PATH="/root/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH}"

# Porta padrão do Openflow
EXPOSE 8080

# Healthcheck apontando pro endpoint nativo
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -fs http://localhost:8080/healthz || exit 1

# Comando de inicialização do Openclaw
# Configurações são lidas preferencialmente de variáveis de ambiente
CMD ["openclaw", "gateway", "--allow-unconfigured"]
