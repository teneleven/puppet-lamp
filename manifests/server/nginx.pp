class lamp::server::nginx inherits lamp::params {

  class { ::nginx::config:
    global_owner => $lamp::params::web_user,
    global_group => $lamp::params::web_group,
  }

  contain ::nginx

}
