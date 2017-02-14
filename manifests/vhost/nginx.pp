define lamp::vhost::nginx (
  $site   = $title, /* used as nginx identifier */
  $path   = undef,
  $engine = undef,

  /* nginx options */
  $options = {},

  /* location options to be passed to lamp::vhost::location */
  $locations = {},

  /* proxy all requests to this url */
  $proxy       = undef,
  $proxy_match = undef,
) {

  contain lamp::server::nginx

  create_resources('::nginx::resource::vhost', { "${title}" => $options })

  if ($proxy) {
    ::nginx::resource::location { "${title}_proxy":
      location => $proxy_match ? {
        undef   => '/',
        default => $proxy_match,
      },
      proxy            => $proxy,
      proxy_set_header => ['Host $host', 'X-Forwarded-For $remote_addr'],
      vhost            => $site,
    }
  } else {
    $proxy_location = undef
  }

  if ($engine == 'php') {
    /* handle *.php files */
    lamp::vhost::location::nginx { "${title}_php":
      vhost  => $site,
      engine => 'php',
      path   => $path,
      match  => '[^/]\.php(/|$)',
      listen => $lamp::params::fcgi_listen,
      /* app_root => $path, */
    }
  } else {
    if (!$proxy) {
      /* block access to *.php files */
      lamp::vhost::location::nginx { "${title}_php":
        vhost    => $site,
        server   => 'nginx',
        path     => $path,
        priority => 600,
        match    => '[^/]\.php(/|$)',

        custom_cfg => {
          'deny' => 'all',
          'access_log' => 'off',
          'log_not_found' => 'off',
        }
      }
    }
  }

  $locations.each |$key, $location| {
    create_resources('lamp::vhost::location::nginx', { "${key}" => merge(
      { 'vhost' => $site, 'path' => $path },
      $location
    )})
  }

  /* $apps.each |$key, $app| { */
  /*   create_resources('lamp::server::nginx::app', { "${key}" => merge( */
  /*     { 'site' => $site }, */
  /*     $app */
  /*   )}) */
  /* } */

}
