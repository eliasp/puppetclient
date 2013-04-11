class puppetclient::config (
    $server,
    $startmode,
    $cronminutes,
    $splay = undef,
) {
  file { '/etc/puppet/puppet.conf':
    content => template('puppetclient/puppet.conf.erb')
  }

  file { '/usr/bin/waitrandom':
    source => 'puppet:///modules/puppetclient/waitrandom',
    mode   => '0755',
  }

  if $startmode {
    if $startmode == 'daemon' {
      augeas { 'puppetclient::enable_puppet':
        changes => [
          'set /files/etc/default/puppet/START yes'
        ],
      }

      file { '/etc/cron.d/puppetclient':
        ensure => absent,
      }

      service { 'puppet':
        ensure => running,
      }
    }

    if $startmode == 'cron' or $startmode == 'manual' {
      augeas { 'puppetclient::enable_puppet':
        changes => [
          'set /files/etc/default/puppet/START no'
        ],
      }

      file { '/etc/cron.d/puppetclient':
        ensure  => $startmode ? {
          /cron/  => present,
          default => absent,
        },
        content => template('puppetclient/puppetclient.cron.erb')
      }

      service { 'puppet':
        ensure => stopped,
      }
    }
  }
}

