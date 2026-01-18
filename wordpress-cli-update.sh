#!/bin/csh
/usr/local/bin/wp cli check-update --allow-root --patch --quiet
# csh version bellow
if ( $status == 1 )  then
    echo "Има налична нова версия на WP-CLI!"
   /usr/local/bin/wp cli update --allow-root --yes --nightly
else
    echo "WP-CLI е актуален."
endif

set sites = ( \
    "/usr/local/www/ostreff.info/" \
)
set wp_cli = "sudo -u nobody -g nobody -- /usr/local/bin/wp"

foreach site ($sites)
    if ( -d "$site" ) then
        set site_url = `$wp_cli option get home --path=$site`
        echo "--- Updating site: $site_url ---"

        set update_output = `$wp_cli core update --path="$site"`
        echo "$update_output"
        echo "$update_output" | grep -q "is up to date"
        if ( $status != 0 ) then
            echo "Core updated, running database update..."
            $wp_cli core update-db --path="$site"
        endif

        $wp_cli plugin update --all --path="$site"
        $wp_cli theme update --all --path="$site"

        $wp_cli language core update --path="$site"
        $wp_cli language plugin update --all --path="$site"
        $wp_cli language theme update --all --path="$site"

        echo "Done with $site_url"
        echo ""
    else
        echo "Directory $site not found. Skipping..."
    endif
end
