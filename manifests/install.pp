class puppetclient::install ($upstreamrepository = 'false') {
  if $upstreamrepository == 'true' {
    if $operatingsystem == 'Debian' {
      apt::source { "puppet":
        location   => 'http://apt.puppetlabs.com/',
        release    => $lsbdistcodename,
        repos      => 'main',
        key        => '4BD6EC30',
        key_server => 'hkp://p80.pool.sks-keyservers.net:80'
      }

      # Install libaugeas-ruby which usually depends on the Ruby 1.9 version
      # used by the upstream puppet
      package {'libaugeas-ruby': }
    } else {
      warn ("puppet::upstreamrepository is not implemented for $operatingsystem")
    }
  }

  package { 'puppet': }
}

