require 'spec_helper'

describe 'lamp::vhost' do
  let(:facts) {
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :operatingsystemrelease => '16.04'
    }
  }

  context 'nginx' do
    let(:title) { 'nginx' }
    let(:params) {
      { :server => 'nginx', :path => '/var/www', :index => 'app.php', :engine => 'php' }
    }

    it { is_expected.to contain_lamp__vhost__nginx('nginx').with(
      'path'   => '/var/www',
      'engine' => 'php',
    ) }
  end

  context 'apache' do
    let(:title) { 'apache' }
    let(:params) {
      { :server => 'apache', :path => '/var/www', :index => 'index.php', :engine => 'php' }
    }

    it { is_expected.to contain_lamp__vhost__apache('apache').with(
      'path'   => '/var/www',
      'engine' => 'php',
    ) }
  end
end
