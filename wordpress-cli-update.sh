#!/bin/csh
setenv WP_CLI_CACHE_DIR /tmp/home-nobody/.wp-cli/cache
install -d -o nobody -g nobody $WP_CLI_CACHE_DIR

/usr/local/bin/wp cli check-update --allow-root --patch --quiet
if ( $status == 1 )  then
    echo "New WP-CLI version available!"
   /usr/local/bin/wp cli update --allow-root --yes --nightly
else
    echo "WP-CLI is up to date."
endif
set sites = ( \
    "/usr/local/www/ostreff.info/" 
)
set wp_cli = "sudo -u nobody -g nobody -- /usr/local/bin/wp"
set wp_req = "--require=/usr/local/bin/force_wp_use_ipv4.php"

if ( ! -f /usr/local/bin/force_wp_use_ipv4.php ) then
    echo "WARNING: force_wp_use_ipv4.php not found, continuing without it"
    set wp_req = ""
endif

foreach site ($sites)
    if ( -d "$site" ) then
        set site_url = `$wp_cli option get home --path=$site $wp_req`
        if ( "$site_url" == "" ) then
            echo "ERROR: Cannot get site URL for $site"
            echo "SKIP: Directory $site not found"
            continue
        endif
        echo "--- Updating site: $site_url ---"

        set update_output = `$wp_cli core update --path="$site" $wp_req`
        echo "$update_output"

        echo "$update_output" | grep -q "is up to date"
        if ( $status == 0 ) then
            echo "Core is up to date."
        else
            echo "Core updated or error, running database update..."
            $wp_cli core update-db --path="$site" $wp_req
        endif

        $wp_cli plugin update --all --path="$site" $wp_req
        $wp_cli theme update --all --path="$site" $wp_req

        $wp_cli language core update --path="$site" $wp_req
        $wp_cli language plugin update --all --path="$site" $wp_req
        $wp_cli language theme update --all --path="$site" $wp_req

        echo "Done with $site_url"
        echo ""
    else
        echo "Directory $site not found. Skipping..."
    endif
end
