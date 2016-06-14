# Class: puppet
#
# Install, configure different Puppet installation roles
# Can configure for nodes and servers.
#

class puppet (
  $role                   = 'client',
  # Puppet conf settings
  $conf_path              = '/etc/puppetlabs/puppet/puppet.conf',
  $conf_owner             = 'root',
  $conf_group             = 'root',
  $conf_mode              = '0644',
  $conf_main              = { },
  $conf_agent             = { },
  $conf_master            = { },
  $conf_user              = { },
  # Client Config
  $client_package_name    = 'puppet-agent',
  $client_package_ensure  = 'installed',
  $client_agent_service   = {
    'type'        => 'cron',
    'interval'    => 30,
    'cmd'         => undef,
    'puppet_bin'  => '/opt/puppetlabs/bin/puppet',
    'user'        => 'root',
    'ensure'      => 'present',
    'minute'      => undef,
    'hour'        => '*',
  },
) {

  validate_absolute_path($conf_path)
  validate_hash($conf_main)
  validate_hash($conf_agent)
  validate_hash($conf_master)
  validate_hash($conf_user)

  validate_re($role, '^(client)|(master)$', "The role can either be 'client' or 'master' not '${role}'")


  if $role == 'client' {
    include ::puppet::client
  }
  elsif $role == 'master' {
  }

}
