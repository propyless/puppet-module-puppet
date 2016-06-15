class puppet::client (
  $package_name    = $::puppet::client_package_name,
  $package_ensure  = $::puppet::client_package_ensure,
  $agent_service   = $::puppet::client_agent_service,
) inherits ::puppet {
  # Make sure that this class can only be called by this module.
  assert_private('puppet::client is a private class and can not be called directly')

  validate_hash($agent_service)

  package { 'puppet_client':
    ensure => $package_ensure,
    name   => $package_name,
  }

  include ::puppet::config

  if has_key($agent_service, 'type') {
    validate_re($agent_service['type'], ['^cron$'])

    case $agent_service['type'] {
      'cron': {

        # Assert the order in which stuff should execute
        Package['puppet_client'] -> Class['::puppet::config'] -> Cron['puppet_cron_interval']

        $cron_cmd = pick(
          $agent_service['cmd'],
          'agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay'
        )
        $puppet_bin  = pick($agent_service['puppet_bin'], '/opt/puppetlabs/bin/puppet')
        $cron_user   = pick($agent_service['user'], 'root')
        $cron_ensure = pick($agent_service['ensure'], 'present')
        $cron_hour   = pick($agent_service['hour'], '*')

        # Calculate the $cron_minute
        $_run_interval = pick($agent_service['interval'], 30)
        # Validate the run_interval value to make sure its a numeric and not above 60 (1 hour)
        validate_integer($_run_interval, 60)
        $_cron_minute_1 = pick($agent_service['minute'], fqdn_rand($_run_interval))

        if $_run_interval <= 30 {
          $_cron_minute_2 = $_cron_minute_1 + 30
          $cron_minute = [$_cron_minute_1, $_cron_minute_2]
        }

        cron { 'puppet_cron_interval':
          ensure  => $cron_ensure,
          user    => $cron_user,
          command => "${puppet_bin} ${$cron_cmd}",
          minute  => $cron_minute,
          hour    => $cron_hour,
        }
      }
      default: {
      # satisfy puppet-lint
      }
    }
  }
  else {
    fail('$puppet::client::agent_version must include a type.')
  }


}