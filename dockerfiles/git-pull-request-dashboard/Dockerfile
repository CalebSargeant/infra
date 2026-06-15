# Builds AKharytonchyk/git-pull-request-dashboard (a client-side Vite/React SPA;
# no upstream container image is published) and serves the static bundle with a
# rootless nginx. The GitHub PAT is entered in the browser at runtime — there is
# no server-side config or secret. VITE_* settings are build-time only; the
# defaults target github.com (api.github.com), which is what we want.
#
# Pinned to the upstream release tag for reproducibility. Bump APP_VERSION (and
# the image tag pushed by docker-publish.yml) together when upgrading.
ARG APP_VERSION=1.3.1

FROM node:22-alpine AS build
ARG APP_VERSION
WORKDIR /app
# Remote tarballs are NOT auto-extracted by ADD — fetch then untar.
ADD https://github.com/AKharytonchyk/git-pull-request-dashboard/archive/refs/tags/v${APP_VERSION}.tar.gz /tmp/src.tar.gz
RUN tar -xzf /tmp/src.tar.gz --strip-components=1 -C /app \
    && npm ci \
    && npm run build

FROM ghcr.io/nginxinc/nginx-unprivileged:1.27-alpine
# SPA routing (try_files → index.html); listens on 8080 as the non-root nginx user.
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
