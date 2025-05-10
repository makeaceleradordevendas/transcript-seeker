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

# Copia todos os arquivos necessários para o ambiente de produção
COPY --from=builder /app ./

# Instala apenas dependências de produção com pnpm
RUN corepack enable \
  && corepack prepare pnpm@latest --activate \
  && pnpm install --prod

# Define o comando de execução, se necessário
# CMD ["pnpm", "start"]
