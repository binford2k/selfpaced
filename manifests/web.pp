class selfpaced::web (
  $docroot = $selfpaced::params::docroot
) inherits selfpaced::params {
  include nginx
  nginx::resource::vhost { 'try.puppet.com':
    ssl_port               => '443',
    ssl                    => true,
    ssl_cert               => '/etc/ssl/try.puppet.com.crt',
    ssl_key                => '/etc/ssl/try.puppet.com.key',
    use_default_location   => false,
    locations              => {
      '/sandbox/' => {
        proxy_read_timeout    => '1h',
        proxy_connect_timeout => '1h',
        proxy                 => 'http://127.0.0.1:3000',
        proxy_set_header      => [
          'Upgrade $http_upgrade',
          'Connection "Upgrade"',
        ],
        rewrite_rules         => [
          '/sandbox(.*) /$1  break'
        ]
      },
      '/' => {
        www_root => $docroot
      }
    }
  }

  file {$docroot:
    ensure => directory,
  }
  file {"${docroot}/index.html":
    ensure  => file,
    source  => 'puppet:///modules/selfpaced/index.html',
  }
  file {"${docroot}/js":
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/selfpaced/js',
  }

}
