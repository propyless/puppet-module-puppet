require 'spec_helper'

describe 'puppet' do
  let :facts do
    {
        :fqdn => 'my_hostname.tldr.domain.com',
    }
  end
  describe 'client' do
    default_params = {
        :'role' => 'client'
    }

    context 'with default configuration' do
      let :params do
        default_params
      end
      it { should compile.with_all_deps }

      it { should contain_class('puppet') }
      it { should contain_class('puppet::client') }
      it { should contain_class('puppet::config') }


    end # context 'with no configuration'

    context 'with custom configuration' do
      context '[main]' do
        let(:params) do
          default_params.merge(
              {
                  :'configuration' => {
                      'main' => {
                          'server' => 'puppet.tldr.domain.com',
                          'ca_server' => 'puppetca.tldr.domain.com'
                      }
                  }
              }
          )
        end
        it { should compile.with_all_deps }
        it { should contain_class('puppet') }
        it { should contain_class('puppet::client') }
        it { should contain_package('puppet_client').that_comes_before('Class[puppet::config]') }
        it { should contain_class('puppet::config').that_comes_before('Cron[puppet_cron_interval]') }
        it { should contain_cron('puppet_cron_interval').with(
            'ensure' => 'present',
            'user' => 'root',
            'command' => '/opt/puppetlabs/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
            'minute' => [3, 33],
            'hour' => '*'
        ) }
        it { should contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main server').with(
            'value' => 'puppet.tldr.domain.com'
        ) }
        it { should contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main ca_server').with(
            'value' => 'puppetca.tldr.domain.com'
        ) }

      end # context "[main]"
    end # context "with configuration"

  end # describe 'agent'
end # describe 'puppet-module-puppet'
