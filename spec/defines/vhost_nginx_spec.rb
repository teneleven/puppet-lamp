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
        'server_name' => ['default'],
        'www_root'    => '/var/www',
        # TODO we should confirm this is being set from our vhost test
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
        .with_content(/^\s*root *\/var\/www;$/)
        .with_content(/^\s*index *index.php;$/)
        .with_content(/^\s*try_files \$uri \/index.php\$is_args\$args;$/)
    end
  end
end