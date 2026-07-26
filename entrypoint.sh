#!/bin/bash
set -e

# Adjust Apache port dynamically for Render ($PORT)
if [ -n "$PORT" ]; then
    sed -i "s/80/$PORT/g" /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf
fi

# Ensure SQLite database exists
mkdir -p /var/www/html/database
if [ ! -f /var/www/html/database/database.sqlite ]; then
    touch /var/www/html/database/database.sqlite
fi
chown -R www-data:www-data /var/www/html/database

# Ensure storage directories exist with proper permissions
mkdir -p /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/storage/framework/cache \
         /var/www/html/storage/app/public

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Link storage
php artisan storage:link --force || true

# Run database migrations
php artisan migrate --force

# Optimize Laravel
php artisan config:clear
php artisan route:cache
php artisan view:cache

exec apache2-foreground
