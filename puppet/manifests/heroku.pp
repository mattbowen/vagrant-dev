# == Class: heroku
#
class heroku {

    apt::source { 'heroku':
        location    => 'http://toolbelt.heroku.com/ubuntu',
        release     => ' ./',
        repos       => '',
        key         => '0F1B0520',
        key_source  => 'https://toolbelt.heroku.com/apt/release.key',
        include_src => false
    }

    package {
        'heroku-toolbelt':
            ensure  => installed,
            require => Apt::Source['heroku'];
    }
}
