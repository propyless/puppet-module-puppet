require 'spec_helper'

describe 'puppet' do
  let :facts do
    {
      :fqdn => 'my_hostname.tldr.domain.com',
    }
  end
  describe 'client' do
    default_params = {
      :"role" => 'client'
    }

    context "with default configuration" do
      let :params do
        default_params
      end
      it { should compile.with_all_deps }

      it { should contain_class('puppet')}
      it { should contain_class('puppet::client')}
      it { should contain_class('puppet::config')}


    end # context 'with no configuration'

    context "with custom configuration" do
      context "[main]" do
        let(:params) do
          default_params.merge(
            {}
          )
        end
      it { should compile.with_all_deps }

      it { should contain_class('puppet')}
      it { should contain_class('puppet::client')}
      it { should contain_class('puppet::config')}

      end # context "[main]"

    end # context "with configuration"

  end # describe 'agent'
end # describe 'puppet'
