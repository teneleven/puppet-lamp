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
    $proxy_options = { 'proxy' => $proxy, 'proxy_set_header' => $lamp::server::nginx::proxy_headers }

    /* # TODO figure out proxy_location */
    /* proxy    => $proxy_location, */
    /* proxy_set_header => $proxy_location ? { */
    /*   undef   => undef, */
    /*   default => $proxy_headers, */
    /* }, */
  } else {
    $proxy_options = {}
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
      { 'vhost' => $site, 'path' => $path, 'proxy' => $proxy, 'proxy_match' => $proxy_match },
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
