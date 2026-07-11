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
    "/usr/local/www/ostreff.info/" \
    "/home/realesr/" \
    "/home/classic-bg.net/new-site/" \
    "/home/classic-bg.net/tmp-site/" \
    "/usr/local/www/wordpress/" \
    "/usr/local/www/albena-bg.be/" \
)
set wp_cli = "sudo -u nobody -g nobody WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR -- /usr/local/bin/wp"
set wp_req_file = "/tmp/home-nobody/force_wp_use_ipv4.php"

if ( ! -f "$wp_req_file" ) then
    echo "Generating force_wp_use_ipv4.php in temporary directory..."
    echo '<?php' > "$wp_req_file"
    echo '// force_wp_use_ipv4.php - Forces IPv4 for all HTTP requests in WP-CLI' >> "$wp_req_file"
    echo '// Usage: wp --require=/usr/local/bin/force_wp_use_ipv4.php <command>' >> "$wp_req_file"
    echo '' >> "$wp_req_file"
    echo 'if (defined("WP_CLI") && WP_CLI) {' >> "$wp_req_file"
    echo '    // Hook AFTER WordPress is loaded, so add_action/add_filter exist' >> "$wp_req_file"
    echo '    WP_CLI::add_hook("after_wp_load", function() {' >> "$wp_req_file"
    echo '        // Force IPv4 for WordPress HTTP API' >> "$wp_req_file"
    echo '        add_action("http_api_curl", function($handle) {' >> "$wp_req_file"
    echo '            curl_setopt($handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);' >> "$wp_req_file"
    echo '        }, PHP_INT_MIN, 1);' >> "$wp_req_file"
    echo '' >> "$wp_req_file"
    echo '        // Disable SSL verification (for testing)' >> "$wp_req_file"
    echo '        // add_filter("https_ssl_verify", "__return_false");' >> "$wp_req_file"
    echo '        // add_filter("https_local_ssl_verify", "__return_false");' >> "$wp_req_file"
    echo '    });' >> "$wp_req_file"
    echo '}' >> "$wp_req_file"
    chown nobody:nobody "$wp_req_file"
    chmod 644 "$wp_req_file"
endif
set wp_req = "--require=$wp_req_file"

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
