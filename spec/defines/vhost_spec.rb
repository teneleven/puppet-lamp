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
      { :server => 'nginx', :path => '/var/www', :index => 'app.php', :engine => 'php', :hosts => 'test-host' }
    }

    it do
      is_expected.to contain_lamp__vhost__nginx('nginx')
        .with(
          'path'   => '/var/www',
          'engine' => 'php',
        )
        .with_options(/"www_root"=>"\/var\/www"/)
        .with_options(/"try_files"=>"\$uri \/app.php\$is_args\$args"/)
        .with_options(/"server_name"=>\["test-host"\]/)
    end
  end

  context 'apache' do
    let(:title) { 'apache' }
    let(:params) {
      { :server => 'apache', :path => '/var/www', :index => 'app.php', :engine => 'php', :hosts => 'test-host' }
    }

    it do
      is_expected.to contain_lamp__vhost__apache('apache')
        .with(
          'path'   => '/var/www',
          'engine' => 'php',
        )
        .with_options(/"docroot"=>"\/var\/www"/)
        .with_options(/"directoryindex"=>"app\.php"/)
        .with_options(/"servername"=>"test-host"/)
    end
  end

  # TODO apache + nginx reverse-proxy
end
