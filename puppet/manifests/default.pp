
class { 'apt':
  always_apt_update    => true,
  disable_keys         => undef,
  proxy_host           => false,
  proxy_port           => '8080',
  purge_sources_list   => false,
  purge_sources_list_d => false,
  purge_preferences_d  => false
}

apt::source { 'puppetlabs':
  location   => 'http://apt.puppetlabs.com',
  repos      => 'main',
  key        => '4BD6EC30',
  key_server => 'pgp.mit.edu',
}

Package { ensure => "installed" }

package { "puppet":
	ensure => latest
}

$postinstallpkgs = ["build-essential", "zlib1g-dev", "libssl-dev", "libreadline-gplv2-dev", "ssh", "aptitude"]
$enhancers = [ "screen", "strace", "sudo" ]

package { $enhancers: }
package { $postinstallpkgs: }



