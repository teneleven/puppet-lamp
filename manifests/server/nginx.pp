class lamp::server::nginx (
  /* Default proxy headers for nginx */
  $proxy_headers = ['Host $host', 'X-Forwarded-For $remote_addr'],

  /* Default vhost options to pass to nginx vhost */
  $default_vhost_options = { use_default_location => false },
) inherits lamp::params {

  class { ::nginx::config:
    global_owner => $lamp::params::web_user,
    global_group => $lamp::params::web_group,
  }

  contain ::nginx

}
