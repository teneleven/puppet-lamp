class lamp::server::apache inherits lamp::params {

  class { ::apache:
    manage_user   => false,
    manage_group  => false,
    default_vhost => false
  }

}
