# CodeIgniter template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with the
stock CodeIgniter 4 app starter laid on top, served by FrankenPHP.

## Origin

    docker run --rm -u $(id -u):$(id -g) -v "$PWD":/w -w /w <php8.4 + composer:2 image> \
      composer create-project codeigniter4/appstarter qode-codeigniter-template-v1 --prefer-dist --no-interaction

Generated 2026-10-05 (codeigniter4/appstarter, codeigniter4/framework ^4.7, PHP 8.4.26 —
the PHP the image runs). `vendor/` was removed; `composer.lock` is kept.

## Run it

**On the fleet** — nothing to do: `bin/run` (docker runtime) does `docker compose build`
then `docker compose up --remove-orphans` in the foreground. The app listens on
`0.0.0.0:$PORT`; `HEALTH_PATH=/health`; `/` is the stock welcome page.

**With docker**

    PORT=8080 bin/run              # or: docker compose up --build
    curl localhost:8080/health

**Without docker** (PHP 8.2+ with intl and mbstring, composer):

    FLEET_RUNTIME=process PORT=8080 bin/run
    # = composer install; php spark serve --host 0.0.0.0 --port $PORT

| step | process runtime | docker runtime |
|---|---|---|
| install | `composer install --no-interaction` | — |
| build | — | `docker compose build` |
| start | `php spark serve --host 0.0.0.0 --port $PORT` | `docker compose up --remove-orphans` |

## How the container works

- `Dockerfile`: `dunglas/frankenphp:1-php8.4-bookworm` (+ intl, pdo_pgsql, pgsql, zip),
  `composer install --no-dev`, `CI_ENVIRONMENT=production`, non-root user `app` owning
  `writable/`.
- `docker/entrypoint.sh`: defaults `app_baseURL` (CodeIgniter's `app.baseURL` as an env
  var) to `$FLEET_APP_URL/` so generated links point at the public URL, then serves with
  FrankenPHP's stock Caddyfile on `SERVER_NAME=":$PORT"` (plain HTTP on the runtime
  `$PORT`), document root `public/`.
- Database: the starter configures none; CodeIgniter reads `database.default.*` env vars
  (see the `env` file) — map the fleet's `PG*` variables onto them when you add one.

## Deviations from the stock generator output, and why

- `app/Config/Routes.php`: a `/health` route returning `{"status":"ok"}` — the fleet's
  health check.
- Added `Dockerfile`, `docker/entrypoint.sh`, `compose.yaml`, `.dockerignore`,
  `fleet.conf`, `bin/`, `.github/workflows/`, `docs/fleet-lifecycle.md`; `.gitignore`
  gained `.fleet/`, `.fleet-deploy.log`, `*.log`.

## Verified

**Not verified yet.** The `docker compose build` / `verify.sh` run was never reached: on
2026-10-05 the shared docker host's disk sat at 0-2 GB free (98 GB volume at 99-100%)
for more than three hours, below the 6 GB gate builds wait for. Before trusting this
template, run `verify.sh <dir> <port>` (run, restart and stop must all pass).

What *was* checked: `migrate.py audit` → READY; `php -l` on every PHP file this template
added or changed, and `sh -n` on its shell scripts → clean.

See `docs/fleet-lifecycle.md` for the lifecycle scripts.
