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
      { :server => 'nginx', :path => '/var/www', :index => ['app.php', 'index.php'], :engine => 'php', :hosts => 'test-host' }
    }

    it do
      is_expected.to contain_lamp__vhost__nginx('nginx')
        .with(
          'path'   => '/var/www',
          'engine' => 'php',
        )
        .with_options(/"www_root"=>"\/var\/www"/)
        .with_options(/"try_files"=>"\$uri \/app.php\$is_args\$args \/index.php\$is_args\$args"/)
        .with_options(/"server_name"=>\["test-host"\]/)
    end
  end

  context 'apache' do
    let(:title) { 'apache' }
    let(:params) {
      { :server => 'apache', :path => '/var/www', :index => ['app.php', 'index.php'], :engine => 'php', :hosts => 'test-host' }
    }

    it do
      is_expected.to contain_lamp__vhost__apache('apache')
        .with(
          'path'   => '/var/www',
          'engine' => 'php',
        )
        .with_options(/"docroot"=>"\/var\/www"/)
        .with_options(/"directoryindex"=>"app\.php index\.php"/)
        .with_options(/"servername"=>"test-host"/)
    end
  end

  context 'nginx-proxy' do
    let(:title) { 'nginx' }
    let(:params) {
      { :server => 'nginx', :proxy => 'http://127.0.0.1:81', :index => 'app.php', :hosts => 'test-host' }
    }

    it do
      is_expected.to contain_lamp__vhost__nginx('nginx')
        .with(
          'proxy' => 'http://127.0.0.1:81',
        )
    end
  end

  context 'apache-proxy' do
    let(:title) { 'apache' }
    let(:params) {
      { :server => 'apache', :proxy => 'http://127.0.0.1:81', :index => 'app.php', :hosts => 'test-host' }
    }

    it do
      is_expected.to contain_lamp__vhost__apache('apache')
        .with(
          'proxy' => 'http://127.0.0.1:81',
        )
    end
  end
end
