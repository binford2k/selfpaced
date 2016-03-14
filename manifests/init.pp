class selfpaced (
  $wetty_install_dir = '/root/wetty'
) {
  include nodejs
  include docker
  docker::image {'maci0/systemd':}
  docker::image { 'agent':
    docker_dir => '/tmp/agent',
    subscribe => File['/tmp/agent'],
    require => Docker::Image['maci0/systemd'],
  }
  file { '/tmp/agent':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/selfpaced/agent',
  }


  file {'/usr/local/bin/selfpaced':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/selfpaced.rb',
  }
  file {'/usr/local/share/words':
    ensure => directory
  }
  file {'/usr/local/share/words/places.txt':
    source => 'puppet:///modules/selfpaced/places.txt',
  }
  file {'/usr/local/bin/cleanup':
    mode => '0755',
    source => 'puppet:///modules/selfpaced/cleanup.rb',
  }

  include nginx
  nginx::resource::vhost { 'selfpaced.puppetlabs.com':
    proxy    => 'http://127.0.0.1:3000'
  }
  nginx::resource::vhost { 'localhost':
    ssl_port   => '3001',
    proxy    => 'http://127.0.0.1:3000',
    ssl      => true,
    ssl_cert => '/etc/puppetlabs/puppet/ssl/certs/master.puppetlabs.vm.pem',
    ssl_key  => '/etc/puppetlabs/puppet/ssl/private_keys/master.puppetlabs.vm.pem',
  }
  package { 'puppetclassify':
    ensure   => present,
    provider => 'gem',
  }

  vcsrepo { '/etc/puppetlabs/code/modules/course_selector':
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/puppetlabs/pltraining-course_selector'
  }

  include selfpaced::wetty
  include selfpaced::squid

  firewall { '000 reject outbound SSH, SMTP, and BTC traffic on docker0':
    iniface     => 'docker0',
    chain       => 'FORWARD',
    proto       => 'tcp',
    dport       => ['22','25','8333'],
    action      => 'reject',
  }

}
