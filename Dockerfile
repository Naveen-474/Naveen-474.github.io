FROM webdevops/php-nginx:8.2-alpine

# Install Laravel framework system requirements (https://laravel.com/docs/8.x/deployment#optimizing-configuration-loading)
RUN apk update
RUN apk add oniguruma-dev libxml2-dev postgresql-dev supervisor
# Copy Composer binary from the Composer official Docker image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV WEB_DOCUMENT_ROOT /app/public

ENV APP_NAME Blog
ENV APP_ENV production
ENV APP_KEY base64:JBz16AWl38AQHW713IICBhPyA1s5HcW5sT+g0bFZ5QU=
ENV APP_DEBUG false
ENV APP_URL http://127.0.0.1

ENV LOG_CHANNEL stack
ENV LOG_DEPRECATIONS_CHANNEL null
ENV LOG_LEVEL debug

ENV DB_CONNECTION pgsql
ENV DB_HOST pgsql
ENV DB_PORT 5432
ENV DB_DATABASE blog
ENV DB_USERNAME postgres
ENV DB_PASSWORD password

ENV BROADCAST_DRIVER log
ENV CACHE_DRIVER file
ENV FILESYSTEM_DISK local
ENV QUEUE_CONNECTION database
ENV SESSION_DRIVER file
ENV SESSION_LIFETIME 120

ENV MAIL_MAILER smtp
ENV MAIL_HOST smtp.mailtrap.io
ENV MAIL_PORT 2525
ENV MAIL_USERNAME c70f09c3caf1ce
ENV MAIL_PASSWORD 2f6967a69dc619
ENV MAIL_ENCRYPTION tls
ENV MAIL_FROM_ADDRESS ""
ENV MAIL_FROM_NAME "${APP_NAME}"
ENV MAIL_TO_ADDRESS " "

WORKDIR /app
COPY . .

RUN composer install --no-interaction --optimize-autoloader --no-dev
# Optimizing Configuration loading
RUN php artisan config:cache
# Optimizing Route loading
RUN php artisan route:cache
# Optimizing View loading
RUN php artisan view:cache

RUN chown -R application:application .

RUN mkdir -p /etc/supervisor/conf.d

# Create a Supervisor configuration file for the queue:work command
#RUN mv supervisor/* /opt/docker/etc/supervisor.d/

RUN (crontab -l ; echo "* * * * * cd /app && php artisan schedule:run >> /dev/null 2>&1") | crontab -
