class puppetclient::config (
    $server,
    $startmode,
    $cronminutes,
    $splay = undef,
    $data = {},
) {
  $default = {
    'main' => {
      'logdir' => '/var/log/puppet',
      'vardir' => '/var/lib/puppet',
      'ssldir' => '/var/lib/puppet/ssl',
      'rundir' => '/var/run/puppet',
      'factpath' => '$vardir/lib/facter',
      'templatedir' => '$confdir/templates',
      'usecacheonfailure' => 'false',
    },
    'agent' => {
      'pluginsync' => 'true',
      'report' => 'true',
      'server' => $server,
    },
    'master' => {
      'ssl_client_header' => 'SSL_CLIENT_S_DN',
      'ssl_client_verify_header' => 'SSL_CLIENT_VERIFY',
      'modulepath' => '$confdir/environments/$environment/modules',
      'manifest' => '$confdir/environments/$environment/manifests/site.pp',
      'certname' => $server,
      'reports' => 'tagmail,log,store',
    }
  }

  # Live would be so easy if there was a deep_merge function
  # $config = deep_merge($default, $data)
  # Instead we have to check each section for the right type and merge them seperately

  if ! has_key($data, 'main') {
    $data[main] = {}
  }

  if ! has_key($data, 'master') {
    $data[master] = {}
  }

  if ! has_key($data, 'agent') {
    $data[agent] = {}
  }

  $config = {
    'main' => merge($default[main], $data[main]),
    'master' => merge($default[master], $data[master]),
    'agent' => merge($default[agent], $data[agent]),
  }

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

