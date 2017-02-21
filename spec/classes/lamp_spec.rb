require 'spec_helper'

describe 'lamp' do
  let(:facts) {
    {
      :osfamily                  => 'Debian',
      :operatingsystem           => 'Ubuntu',
      :operatingsystemrelease    => '16.04',
      :operatingsystemmajrelease => '16.04',
      :puppetversion             => '4.0',
    }
  }

  context 'basic' do
    let(:params) {
      {
        :vhosts => {},
        :php    => {},
        :dbs    => {},
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
          'apache'  => { 'hosts' => 'apache', 'path' => '/var/www/apache' },
          'apache2' => { 'hosts' => 'apache2', 'path' => '/var/www/apache2' },
          'nginx'   => { 'hosts' => 'proxy',  'path' => '/var/www/nginx', 'server' => 'nginx' }
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

    it { is_expected.to contain_lamp__vhost('apache2').with(
      'engine' => 'php',
      'server' => 'apache',
      'path'   => '/var/www/apache2',
      'port'   => 81,
      'hosts'  => ['apache2']
    ) }

    it { is_expected.to contain_lamp__vhost('nginx').with(
      'engine' => 'php',
      'server' => 'nginx',
      'path'   => '/var/www/nginx',
      'port'   => 80,
      'hosts'  => ['proxy']
    ) }

    # reverse proxy back to apache host
    it { is_expected.to contain_lamp__vhost('reverse-proxy-apache').with(
      'server' => 'nginx',
      'port'   => 80,
      'proxy'  => 'http://127.0.0.1:81',
      'hosts'  => ['apache']
    ) }

    it { is_expected.to contain_lamp__vhost('reverse-proxy-apache2').with(
      'server' => 'nginx',
      'port'   => 80,
      'proxy'  => 'http://127.0.0.1:81',
      'hosts'  => ['apache2']
    ) }
  end

  # This tests configuring an nginx vhost with a path & a proxy.
  context 'nginx-path-with-proxy' do
    let(:params) {
      {
        :vhosts => {
          'nginx' => { 'hosts' => 'proxy', 'path' => '/var/www', 'server' => 'nginx', 'proxy' => 'http://some-external-website.com', 'proxy_match' => '/external' }
        },
      }
    }

    it { is_expected.to contain_class('lamp::server::nginx') }

    it { is_expected.to contain_lamp__vhost('nginx').with(
      'engine'      => 'php',
      'server'      => 'nginx',
      'path'        => '/var/www',
      'hosts'       => ['proxy'],
      'proxy'       => 'http://some-external-website.com',
      'proxy_match' => '/external',
    ) }
  end

  context 'simple mysql db' do
    let(:params) {
      {
        :dbs => { 'test' => '123' }
      }
    }

    it { is_expected.to contain_lamp__db('test').with(
      'users' => { 'test' => { 'password' => '123' } }
    ) }

    it { is_expected.to contain_mysql__db('test_test').with(
      'dbname'   => 'test',
      'user'     => 'test',
      'host'     => 'localhost',
      'grant'    => ['ALL'],
      'password' => '123',
    ) }
  end

  context 'mysql db' do
    let(:params) {
      {
        :dbs => {
          'test' => {
            'server' => 'mysql',
            'users' => {
              'test_user'  => '123',
              'test_user2' => { 'password' => '234', 'host' => '127.0.0.1' }
            }
          }
        }
      }
    }

    it { is_expected.to contain_lamp__db('test').with(
      'users' => { 'test_user' => '123', 'test_user2' => { 'password' => '234', 'host' => '127.0.0.1' } }
    ) }

    it { is_expected.to contain_mysql__db('test_test_user').with(
      'dbname'   => 'test',
      'user'     => 'test_user',
      'host'     => 'localhost',
      'grant'    => ['ALL'],
      'password' => '123',
    ) }
    it { is_expected.to contain_mysql__db('test_test_user2').with(
      'dbname'   => 'test',
      'user'     => 'test_user2',
      'host'     => '127.0.0.1',
      'grant'    => ['ALL'],
      'password' => '234',
    ) }
  end

end
