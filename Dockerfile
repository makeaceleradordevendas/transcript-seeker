# ---------- Fase 1: build ----------
FROM node:20-slim AS builder
WORKDIR /app
COPY . .
# PNPM já vem no Node 20 via Corepack
RUN corepack enable \
 && corepack prepare pnpm@latest --activate \
 && pnpm install --no-frozen-lockfile \
 && pnpm run build

# ---------- Fase 2: runtime --------
FROM node:20-slim
WORKDIR /app
ENV NODE_ENV=production
# copia apenas o bundle compilado
COPY --from=builder /app/apps/web/.output ./.output
COPY package.json pnpm-lock.yaml ./
RUN corepack enable \
 && corepack prepare pnpm@latest --activate \
 && pnpm install --prod --frozen-lockfile
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]
