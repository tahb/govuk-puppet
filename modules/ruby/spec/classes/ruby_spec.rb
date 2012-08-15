require_relative '../../../../spec_helper'

describe 'ruby', :type => :class do
  let(:params) { {'version' => '1.2.3.4.5.6'} }
  it { should contain_package('ruby1.9.1').with({
      'ensure'  => '1.2.3.4.5.6'
  })}
  it { should contain_package('ruby1.9.1-dev').with({
      'ensure'  => '1.2.3.4.5.6'
  })}

  it { should contain_apt__repository('brightbox-ruby-ng') }
end
