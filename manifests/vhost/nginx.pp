define lamp::vhost::nginx (
  $site   = $title, /* used as nginx identifier */
  $path   = undef,
  $engine = undef,

  /* nginx options */
  $options = {},

  /* location options to be passed to lamp::vhost::location */
  $locations = {},

  /* proxy all requests to this url */
  $proxy         = undef,
  $proxy_match   = undef,
) {

  contain lamp::server::nginx

  if ($proxy and $path == undef) {
    # if we only set $proxy and not $path, we need to pass the $proxy to our
    # nginx vhost below (otherwise it errors since it needs at least $path *or*
    # $proxy set)
    $proxy_options = { 'proxy' => $proxy, 'proxy_set_header' => $lamp::server::nginx::proxy_headers }
  } else {
    $proxy_options = {}
  }

  if ($proxy and empty($proxy_options)) {
    # create a proxy location under this vhost
    ::nginx::resource::location { "${title}_proxy":
      priority => 499, # needs higher priority or our other locations will match first
      location => $proxy_match ? {
        undef   => '/',
        default => $proxy_match,
      },
      proxy            => $proxy,
      proxy_set_header => $lamp::server::nginx::proxy_headers,
      vhost            => $site,
    }
  }

  create_resources('::nginx::resource::vhost', { "${title}" =>
    merge($options, $proxy_options)
  })

  if ($path) {
    if ($engine == 'php') {
      notice("creating php engine for ${title}")

      /* handle *.php files */
      lamp::vhost::location::nginx { "${title}_php":
        vhost  => $site,
        engine => 'php',
        path   => $path,
        match  => '[^/]\.php(/|$)',
        listen => $lamp::params::fcgi_listen,
        /* app_root => $path, */
      }
    } elsif (!$proxy) {
      notice("blocking php engine for ${title}")

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
