# Etapa 1: build
FROM node:20-slim AS builder

WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Habilita o Corepack e prepara o pnpm
RUN corepack enable \
  && corepack prepare pnpm@latest --activate \
  && pnpm install --no-frozen-lockfile \
  && pnpm exec turbo run build --filter=!@meeting-baas/docs

# Etapa 2: imagem final
FROM node:20-slim AS runner

WORKDIR /app
ENV NODE_ENV=production

# Copia apenas os artefatos necessários do build
COPY --from=builder /app/apps/web/dist ./dist

# Copia arquivos essenciais para rodar a aplicação
COPY package.json pnpm-lock.yaml ./

# Instala apenas as dependências de produção
RUN corepack enable \
  && corepack prepare pnpm@latest --activate \
  && pnpm install --prod

# Define o comando de start, se necessário
# Exemplo:
# CMD ["pnpm", "start"]
