require 'spec_helper'

describe 'lamp::nodejs' do
  let(:facts) {
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :operatingsystemrelease => '16.04'
    }
  }

  context 'npm modules' do
    let(:params) {
      {
        :npm_modules         => ['bower'],
        :manage_package_repo => false, # this needs to be set or we get some error from Apt
      }
    }

    it { is_expected.to contain_package('bower') }
  end

  context 'npm install' do
    let(:params) {
      {
        :install             => ['/var/www'],
        :manage_package_repo => false, # this needs to be set or we get some error from Apt
      }
    }

    it { is_expected.to contain_nodejs__npm('/var/www').with(
      'ensure'  => 'present',
      'target'  => '/var/www',
      'package' => '/var/www',
    ) }

    it { is_expected.to contain_exec('npm_install_/var/www').with(
      'command' => '/usr/bin/npm install /var/www ',
      'cwd'     => '/var/www',
    ) }
  end
end
