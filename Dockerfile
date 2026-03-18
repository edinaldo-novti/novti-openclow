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

# 4. Copia a configuração padrão para um diretório temporário
COPY openclaw.json /app/openclaw.json

# Comando de inicialização do Openclaw
# 1. Garante que o diretório de dados existe
# 2. Se o arquivo já existir no volume, roda o 'doctor --fix' para remover chaves depreciadas (como models.primary)
# 3. Se NÃO existir, copia o arquivo padrão do projeto
CMD ["sh", "-c", "mkdir -p /root/.openclaw && if [ -f /root/.openclaw/openclaw.json ]; then openclaw doctor --fix --yes; else cp /app/openclaw.json /root/.openclaw/openclaw.json; fi; exec openclaw gateway run --allow-unconfigured --port 8080 --bind lan --token \"$OPENCLOW_GATEWAY_TOKEN\" --verbose"]
