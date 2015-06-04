require_relative '../../../../spec_helper'

describe 'govuk_unattended_reboot', :type => :class do
  let(:facts) {{
    :fqdn             => 'foo.example.com',
    :govuk_node_class => 'chocolate_factory',
  }}
  let(:check_scripts_directory) { '/etc/unattended-reboot/check' }

  describe "enabled" do
    let(:params) {{
      :enabled => true,
    }}

    it { should contain_class('unattended_reboot').with_enabled('true').with_check_scripts_directory(check_scripts_directory) }

    it { should contain_file('/usr/local/bin/check_icinga').with_ensure('present') }
    it { should contain_file("#{check_scripts_directory}").with_ensure('directory') }
    it { should contain_file("#{check_scripts_directory}/00_safety").with_ensure('present') }
    it { should contain_file("#{check_scripts_directory}/01_alerts").with_ensure('present') }

    it "correctly formats the node class when querying Icinga" do
      should contain_file('/etc/unattended-reboot/check/01_alerts').with_content(/status.cgi\?search_string=%5Echocolate-factory-\[0-9\]&/)
    end
  end

  describe "disabled" do
    let(:params) {{
      :enabled => false,
    }}

    it { should contain_class('unattended_reboot').with_enabled('false') }

    it { should contain_file('/usr/local/bin/check_icinga').with_ensure('absent') }
    it { should contain_file("#{check_scripts_directory}").with_ensure('absent') }
    it { should contain_file("#{check_scripts_directory}/00_safety").with_ensure('absent') }
    it { should contain_file("#{check_scripts_directory}/01_alerts").with_ensure('absent') }
  end
end
