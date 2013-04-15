# == Class: xhprof
#
# This class installs the xhprof package along with the necessary configuration
# files and a virtual host for accessing the output.
#
# === Parameters
#
# [*version*]
#   The version of the package to install. Defaults to '0.9.2'.
#
# === Examples
#
#   class { 'xhprof': }
#
# === Requirements
#
# This class requires the apache class from PuppetLabs.
class xhprof {
    package { ['graphviz']:
        ensure => present,
        require => Class['phpsetup']
    }

    $username = 'salimane'
    $home_dir = "/home/${username}"

    exec {
        'clone_xhprof':
            cwd     =>"${home_dir}/htdocs",
            user    => $username,
            command => "git clone https://github.com/salimane/xhprof.git ${home_dir}/htdocs/xhprof && chmod -R 0777 /home/salimane/htdocs/xhprof",
            require => [Package['git'], File["${home_dir}/htdocs"]],
            creates => "${home_dir}/htdocs/xhprof";

        'install_xhprof':
            cwd     =>"${home_dir}/htdocs/xhprof/extension",
            command => "phpize && ./configure && make && make install && echo \"extension=xhprof.so\nxhprof.output_dir=/tmp/\" > /etc/php5/conf.d/xhprof.ini",
            require => Exec['install_xhprof'],
            creates => "/etc/php5/conf.d/xhprof.ini";
    }

    file_line {
        'php-ini-prepend':
            path   => '/etc/php5/conf.d/php.custom.ini',
            line   => 'auto_prepend_file = ${home_dir}/htdocs/xhprof/xhprof_html/header.php',
            require => [Exec['install_xhprof'], File['/etc/php5/conf.d/php.custom.ini']],
            notify => Class['php::fpm::service'];

        'php-ini-append':
            path   => '/etc/php5/conf.d/php.custom.ini',
            line   => 'auto_append_file = ${home_dir}/htdocs/xhprof/xhprof_html/footer.php',
            require => [Exec['install_xhprof'], File['/etc/php5/conf.d/php.custom.ini']],
            notify => Class['php::fpm::service'];
    }

    nginx::resource::upstream { 'php_backend':
       ensure  => present,
       members => [
         'unix:/tmp/php-fpm.sock',
       ],
    }

     nginx::resource::vhost { 'xhprof.local':
        ensure              => present,
        listen_port         => '80',
        www_root            => '${home_dir}/htdocs/xhprof/xhprof_html',
        index_files         => ['index.php'],
        server_name         => ['xhprof.local'],
        location_cfg_prepend =>{'if (!-e $request_filename) { rewrite ^(^\/*)/(.*)$ $1/index.php last; }' => ''},
        location_cfg_append =>{'access_log' => '/var/log/nginx/xhprof.access.log', 'error_log' => '/var/log/nginx/xhprof.error.log'},
        require             => Exec['install_xhprof'],
    }

    nginx::resource::location { 'xhprof.local-images':
        ensure              => present,
        location            => '~* ^.+\.(jpg|jpeg|gif|css|png|js|ico)$',
        www_root            => '${home_dir}/htdocs/xhprof/xhprof_html',
        vhost               => 'xhprof.local',
        location_cfg_append =>{'access_log' => 'off', 'expires' => '1m'}
    }

    nginx::resource::location { 'xhprof.local-php':
        ensure              => present,
        location            => '~ ^(.+\.php)(.*)$',
        www_root            => '${home_dir}/htdocs/xhprof/xhprof_html',
        vhost               => 'xhprof.local',
        index_files         => ['index.php'],
        location_cfg_append =>{'fastcgi_pass' => 'off', 'include' => 'fastcgi_params'}
    }
}
