#!/bin/bash

# Variables
APPENV=local
DBHOST=localhost
DBNAME=master
DBUSER=root
DBPASSWD=root

echo -e "\n--- Installing now... ---\n"

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

echo -e "\n--- Install base packages: vim, git, etc. ---\n"
apt-get -y install vim build-essential python-software-properties git > /dev/null 2>&1

echo -e "\n--- Installing nginx ---\n";
apt-get install nginx -y > /dev/null 2>&1
sed -i -e 's/\/usr\/share\/nginx\/html/\/var\/www/' /etc/nginx/sites-enabled/default

echo -e "\n--- Installing PHP ---\n"
add-apt-repository ppa:ondrej/php5 #> /dev/null 2>&1
apt-get -qq update # > /dev/null 2>&1
apt-get install php5-common php5-dev php5-cli php5-fpm -y # > /dev/null 2>&1
apt-get install curl php5-curl php5-gd php5-mcrypt php5-mysql -y # > /dev/null 2>&1

echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
apt-get -y install mysql-server-5.5 phpmyadmin > /dev/null 2>&1

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

echo -e "\n--- Installing NodeJS ---\n"
add-apt-repository ppa:chris-lea/node.js > /dev/null 2>&1
apt-get -qq update

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
mv composer.phar /usr/local/bin/composer

echo -e "\n--- Installing NodeJS and NPM ---\n"
apt-get -y install nodejs > /dev/null 2>&1
curl --silent https://npmjs.org/install.sh | sh > /dev/null 2>&1

echo -e "\n--- Installing MongoDB ---\n"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
apt-get install -y mongodb-org
service mongod status

echo -e "\n--- Installing javascript components ---\n"
npm install -g gulp bower > /dev/null 2>&1

echo -e "\n--- Updating project components and pulling latest versions ---\n"
cd /vagrant
sudo -u vagrant -H sh -c "composer install" > /dev/null 2>&1
cd /vagrant/client
sudo -u vagrant -H sh -c "npm install" > /dev/null 2>&1
sudo -u vagrant -H sh -c "bower install -s" > /dev/null 2>&1
sudo -u vagrant -H sh -c "gulp" > /dev/null 2>&1

echo -e "\n--- Creating a symlink for future phpunit use ---\n"
ln -fs /vagrant/vendor/bin/phpunit /usr/local/bin/phpunit

echo -e "\n--- Add environment variables locally for artisan ---\n"
cat >> /home/vagrant/.bashrc <<EOF

# Set envvars
export APP_ENV=$APPENV
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD
EOF
