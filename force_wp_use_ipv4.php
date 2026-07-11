<?php
// force_wp_use_ipv4.php - Forces IPv4 for all HTTP requests in WP-CLI
// Usage: wp --require=/usr/local/bin/force_wp_use_ipv4.php <command>

if (defined('WP_CLI') && WP_CLI) {
    // Hook AFTER WordPress is loaded, so add_action/add_filter exist
    WP_CLI::add_hook('after_wp_load', function() {
        // Force IPv4 for WordPress HTTP API
        add_action('http_api_curl', function($handle) {
            curl_setopt($handle, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        }, PHP_INT_MIN, 1);

        // Disable SSL verification (for testing)
        // add_filter('https_ssl_verify', '__return_false');
        // add_filter('https_local_ssl_verify', '__return_false');
    });
}
