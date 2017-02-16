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

    it do
      is_expected.to contain_exec('npm_install_/var/www')
        .with(
          'command' => '/usr/bin/npm install',
          'cwd'     => '/var/www',
          'timeout' => 0,
        )
        .with_require(/Package\[npm\]/)
    end
  end
end
