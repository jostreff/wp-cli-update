#!/bin/csh
#/usr/local/bin/wp cli update --allow-root --yes
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ core update
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ plugin update --all
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ theme update --all
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ language core update
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ language plugin update --all
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ language plugin theme --all
