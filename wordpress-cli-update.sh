#!/bin/csh
/usr/local/bin/wp cli check-update --allow-root --patch --quiet
# bash version bellow:
#if [ $? -eq 1 ]; then
#    echo "Има налична нова версия на WP-CLI!"
#   /usr/local/bin/wp cli update --allow-root --yes --nightly
#else
#    echo "WP-CLI е актуален."
#fi

# csh version bellow
if ( $status == 1 )  then
    echo "Има налична нова версия на WP-CLI!"
   /usr/local/bin/wp cli update --allow-root --yes --nightly
else
    echo "WP-CLI е актуален."
endif

sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ core update
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ plugin update --all
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ theme update --all
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ language core update
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ language plugin update --all
sudo -u nobody -g nobody -- /usr/local/bin/wp --path=/usr/local/www/ostreff.info/ language theme update --all
