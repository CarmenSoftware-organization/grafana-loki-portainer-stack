docker-compose exec sentry sentry upgrade --noinput 

docker-compose exec sentry sentry createuser --email carmensoftware.dev@gmail.com --password Carmen@2024 --superuser --no-input