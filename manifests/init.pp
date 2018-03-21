class selfpaced {
  File {
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  include selfpaced::web
  include selfpaced::docker
  include selfpaced::selinux

  package { [ 'git', 'rubygems', 'zlib-devel', 'ruby-devel', 'gcc', 'gcc-c++' ]:
    ensure => present,
  }

  package { 'puppet':
    ensure          => present,
    provider        => gem,
    require         => Package['rubygems'],
    install_options => { '--bindir' => '/tmp' },
  }

  package { [ 'puppetclassify', 'dockershell' ]:
    ensure   => present,
    provider => 'gem',
    require  => Package['rubygems'],
  }
  package { 'public_suffix':
    ensure   => '2.0.5',
    provider => gem,
    require  => Package['rubygems'],
  }

  vcsrepo { '/etc/puppetlabs/code/modules/course_selector':
    ensure   => latest,
    provider => 'git',
    source   => 'https://github.com/puppetlabs/pltraining-course_selector',
    force    => true,
  }

  file { '/etc/puppetlabs/puppet/autosign.conf':
    ensure => file,
    source => 'puppet:///modules/selfpaced/autosign.conf',
  }

  file { '/etc/puppetlabs/code/environments/production/hieradata/common.yaml':
    ensure => file,
    source => 'puppet:///modules/selfpaced/common.yaml',
  }

  file { '/etc/banner':
    ensure => file,
    source => 'puppet:///modules/selfpaced/banner',
  }

  file { '/etc/dockershell':
    ensure => directory,
  }

  file { '/etc/dockershell/config.yaml':
    ensure => file,
    source => 'puppet:///modules/selfpaced/dockershell/config.yaml',
  }

  class { 'abalone':
    autoconnect => false,
    bannerfile  => '/etc/banner',
    command     => '/usr/local/bin/dockershell',
    method      => 'command',
    params      => ['profile', 'option'],
    port        => '3000',
    timeout     => 900,
    ttl         => 900,
  }

}
