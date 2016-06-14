# == Class: puppet::config
#
# Manage the Puppet config

class puppet::config (
  $config_path  = $::puppet::conf_path,
  $config_owner = $::puppet::conf_owner,
  $config_group = $::puppet::conf_group,
  $config_mode  = $::puppet::conf_mode,
  $conf_main    = $::puppet::conf_main,
  $conf_agent   = $::puppet::conf_agent,
  $conf_master  = $::puppet::conf_master,
  $conf_user    = $::puppet::conf_user,
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

  create_ini_settings({ 'main'    => $conf_main }, $_defaults_puppet_conf)
  create_ini_settings({ 'agent'   => $conf_agent }, $_defaults_puppet_conf)
  create_ini_settings({ 'master'  => $conf_master }, $_defaults_puppet_conf)
  create_ini_settings({ 'user'    => $conf_user }, $_defaults_puppet_conf)
}