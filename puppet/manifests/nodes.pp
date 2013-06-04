
node vagrant-dev {

    import 'nodedefault.pp'
    include nodedefault

    $username = 'vagrant'

    # add user vagrant
    adduser { $username:
        shell      => '/bin/zsh',
        groups     => ['sudo'],
        sshkeytype => 'ssh-rsa',
        sshkey     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDT2yEfwTAsvOqWCzCas/JmIjuVvMtVN+1g/ZRpdxNvyTep9kYLodcKOMg77RpiqDGdhJVH3XpXbfWE8zGihc1CN1KymhO5L3WhlaAsViDYqirrMPtlOwO897sCmF8TfL7aPWGU4RBQKUv9DfdBzHUaDBOufZZS6bgtMCzqoiWM5n0kjOpZ9imX+53kZJ288wGrF/GahFe17y+q5n0D8If6kZ2mMUjBVW6oCYlLWE0HEZaZt+1R4no1P3keiZ2hn9DIhKytJivrI9aQdAymzpAtRiykzErTGhO6ZK0n9ukXMb9sqWL+4pbCvERs6BRetmVvIb6zT4mpy0xhjhpy8uzH'
    }

    class { 'dotfiles':
        username => $username
    }

    class { 'phpsetup':
        username => $username
    }

    class { 'railssetup':
        username => $username
    }

    class { 'weighttp':
        username => $username
    }

    class { 'pythonsetup':
        username => $username
    }

}

node salimane-zenbook {

    import 'nodedefault.pp'
    include nodedefault

    $username = 'salimane'

    # add user salimane
    adduser { $username:
        shell      => '/bin/zsh',
        groups     => ['sudo'],
    }

    class { 'dotfiles':
        username => $username
    }

    class { 'phpsetup':
        username => $username
    }

    class { 'railssetup':
        username => $username
    }

    class { 'weighttp':
        username => $username
    }

    class { 'pythonsetup':
        username => $username
    }

}

