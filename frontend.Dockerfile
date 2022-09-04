FROM node:18-bullseye-slim AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y ca-certificates tzdata fonts-noto-cjk && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /frontend
COPY ./frontend/package.json ./frontend/pnpm-lock.yaml /frontend/

# 開発環境
FROM base AS development

COPY ./scripts/* /bin/
WORKDIR /frontend
COPY ./frontend /frontend

ENTRYPOINT [ "/bin/docker-entrypoint.frontend.sh" ]

# ビルド
FROM base AS build-frontend

WORKDIR /frontend
COPY ./frontend /frontend
RUN npm install -g pnpm
RUN pnpm i --frozen-lockfile
RUN pnpm run build

# node_modulesから本番で使わないものを取り除く
FROM build-frontend AS prune-modules

WORKDIR /frontend
RUN pnpm prune --prod

# 本番環境 install-modules
FROM base AS production

ENV NODE_ENV=production

WORKDIR /frontend
COPY --from=prune-modules /frontend/node_modules ./node_modules
COPY --from=build-frontend /frontend/.next ./.next
COPY --from=build-frontend /frontend/next.config.js ./next.config.js

RUN npm install -g pnpm
ENTRYPOINT ["pnpm", "start"]
