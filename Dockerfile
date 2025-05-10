###############################################################################
# ETAPA 1 – Build (gera o /apps/web/dist)
###############################################################################
FROM node:20-slim AS builder

# 1. diretório de trabalho
WORKDIR /app

# 2. copia o monorepo inteiro
COPY . .

# 3. habilita o pnpm via Corepack e instala dependências
RUN corepack enable \
 && corepack prepare pnpm@latest --activate \
 && pnpm install --no-frozen-lockfile

# 4. compila **apenas** o front-end (e ignora a pasta docs)
RUN pnpm exec turbo run build --filter=@meeting-baas/web --filter=!@meeting-baas/docs

###############################################################################
# ETAPA 2 – Imagem final (apenas os arquivos estáticos + servidor “serve”)
###############################################################################
FROM node:20-slim AS runner

# 1. diretório de trabalho
WORKDIR /app

# 2. copia a pasta dist gerada na etapa de build
COPY --from=builder /app/apps/web/dist ./dist

# 3. instala o servidor estático “serve” globalmente (minúsculo: ≅ 3 MB)
RUN npm install -g serve

# 4. (opcional) variável de ambiente para produção
ENV NODE_ENV=production

# 5. expõe a porta interna que o container usará
EXPOSE 3000

# 6. comando que mantém o container vivo
CMD ["serve", "-s", "dist", "-l", "3000"]
