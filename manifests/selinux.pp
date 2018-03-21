class selfpaced::selinux {

  # Source code in nginx_proxy.te
  file { '/usr/share/selinux/targeted/nginx_proxy.pp':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/selfpaced/selinux/nginx_proxy.pp',
  }

  selmodule { 'nginx_proxy':
    ensure => present,
  }

}
