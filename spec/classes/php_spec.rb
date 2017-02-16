require 'spec_helper'

describe 'lamp::php' do
  let(:facts) {
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :operatingsystemrelease => '16.04'
    }
  }

  context 'php extensions' do
    let(:params) { { :extensions => ['curl', 'gd'] } }

    it { is_expected.to contain_class('php') }
    it { is_expected.to contain_php__extension('curl') }
    it { is_expected.to contain_php__extension('gd') }
    it { is_expected.not_to contain_php__extension('xdebug') }
  end

  context 'composer' do
    let(:params) { { :composer => true } }

    it { is_expected.to contain_class('php::composer') }
  end
end
