FROM node:22-bookworm-slim AS build

WORKDIR /app

COPY package.json package-lock.json tsconfig.json ./
RUN npm ci

COPY src ./src
COPY docs ./docs
COPY README.md LICENSE ./
COPY .env.example ./

RUN npm run build

FROM node:22-bookworm-slim AS runtime

ENV NODE_ENV=production \
    UI_MODE=true \
    MONITOR_CONTINUOUS=true \
    UI_PORT=4310 \
    UI_BIND_ADDRESS=0.0.0.0

WORKDIR /app

COPY --from=build /app/dist ./dist
COPY --from=build /app/docs ./docs
COPY --from=build /app/README.md ./README.md
COPY --from=build /app/LICENSE ./LICENSE
COPY --from=build /app/.env.example ./.env.example

RUN mkdir -p /app/runtime && chown -R node:node /app

USER node

EXPOSE 4310

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch(`http://127.0.0.1:${process.env.UI_PORT || 4310}/healthz`).then((res) => process.exit(res.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "dist/index.js"]
