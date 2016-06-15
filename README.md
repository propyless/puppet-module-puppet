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


## API reference notes
### init.pp
#### `::puppet::role`
Assign which role the module should apply to the node.
Right now the only working role is `client`. Later on
this module will support the `master` role as well.
The master role will allow the configuration of the
auth and fileserver configuration files.

*The default is `client`*

#### `::puppet::conf_path`
The fully qualified path to puppet.conf.

*The default is `/etc/puppetlabs/puppet/puppet.conf`*

#### `::puppet::conf_owner`
The user which should be the owner of puppet.conf located at `::puppet::conf_path`

*The default is `root`*

#### `::puppet::conf_owner`
The user which should be owner of puppet.conf located at `::puppet::conf_path`

*The default is `root`*

#### `::puppet::conf_group`
The group which should be owner of puppet.conf located at `::puppet::conf_path`

*The default is `root`*

#### `::puppet::conf_mode`
The file mode which should be used for puppet.conf located at `::puppet::conf_path`

*The default is `0644`*

#### `::puppet::conf_*`
The configuration that should be used in `::puppet::conf_path` for the [main/agent/master/user] section.
Take a look in the examples section to understand how to configure puppet.conf [main/agent/master/user].

#### `::puppet::conf_*_hiera_merge` `[{main,agent,master,user}]`
Enable or disable for hash merging (hiera_hash) functionality in hiera so that `puppet::conf_*` specified at various levels in hiera are merged together as one.

*The default is `false`*

#### `::puppet::client_package_name`
The puppet agent package that should be installed.

*The default is `puppet-agent`*

#### `::puppet::client_package_ensure`
The state that should be realized for the package specified at `::puppet::client_package_name`. Specify if the package should be a specific version, installed, or use the latest version at all times.

*The default is `installed`*

#### `::puppet::client_agent_server`
Configure the puppet agent to run at a specific interval or according to a schedule.
The only scheduler configurable with this module today is `cron`.

##### Interval or minute
You can either specify a explicit minute value for cron like `*/5` (run puppet at 5 minute intervals.)
or use the interval to specify how often puppet should run that way.
Interval will also use fqdn_rand to randomize the interval so that it "load-balances" runs across different minutes.
So an interval of 30 for node "test.domain.com" could end up with it running at `20,50` while another node "best.domain.com" could end up running at `21,51`

##### How cron_structure is used
By default.. the cron_structure is `'%{puppet_bin} %{puppet_args}'`
```puppet
{
  'type'        => 'cron',
  'puppet_bin'  => '/opt/puppetlabs/bin/puppet',
  'puppet_args' => 'agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
}
```
Using the above as an example it would result in the following:

`/opt/puppetlabs/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay`

If we change the `cron_structure` key to for example:

`'echo "Running puppet"; %{puppet_bin} %{puppet_args}'`

We would get the result:

`echo "Running puppet"; /opt/puppetlabs/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay`

The advantages of this is more flexibility to the cron job command.

*The default is:*
```puppet
{
    'ensure'          => 'present',
    'type'            => 'cron',
    'interval'        => 30,
    'cron_structure'  => '%{puppet_bin} %{puppet_args}',
    'puppet_args'     => 'agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
    'puppet_bin'      => '/opt/puppetlabs/bin/puppet',
    'user'            => 'root',
    'minute'          => undef,
    'hour'            => '*',
  }
```
