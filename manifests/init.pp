class sxid(
  $search = '/',
  $exclude = ['/proc', '/mnt', '/cdrom', '/floppy'],
  $email = 'root',
  $always_notify = 'no',
  $log_file = '/var/log/sxid.log',
  $keep_logs = 5,
  $always_rotate = 'no',
  $forbidden = ['/home', '/tmp'],
  $enforce = 'no',
  $listall = 'no',
  $ignore_dirs = ['/home'],
  $extra_list = [],
  $mail = '/usr/bin/mail'
){

  package { 'sxid':
    ensure => 'installed',
  }

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['sxid'],
  }

  file { '/etc/sxid.conf':
    ensure  => file,
    content => template('sxid/sxid.conf.erb'),
  }

  file { '/etc/sxid.list':
    ensure  => file,
    content => template('sxid/sxid.list.erb'),
  }

  file { '/etc/cron.daily/sxid':
    ensure  => absent,
  }

  cron { 'sxid':
    command => '/usr/bin/sxid &> /dev/null',
    user    => 'root',
    hour    => fqdn_rand(6),
    minute  => fqdn_rand(59),
    require => Package['sxid'],
  }

  exec { 'sxid':
    command     => 'nohup nice -n 19 sxid &',
    path        => '/usr/bin/:/bin/',
    cwd         => '/tmp',
    subscribe   => File['/etc/sxid.conf'],
    refreshonly => true,
  }
}