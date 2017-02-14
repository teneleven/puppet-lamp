require 'spec_helper'

describe 'lamp' do
  let(:facts) {
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :operatingsystemrelease => '16.04'
    }
  }

  context 'basic' do
    let(:params) {
      {
        :vhosts => {},
        :php    => {},
        :db     => {},
      }
    }

    it { is_expected.to contain_user('www-data') }
    it { is_expected.to contain_group('www-data') }
  end

  context 'php' do
    let(:params) {
      {
        :php    => { 'extensions' => ['curl', 'gd', 'mysql', 'zip'] },
      }
    }

    it { is_expected.to contain_class('lamp::php').with(
      'extensions' => ['curl', 'gd', 'mysql', 'zip']
    ) }
  end

  context 'vhosts' do
    let(:params) {
      {
        # defaults from params.pp:
        #
        # :default_vhost_server => 'apache',
        # :default_vhost_engine => 'php',

        :vhosts => {
          'apache' => { 'path' => '/var/www/apache' },
          'nginx'  => { 'path' => '/var/www/nginx', 'server' => 'nginx' }
        },
      }
    }

    it { is_expected.to contain_class('lamp::server::apache') }
    it { is_expected.to contain_class('lamp::server::nginx') }

    it { is_expected.to contain_lamp__vhost('apache').with(
      'engine' => 'php',
      'server' => 'apache',
      'path'   => '/var/www/apache',
    ) }

    it { is_expected.to contain_lamp__vhost('nginx').with(
      'engine' => 'php',
      'server' => 'nginx',
      'path'   => '/var/www/nginx',
    ) }
  end
end
