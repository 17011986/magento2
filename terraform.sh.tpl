#!/bin/bash
echo "${key_ssh_dev}" > /home/ubuntu/.ssh/authorized_keys
echo "${key_ssh_user}" >> /home/ubuntu/.ssh/authorized_keys
chown ubuntu: /home/ubuntu/.ssh/authorized_keys
chmod 0600 /home/ubuntu/.ssh/authorized_keys
apt install software-properties-common
add-apt-repository ppa:ondrej/php -y
apt-get update && sudo apt-get -y upgrade && sudo apt-get autoremove -y
apt install nginx-full -y python-certbot-nginx -y
apt install wget curl zip unzip -y
apt install mysql-server -y
apt install hhvm -y
apt install -y php-psr-container

sudo apt install php7.4-fpm \
php7.4-common \
php7.4-mysql \
php7.4-xml \
php7.4-xmlrpc \
php7.4-curl \
php7.4-gd \
php7.4-imagick \
php7.4-cli \
php7.4-dev \
php7.4-imap \
php7.4-mbstring \
php7.4-opcache \
php7.4-soap \
php7.4-zip \
php7.4-intl \
php7.4-bcmath \
php7.4-json \
php-token-stream -y -y


curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt update -y
apt install elasticsearch -y
systemctl start elasticsearch
systemctl enable elasticsearch

sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.4/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/fpm/php.ini
sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php/7.4/fpm/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 2G/g' /etc/php/7.4/cli/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/7.4/cli/php.ini
sed -i 's/zlib.output_compression = Off/zlib.output_compression = On/g' /etc/php/7.4/cli/php.ini
systemctl restart php7.4-fpm
mysql -u root -pmagento -e "create database magento; GRANT ALL PRIVILEGES ON magento.* TO magento@localhost IDENTIFIED BY 'magento'"

cd /var/www/html
export COMPOSER_HOME="$HOME/.config/composer"
chmod 777 /usr/local/bin/

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer composer --version=1.10.17
chmod 755 /usr/local/bin/

composer config -g http-basic.repo.magento.com ${users_mag} ${pass_mag}
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition  $PATH_TO_MAGENTO_ROOT
mv project-community-edition/ magento2/
cd /var/www/html/magento2/

find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R :www-data .
chmod u+x bin/magento

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

cd /var/www/html/magento2
cat <<EOF > /var/www/html/magento2/auth.json
  {
    "http-basic": {
        "repo.magento.com": {
            "username": "${users_mag}",
            "password": "${pass_mag}"

    }
}
}
EOF
cd /var/www/html/magento2
php bin/magento sampledata:deploy
php bin/magento setup:upgrade
bin/magento module:disable Magento_TwoFactorAuth
bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2


sed -i '/types_hash_max_size 2048;/ a\
        server_names_hash_bucket_size 1024;' /etc/nginx/nginx.conf

rm -rf /etc/nginx/sites-available/default
rm -rf /etc/nginx/sites-enabled/default
cat <<EOF > /etc/nginx/sites-available/magento
upstream fastcgi_backend {
  server  unix:/var/run/php/php7.4-fpm.sock;
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
wait=6
systemctl restart nginx
