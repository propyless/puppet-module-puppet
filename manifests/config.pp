# == Class: puppet::config
#
# Manage the Puppet config

class puppet::config (
  $certname = $::fqdn,
  $config_path = '/etc/puppetlabs/puppet/puppet.conf',
  $config_owner = 'root',
  $config_group = 'root',
  $config_mode = '0644',
  $configuration = $::puppet::configuration,
) inherits ::puppet {

  # Make sure that this class can only be called by this module.
  assert_private('puppet::config is a private class.')

  file { $config_path:
    owner  => $config_owner,
    group  => $config_group,
    mode   => $config_mode
  }
  $_defaults_puppet_conf = {
    'ensure'  => 'present',
    'path'    => $config_path,
  }

  if has_key($configuration, 'main') {
    validate_hash($configuration['main'])
    create_ini_settings({ 'main' => $configuration['main'] }, $_defaults_puppet_conf)
  }

  if has_key($configuration, 'agent') {
    validate_hash($configuration['agent'])
    create_ini_settings({ 'agent' => $configuration['agent'] }, $_defaults_puppet_conf)
  }
}