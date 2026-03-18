# 🚀 OpenClow — Plataforma de Automação e Orquestração

> Infraestrutura DevOps profissional simplificada para o OpenClaw, com persistência SQLite nativa, CI/CD automatizado e monitoramento integrado.

---

## 📐 Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│                      Traefik (Gateway)                       │
│                    :80 → :443 (TLS)                          │
└─────┬────────────────────────────────────────────────────────┘
      │
      ▼
 ┌─────────┐
 │ Openflow│
 │  :8080  │
 └────┬────┘
      │
      └──── SQLite (Persistência Nativa via Volume)
```

### Stack de Serviços

| Serviço         | Papel                        | Dev Port |
|-----------------|------------------------------|----------|
| **Openflow**    | Plataforma principal (Gateway)| `8080`   |
| **Traefik**     | Gateway / Reverse Proxy (Prod)| `80/443` |

---

## ⚡ Quick Start (≤ 3 comandos)

```bash
# 1. Clone o repositório
git clone https://github.com/edinaldo-novti/novti-openclow.git && cd openclow

# 2. Configure o ambiente
cp .env.example .env

# 3. Suba o ambiente completo
docker compose up -d
```

Pronto! Acesse `http://localhost:8080` para o Openflow.

---

## 📂 Estrutura de Arquivos

```
openclow/
├── Dockerfile                       # Build otimizado (Ubuntu 22.04 + Node 22)
├── docker-compose.yml               # Ambiente de Desenvolvimento
├── docker-compose.prod.yml          # Ambiente de Produção (Coolify)
├── .env.example                     # Template de variáveis de ambiente
├── .github/
│   └── workflows/
│       └── deploy.yml               # CI/CD (Build → GHCR → Coolify)
├── config/
│   └── traefik/
│       └── traefik.yml              # Configuração do Traefik (Prod)
├── monitoring/
│   ├── prometheus/
│   │   └── prometheus.yml           # Scrape configs
│   └── grafana/
│       └── provisioning/
│           └── datasources/
│               └── datasource.yml   # Auto-provisioning Prometheus
└── README.md                        # Documentação Geral
```

---

## 🔧 Configuração

### Variáveis de Ambiente

As variáveis mais importantes:

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `OPENCLOW_GATEWAY_TOKEN` | Token de acesso ao Gateway | ⚠️ Altere! |
| `OPENFLOW_ADMIN_PASSWORD` | Senha administrativa | `Admin@Dev2026` |
| `DOMAIN` | Domínio base (prod) | `ia.nogui.com.br` |

---

## 🐳 Ambientes

### Desenvolvimento

```bash
docker compose up -d          # Subir
docker compose ps              # Verificar status
docker compose logs -f         # Ver logs
```

### Produção (Coolify)

```bash
# OBRIGATÓRIO: Criar a rede 'coolify' no servidor ANTES do primeiro deploy
docker network create coolify 2>/dev/null || true

# Subir via terminal (ou via interface do Coolify)
docker compose -f docker-compose.prod.yml up -d
```

**Diferenças chave vs Dev:**
- ✅ TLS automático via Let's Encrypt para `ia.nogui.com.br`.
- ✅ Persistência definitiva de pareamento via volume `openclaw_data`.
- ✅ Limites de recursos (CPU/Memória).

---

## 🔄 CI/CD

O pipeline GitHub Actions executa o build multi-arquitetura e dispara o webhook do Coolify automaticamente ao fazer push na branch `main`.

---

## 🛡️ Segurança

- [ ] Lembre-se de alterar as senhas no `.env` de produção.
- [ ] O **Gateway Token** é injetado automaticamente e salvo de forma persistente.
