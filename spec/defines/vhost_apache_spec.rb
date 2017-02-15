require 'spec_helper'

describe 'lamp::vhost::apache' do
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
        'servername'     => 'default',
        'serveraliases'  => ['default-alias', 'default-alias2'],
        'docroot'        => '/var/www',
        'directoryindex' => 'index.html, index.php',
        'docroot_owner'  => 'www-data',
        'docroot_group'  => 'www-data',
        'override'       => ['All'],
      } }
    }

    it { is_expected.to contain_class('lamp::server::apache') }
    it { is_expected.to contain_apache__vhost('defaultvhost') }

    # test for apache conf file contents
    it do
      is_expected.to contain_file('/var/www').with(
        'ensure' => 'directory',
        'owner'  => 'www-data',
        'group'  => 'www-data',
      )

      is_expected.to contain_concat__fragment('defaultvhost-apache-header')
        .with_content(/^\s*ServerName default$/)
      is_expected.to contain_concat__fragment('defaultvhost-serveralias')
        .with_content(/^\s*ServerAlias default-alias$/)
        .with_content(/^\s*ServerAlias default-alias2$/)

      is_expected.to contain_concat__fragment('defaultvhost-docroot')
        .with_content(/^\s*DocumentRoot "\/var\/www"$/)

      is_expected.to contain_concat__fragment('defaultvhost-directories')
        .with_content(/^\s*<Directory "\/var\/www">$/)
        .with_content(/^\s*DirectoryIndex index.html, index.php$/)
        .with_content(/^\s*AllowOverride All$/)
    end
  end

  # TODO implement & test reverse-proxying
end
