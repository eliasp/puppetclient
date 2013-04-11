# Puppet client management module for Puppet

This module helps installing and configuring a Puppet client. It offers
the following features so far:

* configure a specific Puppet server
* Puppet can be configured to run as daemon, manually or from a cronjob
* The cronjob defaults to being run every 30 minutes at a time derived from the client FQDN. Setting splay to spread the load is supported for cron mode
* can configure the Puppetlabs upstream repository

The module is a bit Debian-specific at the moment, patches for other distributions are welcome.

## Installation

The modules can be installed via puppet module tool (require [version 2.7.14+](http://docs.puppetlabs.com/puppet/2.7/reference/modules_installing.html)):

    puppet module install bschmidt/puppetclient

## Usage

The following class parameters are supported and can either be set from the manifest or from Hiera.

* **server**: Hostname of the Puppet server, sets server in the [agent] section if defined
* **startmode**: Sets the startmode of the Puppet client. Can be one of
    * **undef** (not set): distribution defaults are used
    * **'daemon'**: /etc/default/puppet/START is set to yes using Augeas, service is enabled and started
    * **'cron'**: /etc/default/puppet/START is set to no, a cronjob is installed at '/etc/cron.d/puppetclient' to run Puppet at specified minutes on the clock. See $cronminutes
    * **'manual'**: /etc/default/puppet/START is set to no, no cronjob is installed. Puppet has to be run manually or from another Supervisor
* **cronminutes**: An array of minutes on the clock where the Puppet client will be run. Only used when startmode == cron. Defaults to a random 30 minute interval based on the client FQDN
* **splay**: if defined and $startmode == 'cron', wait a random interval of up to $splay seconds for each run. Used to spread the load. It installs a bashscript in /usr/local/bin/waitrandom to do this.
* **upstreamrepository**: If set to **'true'**, configure APT to use the Puppetlabs APT Repository. Only supported on Debian so far.

Example:

    class {'puppetclient':
        $server      => 'puppet.domain.com',
        $startmode   => 'cron',
        $cronminutes => [ '5','25','45' ],
        $splay       => '300'
    }

This sets the server to 'puppet.domain.com' and configures Puppet to be run from cron every 20 minutes. To ease the load on the server each individual run will be delayed up to 300 seconds (five minutes).

The same can be archieved by setting the following variables in Hiera:

     puppetclient::server :      'puppet.domain.com'
     puppetclient::startmode :   'cron'
     puppetclient::cronminutes : [ '5','25','45' ]
     puppetclient::splay :       300

If you want to set $upstreamrepository, you currently need to use **'true'** (the string), not **true** (Boolean value)


## Author

Bernhard Schmidt <berni@birkenwald.de>

## Licence

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

## Support

Please log tickets and issues at the [project homepage](https://github.com/bernhardschmidt/puppetclient)

