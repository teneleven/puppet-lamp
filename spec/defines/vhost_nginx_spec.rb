require 'spec_helper'

describe 'lamp::vhost::nginx' do
  let(:facts) {
    {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :operatingsystemrelease => '16.04'
    }
  }

  context 'default' do
    let(:title) { 'defaultvhost' }
    let(:params) {
      { :path => '/var/www', :engine => 'php', :options => {
        'ensure'      => 'present',
        'index_files' => ['index.php'],
        'server_name' => ['default', 'default-alias'],
        'www_root'    => '/var/www',
        'location_cfg_append' => {
          'try_files' => ['$uri /index.php$is_args$args']
        }
      } }
    }

    it { is_expected.to contain_class('lamp::server::nginx') }
    it { is_expected.to contain_nginx__resource__vhost('defaultvhost') }

    # test for nginx conf file contents
    it do
      # ensures site is available & enabled
      is_expected.to contain_concat('/etc/nginx/sites-available/defaultvhost.conf')
      is_expected.to contain_file('defaultvhost.conf symlink')

      # vhost header content
      is_expected.to contain_concat__fragment('defaultvhost-header')
        .with_content(/^\s*listen *\*:80;$/)
        .with_content(/^\s*index *index.php;$/)
        .with_content(/^\s*server_name *default default-alias;$/)

      # vhost location resource
      is_expected.to contain_nginx__resource__location('defaultvhost-default').with(
        'ensure'   => 'present',
        'vhost'    => 'defaultvhost',
        'location' => '/',
      )

      # vhost location content
      is_expected.to contain_concat__fragment('defaultvhost-500-6666cd76f96956469e7be39d750cc7d9')
        .with_content(/^\s*root *\/var\/www;$/)
        .with_content(/^\s*index *index.php;$/)
        .with_content(/^\s*try_files \$uri \/index.php\$is_args\$args;$/)
    end
  end

  # test nginx conf file for reverse-proxy
  context 'nginx-proxy' do
    let(:title) { 'defaultvhost' }
    let(:params) {
      { :proxy => 'http://127.0.0.1:81', :options => {
        'ensure'      => 'present',
        'index_files' => ['index.php'],
        'server_name' => ['default'],
        'location_cfg_append' => {
          'try_files' => ['$uri /index.php$is_args$args']
        }
      } }
    }

    it { is_expected.to contain_class('lamp::server::nginx') }
    it { is_expected.to contain_nginx__resource__vhost('defaultvhost') }

    # test for nginx conf file contents
    it do
      # ensures site is available & enabled
      is_expected.to contain_concat('/etc/nginx/sites-available/defaultvhost.conf')
      is_expected.to contain_file('defaultvhost.conf symlink')

      # vhost header content
      is_expected.to contain_concat__fragment('defaultvhost-header')
        .with_content(/^\s*listen *\*:80;$/)
        .with_content(/^\s*index *index.php;$/)

      # vhost location resource
      is_expected.to contain_nginx__resource__location('defaultvhost-default').with(
        'ensure'   => 'present',
        'vhost'    => 'defaultvhost',
        'location' => '/',
      )

      # vhost location content
      is_expected.to contain_concat__fragment('defaultvhost-500-6666cd76f96956469e7be39d750cc7d9')
        .with_content(/^\s*proxy_pass *http:\/\/127.0.0.1:81;$/)
        .with_content(/^\s*proxy_set_header *Host \$host;$/)
        .with_content(/^\s*proxy_set_header *X-Forwarded-For \$remote_addr;$/)
    end
  end

  # This tests configuring an nginx vhost with a path & a proxy. All requests
  # not matching "proxy_match" should be served from vhost, matching requests
  # should be served from proxy.
  context 'nginx-path-with-proxy' do
    let(:title) { 'defaultvhost' }
    let(:params) {
      { :path => '/var/www', :proxy => 'http://127.0.0.1:81', :proxy_match => '/blog', :options => {
        'ensure'      => 'present',
        'index_files' => ['index.php'],
        'server_name' => ['default'],
        'www_root'    => '/var/www',
        'location_cfg_append' => {
          'try_files' => ['$uri /index.php$is_args$args']
        }
      } }
    }

    it { is_expected.to contain_class('lamp::server::nginx') }
    it { is_expected.to contain_nginx__resource__vhost('defaultvhost') }

    # test for nginx conf file contents
    it do
      # vhost header content
      is_expected.to contain_concat__fragment('defaultvhost-header')
        .with_content(/^\s*listen *\*:80;$/)
        .with_content(/^\s*index *index.php;$/)

      # vhost location content
      is_expected.to contain_concat__fragment('defaultvhost-500-6666cd76f96956469e7be39d750cc7d9')
        .with_content(/^\s*root *\/var\/www;$/)
        .with_content(/^\s*index *index.php;$/)
        .with_content(/^\s*try_files \$uri \/index.php\$is_args\$args;$/)

      # vhost proxy location content
      is_expected.to contain_concat__fragment('defaultvhost-499-c061e150208a7ab43c1b0b723b79816b')
        .with_content(/^\s*location *\/blog {$/)
        .with_content(/^\s*proxy_pass *http:\/\/127.0.0.1:81;$/)
        .with_content(/^\s*proxy_set_header *Host \$host;$/)
        .with_content(/^\s*proxy_set_header *X-Forwarded-For \$remote_addr;$/)
    end
  end
end
