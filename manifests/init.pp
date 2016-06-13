# Class: puppet
#
# Install, configure different Puppet installation roles
# Can configure for nodes and servers.
#

class puppet (
  $role                   = 'node',
  $configuration          = { },
) {

  validate_hash($configuration)
  validate_re($role, '/client|master/', 'The role can either be "client" or "master"')


  if $role == 'client' {
    include ::puppet::client
  }
  elsif $role == 'master' {
  }

}
