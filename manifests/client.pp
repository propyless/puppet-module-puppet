class puppet::client (
  $package_name    = 'puppet-agent',
  $package_ensure  = 'installed',
  $agent_service   = {
    'type'        => 'cron',
    'interval'    => '30',
    'cmd'         => undef,
    'puppet_bin'  => '/opt/puppetlabs/bin/puppet',
    'user'        => 'root',
    'ensure'      => 'present',
    'minute'      => undef,
    'hour'        => '*',
  },
) {
  # Make sure that this class can only be called by this module.
  assert_private('puppet::client is a private class and can not be called directly')

  validate_hash($agent_service)

  package { 'puppet_client':
    name   => $package_name,
    ensure => $package_ensure,
  }

  include ::puppet::config

  if has_key($agent_service, 'type') {
    validate_re($agent_service['type'], ['^cron$'])
    case $agent_service['type'] {
      'cron': {

        # Assert the order in which stuff should execute
        Package['puppet_client'] -> Class['::puppet::config'] -> Class['cron']

        $cron_cmd    = pick(
          $agent_service['cmd'],
          'agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay'
        )
        $puppet_bin  = pick($agent_service['puppet_bin'], '/opt/puppetlabs/bin/puppet')
        $cron_user   = pick($agent_service['user'], 'root')
        $cron_ensure = pick($agent_service['ensure'], 'present')
        $cron_hour   = pick($agent_service['hour'], 'present')

        # Calculate the $cron_minute
        $_run_interval = pick($agent_service['interval'], 30)
        # Validate the run_interval value to make sure its a numeric.
        validate_integer(
          $_run_interval,
          'puppet::client::service[\'interval\'] must contain a valid numerical value'
        )
        $_cron_minute = [pick($agent_service['minute'], fqdn_rand($_run_interval))]

        if $_run_interval <= 30 {
          $cron_minute = concat($_cron_minute, $_cron_minute + 30)
        }

        cron { 'puppet_cron_interval':
          ensure  => $cron_ensure,
          user    => $cron_user,
          command => "${puppet_bin} ${$cron_cmd}",
          minute  => $cron_minute,
          hour    => $cron_hour
        }
      }
    }
  }
  else {
    fail('$puppet::client::agent_version must include a type.')
  }


}