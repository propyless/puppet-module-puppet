# puppet-module-puppet
----------------------

## Overview

This module installs and manages the puppet configuration file.


## Examples

### Default Configuration
With the default configuration settings this module will do the following:

#### Manifest
```puppet
include puppet
```
#### Hiera
```yaml
classes:
  - puppet
```

#### Effect
* Install *puppet-agent* (Puppet 4.x aio client package)
* Set root:root with mode 0644 to puppet.conf
  * **Important note: It will not change the configuration so it will use whatever the package provided or existed prior to installation.**
* Add cron job to run puppet agent every 30 minutes

### Changing it up a bit

#### Manifest
```puppet
class { 'puppet':
  role      => 'client',
  client_package_name => 'puppet-aio',
  conf_main => {
    'server' => 'puppet.tldr.domain.com',
    'ca_server' => 'puppetca.tldr.domain.com',
  },
  conf_agent => {
    'ssldir'    => '/opt/other_ssl_dir/',
    'server'    => 'puppet.domain.com',
    'ca_server' => 'puppet.domain.com',
  },
  client_agent_service => {
    'type'        => 'cron',
    'puppet_bin'  => '/opt/puppetlabs/bin/puppet_wrapper',
    'minute'      => '*/20',
  }
}
```
#### Hiera
```yaml
classes:
  - puppet

puppet::role: 'client'
puppet::client_package_name: 'puppet-aio'

puppet::conf_main:
  server: 'puppet.tldr.domain.com'
  ca_server: 'puppetca.tldr.domain.com'

puppet::conf_agent:
  ssldir: '/opt/other_ssl_dir/'
  server: 'puppet.domain.com'
  ca_server: 'puppet.domain.com'
puppet::client_agent_service:
  type: 'cron'
  puppet_bin: '/opt/puppetlabs/bin/puppet_wrapper'
  minute: '*/20'

```

#### Effect
* Install package called *puppet-aio*
* Set root:root with mode 0644 to puppet.conf
* Add configuration to following sections in puppet.conf
  * [main]
    * server = puppet.tldr.domain.com
    * ca_server = puppetca.tldr.domain.com
  * [agent]
    *   ssldir = /opt/other_ssl_dir/
    *   server = puppet.domain.com
    *   ca_server = puppet.domain.com
* Add cron job with a different puppet_bin path and run every 20 minutes **(does not use fqdn_rand function if manually specified like this)**