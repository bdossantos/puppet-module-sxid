# == Class : sxid
#
# Full description of class integrit here.
#
# === Parameters
#
# $search         Root search path
#
# $exclude        Following directories would be exclude from searching
#
# $email          Address where to send reports to
#
# $always_notify  Always send reports even if nothing changed
#
# $log_file       Log path
#
# $keep_log       Number of log archive to keep
#
# $always_rotate  Rotate the logs even when there are no changes
#
# $forbidden      Directories where +s is forbidden
#
# $enforce        Remove (-s) files found in forbidden directories
#
# $listall        This implies ALWAYS_NOTIFY. It will send a full list of
#                 entries along with the changes
#
# $ignore_dirs    Ignore entries for directories in these paths
#
# $extra_list     File that contains a list of other files that sxid should
#                 monitor
#
# $mail           Mail programm path
#
# $nice           Niceness which affects process scheduling of check
#
# === Examples
#
# class { 'sxid':
#   email         => 'admin@domain.tld',
#   always_notify => 'yes',
#   keep_logs     => 10,
#   exclude       => ['/proc', '/mnt', '/cdrom', '/floppy'],
#   ignore_dirs   => ['/home', '/root'],
#   forbidden     => ['/home', '/tmp'],
# }
#
# === Authors
#
# Benjamin Dos Santos <benjamin.dossantos@gmail.com>
#
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
  $mail = '/usr/bin/mail',
  $nice = 19
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
    command => "/usr/bin/nice -n ${sxid::nice} /usr/bin/ionice -c 3 /usr/bin/sxid &> /dev/null",
    user    => 'root',
    hour    => fqdn_rand(6),
    minute  => fqdn_rand(59),
    require => Package['sxid'],
  }

  exec { 'sxid':
    command     => "nohup nice -n ${sxid::nice} \
                    ionice -c 3 \
                    sxid &> /dev/null &",
    path        => '/usr/bin/:/bin/',
    cwd         => '/tmp',
    subscribe   => File['/etc/sxid.conf'],
    refreshonly => true,
  }
}