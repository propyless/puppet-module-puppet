require 'spec_helper'

describe 'puppet' do
  let :facts do
    {
        :fqdn => 'my_hostname.tldr.domain.com',
    }
  end
  describe 'using role' do
    describe 'client' do
      default_params = {
          :'role' => 'client'
      }

      context 'with default configuration' do
        let :params do
          default_params
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('puppet') }
        it { is_expected.to contain_class('puppet::client') }
        it { is_expected.to contain_package('puppet_client').that_comes_before('Class[puppet::config]') }
        it { is_expected.to contain_class('puppet::config').that_comes_before('Cron[puppet_cron_interval]') }
        it { is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with(
            'owner' => 'root',
            'group' => 'root',
            'mode' => '0644'
        ) }
        it { is_expected.to contain_cron('puppet_cron_interval').with(
            'ensure' => 'present',
            'user' => 'root',
            'command' => '/opt/puppetlabs/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
            'minute' => [3, 33],
            'hour' => '*'
        ) }
        it { is_expected.not_to contain_ini_setting }


      end # context 'with no configuration'

      context 'with custom configuration' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('puppet') }
        it { is_expected.to contain_class('puppet::client') }
        it { is_expected.to contain_package('puppet_client').that_comes_before('Class[puppet::config]') }
        it { is_expected.to contain_class('puppet::config').that_comes_before('Cron[puppet_cron_interval]') }
        it { is_expected.to contain_file('/etc/puppetlabs/puppet/puppet.conf').with(
            'owner' => 'root',
            'group' => 'root',
            'mode' => '0644'
        ) }
        it { is_expected.to contain_cron('puppet_cron_interval').with(
            'ensure' => 'present',
            'user' => 'root',
            'command' => '/opt/puppetlabs/bin/puppet agent --onetime --ignorecache --no-daemonize --no-usecacheonfailure --detailed-exitcodes --no-splay',
            'minute' => [3, 33],
            'hour' => '*'
        ) }
        context '[main]' do
          let(:params) do
            default_params.merge(
                {
                    :'conf_main' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    }
                })
          end
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main certname').with(
              'section' => 'main',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main server').with(
              'section' => 'main',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main ca_server').with(
              'section' => 'main',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
        end # context "[main]"

        context '[agent]' do
          let(:params) do
            default_params.merge(
                {
                    :'conf_agent' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    }
                })
          end

          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent certname').with(
              'section' => 'agent',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent server').with(
              'section' => 'agent',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent ca_server').with(
              'section' => 'agent',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
        end # context "[agent]"

        context '[master]' do
          let(:params) do
            default_params.merge(
                {
                    :'conf_master' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    }
                })
          end

          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf master certname').with(
              'section' => 'master',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf master server').with(
              'section' => 'master',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf master ca_server').with(
              'section' => 'master',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
        end # context "[master]"

        context '[user]' do
          let(:params) do
            default_params.merge(
                {
                    :'conf_agent' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    }
                })
          end

          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent certname').with(
              'section' => 'agent',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent server').with(
              'section' => 'agent',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent ca_server').with(
              'section' => 'agent',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
        end # context "[agent]"

        context '[main] & [agent] & [master] & [user]' do
          let(:params) do
            default_params.merge(
                {
                    :'conf_main' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    },
                    :'conf_agent' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    },
                    :'conf_master' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    },
                    :'conf_user' => {
                        'server' => 'puppet.tldr.domain.com',
                        'ca_server' => 'puppetca.tldr.domain.com',
                        'certname' => facts[:fqdn]
                    }
                })
          end
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main certname').with(
              'section' => 'main',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main server').with(
              'section' => 'main',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf main ca_server').with(
              'section' => 'main',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent certname').with(
              'section' => 'agent',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent server').with(
              'section' => 'agent',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent ca_server').with(
              'section' => 'agent',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf master certname').with(
              'section' => 'master',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf master server').with(
              'section' => 'master',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf master ca_server').with(
              'section' => 'master',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent certname').with(
              'section' => 'agent',
              'setting' => 'certname',
              'value' => facts[:fqdn],
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent server').with(
              'section' => 'agent',
              'setting' => 'server',
              'value' => 'puppet.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
          it { is_expected.to contain_ini_setting('/etc/puppetlabs/puppet/puppet.conf agent ca_server').with(
              'section' => 'agent',
              'setting' => 'ca_server',
              'value' => 'puppetca.tldr.domain.com',
              'path' => '/etc/puppetlabs/puppet/puppet.conf'
          ) }
        end # context "[agent]"

      end # context "with configuration"

      context 'variable type and content validations' do
        validations = {
            'must be hash' => {
                :name => %w(conf_main conf_master conf_agent conf_user),
                :valid => [
                    {
                        'setting1' => 'the',
                        'setting2' => 'game'
                    }

                ],
                :invalid => ['string', %w(array), 3, 2.42, true, false, nil],
                :message => 'is not a Hash',
            },
        }
        validations.sort.each do |type, var|
          var[:name].each do |var_name|
            var[:params] = {} if var[:params].nil?
            var[:valid].each do |valid|
              context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
                let(:params) { [default_params, var[:params], {:"#{var_name}" => valid, }].reduce(:merge) }
                it { is_expected.to compile }
                it { is_expected.to contain_ini_setting(
                                        '/etc/puppetlabs/puppet/puppet.conf ' + var_name.sub(/conf_/, '') + ' setting1'
                                    ).with(
                    'setting' => 'setting1',
                    'value'   => 'the'
                ) }
                it { is_expected.to contain_ini_setting(
                                        '/etc/puppetlabs/puppet/puppet.conf ' + var_name.sub(/conf_/, '') + ' setting2'
                                    ).with(
                    'setting' => 'setting2',
                    'value'   => 'game'
                ) }
              end
            end

            var[:invalid].each do |invalid|
              context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
                let(:params) { [default_params, var[:params], {:"#{var_name}" => invalid, }].reduce(:merge) }
                it 'should fail' do
                  expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
                end
              end
            end
          end # var[:name].each
        end # validations.sort.each

      end # context "with invalid configuration"
    end # describe 'client'
  end # describe 'using role'

  describe 'using nonexistent roles' do
    let :params do
      {
          :'role' => 'you just lost it'
      }
    end
    it do
      expect { should contain_class(subject) }.to raise_error(Puppet::Error, /The role can either be 'client' or 'master' not 'you just lost it'/)
    end
  end # describe "nonexistent roles"
end # describe 'puppet'
