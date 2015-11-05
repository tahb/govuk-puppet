require 'spec_helper'

describe 'hubot' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "hubot class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('hubot::params') }
          it { is_expected.to contain_class('hubot::install').that_comes_before('hubot::config') }
          it { is_expected.to contain_class('hubot::config') }
          it { is_expected.to contain_class('hubot::service').that_subscribes_to('hubot::config') }

          it { is_expected.to contain_service('hubot') }
          it { is_expected.to contain_package('hubot').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'hubot class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('hubot') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
