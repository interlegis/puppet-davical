#init.pp

class davical (	$dbserver,
		$dbport,
		$dbname,
		$dbuser,
		$dbpass,
		$admin_email,
		$system_name,
		$ldapserver,
		$ldapport,
		$ldapbinddn,
		$ldapbindpw,
		$ldapbasedn,
		$home_cal_name,	
	) {
	$prereqs = [
		"apache2",
		"libapache2-mod-php5",
		"php5",
		"php5-pgsql",
		"php5-curl",
		"php5-ldap",
                "davical",
        ]

        apt::hold { 'libawl-php':
  		version => '0.53-1',
	}

        # install Prereqs
        package { $prereqs:
                ensure => latest,
		require => File["/etc/apt/sources.list.d/davical.list"],
        }
	package { "postgresql-common":
                ensure => absent,
        }

        apt::source { 'davical':
  		location   => 'http://debian.mcmillan.net.nz/debian',
  		release    => 'precise',
                repos      => 'awm', 
                key        => '8FEB8EBF',
                key_server => 'pgp.net.nz',
        }

	file {'/etc/apache2/sites-available/default':
                content => template('davical/default.apache2.erb'),
                require => [ Package[$prereqs],
			     Exec["enable rewrite module"],	
			],
                notify => Service["apache2"],
        }

	exec { "enable rewrite module":
                command => "a2enmod rewrite",
                logoutput => true,
                timeout => 10,
		creates => "/etc/apache2/mods-enabled/rewrite.load",
		notify => Service["apache2"],
        }

	file {'/etc/davical/config.php':
                content => template('davical/config.php.erb'),
                require => Package[$prereqs],
                notify => Service["apache2"],
        }
	service { "apache2":
                ensure => running,
                enable => true,
                hasstatus => true,
                require => [
                        Package[$prereqs],
                        File["/etc/apache2/sites-available/default"],
                ],
        }



}
