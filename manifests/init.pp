# Class: puppet
#
# Install, configure different Puppet installation roles
# Can configure for nodes and servers.
#

class puppet (
  $role                   = 'client',
  # Puppet conf settings
  $conf_path                = '/etc/puppetlabs/puppet/puppet.conf',
  $conf_owner               = 'root',
  $conf_group               = 'root',
  $conf_mode                = '0644',
  $conf_main                = { },
  $conf_main_hiera_merge    = false,
  $conf_agent               = { },
  $conf_agent_hiera_merge   = false,
  $conf_master              = { },
  $conf_master_hiera_merge  = false,
  $conf_user                = { },
  $conf_user_hiera_merge    = false,
  # Client Config
  $client_package_name    = 'puppet-agent',
  $client_package_ensure  = 'installed',
  $client_agent_service   = {
    'ensure'          => 'present',
    'type'            => 'cron',
    'interval'        => 30,
    'cron_structure'  => '%{puppet_bin} %{puppet_args}',
    'puppet_args'     => 'agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
    'puppet_bin'      => '/opt/puppetlabs/bin/puppet',
    'user'            => 'root',
    'minute'          => undef,
    'hour'            => '*',
  },
) {

  # Parameter validation
  validate_hash(
    $conf_main,
    $conf_agent,
    $conf_master,
    $conf_user
  )
  validate_bool(
    $conf_main_hiera_merge,
    $conf_agent_hiera_merge,
    $conf_master_hiera_merge,
    $conf_user_hiera_merge
  )

  validate_absolute_path($conf_path)

  validate_re(
    $role,
    '^(client)|(master)$',
    "The role can either be 'client' or 'master' not '${role}'"
  )

  if empty($conf_main) == false and $conf_main_hiera_merge{
    $conf_main_real = hiera_hash(puppet::conf_main)
  }
  else {
    $conf_main_real = $conf_main
  }

  if empty($conf_agent) == false and $conf_agent_hiera_merge {
    $conf_agent_real = hiera_hash(puppet::conf_agent)
  }
  else {
    $conf_agent_real = $conf_agent
  }

  if empty($conf_master) == false and $conf_master_hiera_merge {
    $conf_master_real = hiera_hash(puppet::conf_master)
  }
  else {
    $conf_master_real = $conf_master
  }

  if empty($conf_user) == false and $conf_user_hiera_merge {
    $conf_user_real = hiera_hash(puppet::conf_user)
  }
  else {
    $conf_user_real = $conf_user
  }

  if $role == 'client' {
    include ::puppet::client
  }
  elsif $role == 'master' {
  }

}
