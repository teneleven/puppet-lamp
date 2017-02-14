require 'spec_helper'

describe 'lamp' do
  context 'php' do
    let(:params) {
      {
        :vhosts => {},
        :php    => {},
        :db     => {},
      }
    }

    let(:facts) {
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '16.04'
      }
    }

    # it { is_expected.to contain_class('lamp::php') }

    it { is_expected.to contain_user('www-data') }
    it { is_expected.to contain_group('www-data') }
  end

#   context 'apache' do
#     let(:title) { 'apache' }
#     let(:params) {
#       { :server => 'apache', :path => '/var/www', :index => 'index.php', :engine => 'php' }
#     }

#     it { is_expected.to contain_lamp__vhost__apache('apache').with(
#       'path'   => '/var/www',
#       'engine' => 'php',
#     ) }
#   end
end
