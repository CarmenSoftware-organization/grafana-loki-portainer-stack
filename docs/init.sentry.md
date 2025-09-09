docker-compose exec sentry sentry upgrade --noinput 

docker-compose exec sentry sentry createuser --email admin@localhost --password admin123 --superuser --no-input

user : admin@localhost
pass : admin123