#!/bin/bash
echo "${key_ssh_dev}" > /home/ubuntu/.ssh/authorized_keys
echo "${key_ssh_user}" >> /home/ubuntu/.ssh/authorized_keys
chown ubuntu: /home/ubuntu/.ssh/authorized_keys
chmod 0600 /home/ubuntu/.ssh/authorized_keys
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get autoremove -y
sudo apt install \
wget curl zip unzip \
nginx-full \
mysql-server \
python-certbot-nginx \
php7.2-fpm \
php7.2-common \
php7.2-curl php7.2-cli \
php7.2-mysql \
php7.2-gd \
php7.2-xml \
php7.2-json \
php7.2-intl \
php-pear \
php7.2-dev \
php7.2-common \
php7.2-mbstring \
php7.2-zip \
php7.2-soap \
php7.2-bcmath \
php7.2-opcache -y -y

sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.2/fpm/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.2/fpm/php.ini
sudo sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php/7.2/fpm/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.2/cli/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.2/cli/php.ini
sudo sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php/7.2/cli/php.ini
sudo systemctl restart php7.2-fpm
sudo mysql -u root -pmagento -e "create database magento; GRANT ALL PRIVILEGES ON magento.* TO magento@localhost IDENTIFIED BY 'magento'"

cd /var/www/html
export COMPOSER_HOME="$HOME/.config/composer"
sudo chmod 777 /usr/local/bin/

sudo curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer composer --version=1.10.17
sudo chmod 755 /usr/local/bin/

sudo wget -q https://github.com/magento/magento2/archive/2.3.5.tar.gz && tar -xf 2.3.5.tar.gz && rm 2.3.5.tar.gz
mv magento2-*/ magento2/
cd /var/www/html/magento2/
sudo composer install
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
sudo chown -R :www-data .
sudo chmod u+x bin/magento

bin/magento setup:install \
--base-url=https://${alb_dns} \
--db-host=${db-host} \
--db-name=${db-name} \
--db-user=${db-user} \
--db-password=${db-password} \
--backend-frontname=${backend-frontname} \
--admin-firstname=${admin-firstname} \
--admin-lastname=${admin-lastname} \
--admin-email=${admin-email} \
--admin-user=${admin-user} \
--admin-password=${admin-password} \
--language=${language} \
--currency=${currency} \
--timezone=${timezone} \
--use-rewrites=1

cd /var/www/html/magento2/bin
./magento deploy:mode:set developer
sudo sed -i '/types_hash_max_size 2048;/ a\
        server_names_hash_bucket_size 1024;' /etc/nginx/nginx.conf

rm -rf /etc/nginx/sites-available/default
rm -rf /etc/nginx/sites-enabled/default

cat <<EOF > /etc/nginx/sites-available/magento
  upstream fastcgi_backend {
    server  unix:/var/run/php/php7.2-fpm.sock;
  }


    server {
      location /health-check {
         access_log off;
         return 200;
         add_header Content-Type text/plain;
       }
    listen 80;
    server_name _;
    set \$MAGE_ROOT /var/www/html/magento2;
    include /var/www/html/magento2/nginx.conf.sample;
  }

EOF

ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled
export PATH=$PATH:/var/www/html/magento2/bin
cd /var/www/html/magento2/
bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2
systemctl restart nginx
