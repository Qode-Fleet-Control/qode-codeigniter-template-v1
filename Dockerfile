# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# CodeIgniter 4 on FrankenPHP (a Caddy-based PHP app server): docroot public/,
# CI_ENVIRONMENT=production, served on 0.0.0.0:$PORT with the PORT read from the
# environment when the container STARTS (docker/entrypoint.sh).
FROM dunglas/frankenphp:1-php8.4-bookworm AS runtime
RUN install-php-extensions intl pdo_pgsql pgsql zip
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction
COPY . .
RUN composer dump-autoload --optimize --no-dev --no-interaction \
 && useradd -r -u 10001 -d /app app \
 && chown -R app:app writable /config/caddy /data/caddy \
 && chmod +x docker/entrypoint.sh
ARG BUILD_ID=""
ENV PORT=8080 SERVER_ROOT=/app/public CI_ENVIRONMENT=production BUILD_ID=$BUILD_ID
USER app
EXPOSE 8080
ENTRYPOINT ["docker/entrypoint.sh"]
