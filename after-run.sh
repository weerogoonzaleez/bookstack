#!/usr/bin/env bash
cd /var/bookstack
php artisan key:generate
php artisan migrate

chown www-data:www-data public/ -R
chown www-data:www-data storage/ -R

chmod 755 public/ -R
chmod 755 storage/ -R