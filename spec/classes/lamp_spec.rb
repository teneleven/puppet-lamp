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

  context 'default-vhost' do
    let(:params) {
      {
        # defaults from params.pp:
        #
        # :default_vhost_server => 'apache',
        # :default_vhost_engine => 'php',

        :vhosts => {
          'test' => { 'path' => '/var/www/test' },
        },
      }
    }

    it { is_expected.to contain_class('lamp::server::apache') }
    it { is_expected.not_to contain_class('lamp::server::nginx') }

    it { is_expected.to contain_lamp__vhost('test').with(
      'engine' => 'php',
      'server' => 'apache',
      'path'   => '/var/www/test',
    ) }
  end

  context 'nginx-vhost' do
    let(:params) {
      {
        :vhosts => {
          'test' => { 'path' => '/var/www/test', 'server' => 'nginx' },
        },
      }
    }

    it { is_expected.to contain_class('lamp::server::nginx') }
    it { is_expected.not_to contain_class('lamp::server::apache') }

    it { is_expected.to contain_lamp__vhost('test').with(
      'engine' => 'php',
      'server' => 'nginx',
      'path'   => '/var/www/test',
    ) }
  end

  # tests default implementation of using multiple vhost servers
  # this should set the default proxy server to port 80, and reverse
  # proxy requests to the other server to port 81
  context 'multiple-vhost-servers' do
    let(:params) {
      {
        :vhosts => {
          'apache' => { 'hosts' => 'apache', 'path' => '/var/www/apache' },
          'nginx'  => { 'hosts' => 'proxy',  'path' => '/var/www/nginx', 'server' => 'nginx' }
        },
      }
    }

    it { is_expected.to contain_class('lamp::server::apache') }
    it { is_expected.to contain_class('lamp::server::nginx') }

    it { is_expected.to contain_lamp__vhost('apache').with(
      'engine' => 'php',
      'server' => 'apache',
      'path'   => '/var/www/apache',
      'port'   => 81,
      'hosts'  => ['apache']
    ) }

    it { is_expected.to contain_lamp__vhost('nginx').with(
      'engine' => 'php',
      'server' => 'nginx',
      'path'   => '/var/www/nginx',
      'port'   => 80,
      'hosts'  => ['proxy']
    ) }

    # reverse proxy back to apache host
    it { is_expected.to contain_lamp__vhost('nginx-proxy-apache').with(
      'server' => 'nginx',
      'port'   => 80,
      'proxy'  => 'http://127.0.0.1:81',
      'hosts'  => ['apache']
    ) }
  end

  # TODO db
end
