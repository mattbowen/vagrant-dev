# == Class: xhprof
#
# This class installs the xhprof package along with the necessary configuration
# files and a virtual host for accessing the output.
#
# === Parameters
#
#
# === Examples
#
#   class { 'xhprof': }
#
# === Requirements
#
class xhprof ($username = 'vagrant') {
    package { ['graphviz']:
        ensure  => latest,
        require => Class['php::fpm']
    }

    $home_dir = "/home/${username}"

    exec {
        'clone_xhprof':
            provider => shell,
            cwd     =>"${home_dir}/src",
            group   => $username,
            user    => $username,
            command => "mkdir -p ${home_dir}/src && git clone https://github.com/salimane/xhprof.git ${home_dir}/src/xhprof && chmod -R 0777 ${home_dir}/src/xhprof",
            require => [Package['git']],
            creates => "${home_dir}/src/xhprof";

        'install_xhprof':
            provider => shell,
            cwd     =>"${home_dir}/src/xhprof/extension",
            command => 'phpize; ./configure; make; make install && echo "extension=xhprof.so\nxhprof.output_dir=/tmp/" > /etc/php5/conf.d/xhprof.ini',
            require => [Exec['clone_xhprof'], Class['php::fpm']],
            unless => '[ -f /etc/php5/conf.d/xhprof.ini ] ',
            notify  => Class['php::fpm::service'];
    }

    file_line {
        'php-ini-prepend':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => "auto_prepend_file = ${home_dir}/src/xhprof/xhprof_html/header.php",
            require => [Exec['install_xhprof'], File['/etc/php5/conf.d/php.custom.ini']],
            notify  => Class['php::fpm::service'];

        'php-ini-append':
            path    => '/etc/php5/conf.d/php.custom.ini',
            line    => "auto_append_file = ${home_dir}/src/xhprof/xhprof_html/footer.php",
            require => [Exec['install_xhprof'], File['/etc/php5/conf.d/php.custom.ini']],
            notify  => Class['php::fpm::service'];
    }

    nginx::resource::location { 'xhprof.local-images':
        ensure              => present,
        location            => '~* ^.+\.(jpg|jpeg|gif|css|png|js|ico)$',
        www_root            => "${home_dir}/src/xhprof/xhprof_html",
        vhost               => 'xhprof.local',
        location_cfg_append =>{'access_log' => 'off', 'expires' => '1m'}
    }

    nginx::resource::location { 'xhprof.local-php':
        ensure              => present,
        location            => '~ ^(.+\.php)(.*)$',
        www_root            => "${home_dir}/src/xhprof/xhprof_html",
        vhost               => 'xhprof.local',
        index_files         => ['index.php'],
        location_cfg_append =>{'fastcgi_pass' => 'php_backend', 'fastcgi_index' => 'index.php', 'include' => 'fastcgi_params'}
    }

    nginx::resource::vhost { 'xhprof.local':
        ensure              => present,
        listen_port         => '80',
        www_root            => "${home_dir}/src/xhprof/xhprof_html",
        index_files         => ['index.php'],
        server_name         => ['xhprof.local'],
        location_cfg_prepend =>{'if (!-e $request_filename) { rewrite ^(^\/*)/(.*)$ $1/index.php last; }' => ' index index.php'},
        location_cfg_append =>{'access_log' => '/var/log/nginx/xhprof.access.log', 'error_log' => '/var/log/nginx/xhprof.error.log'},
        require             => Exec['install_xhprof'],
    }

    file {
        '/etc/hosts':
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0644';

       '/etc/php5/conf.d/xhprof.ini':
            content => "extension=xhprof.so
xhprof.output_dir=/tmp/",
            require             => Exec['install_xhprof'];
    }

    host { 'xhprof.local':
        ensure  => present,
        alias   => [ 'xhprof.local' ],
        ip      => '127.0.0.1',
        target  => '/etc/hosts',
        require => File['/etc/hosts'],
  }
}
