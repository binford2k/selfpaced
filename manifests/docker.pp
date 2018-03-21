class selfpaced::docker {

  class { 'docker':
    extra_parameters => '--default-ulimit nofile=1000000:1000000',
  }

  docker::image {'centos:7':}
  docker::image { 'agent':
    docker_dir => '/tmp/agent',
    subscribe => File['/tmp/agent'],
    require => Docker::Image['centos:7'],
  }

  file { '/tmp/agent':
    ensure => directory,
    recurse => true,
    source => 'puppet:///modules/selfpaced/agent',
  }

  firewall { '000 accept outbound 80, 443, and 8140 traffic on docker0':
    iniface     => 'docker0',
    chain       => 'FORWARD',
    proto       => 'tcp',
    dport       => ['! 80','! 443','! 8140'],
    action      => 'reject',
  }

}
