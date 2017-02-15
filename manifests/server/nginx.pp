class lamp::server::nginx (
  /* Default proxy headers for nginx */
  $proxy_headers = ['Host $host', 'X-Forwarded-For $remote_addr'],
) inherits lamp::params {

  class { ::nginx::config:
    global_owner => $lamp::params::web_user,
    global_group => $lamp::params::web_group,
  }

  contain ::nginx

}
