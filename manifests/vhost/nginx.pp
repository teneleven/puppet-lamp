define lamp::vhost::nginx (
  $site   = $title, /* used as nginx identifier */
  $path   = undef,
  $engine = undef,
  $index  = undef,

  /* nginx options */
  $options = {},

  /* location options to be passed to lamp::vhost::location */
  $locations = {},

  /* proxy all requests to this url */
  $proxy         = undef,
  $proxy_match   = undef,
) {

  contain lamp::server::nginx

  create_resources('::nginx::resource::vhost', { "${title}" =>
    merge(
      $lamp::server::nginx::default_vhost_options,
      { 'www_root' => $path, 'index_files' => $index },
      $options
    )
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
      /* lamp::vhost::location::nginx { "${title}_php": */
      /*   vhost    => $site, */
      /*   server   => 'nginx', */
      /*   path     => $path, */
      /*   priority => 600, */
      /*   match    => '[^/]\.php(/|$)', */

      /*   custom_cfg => { */
      /*     'deny' => 'all', */
      /*     'access_log' => 'off', */
      /*     'log_not_found' => 'off', */
      /*   } */
      /* } */
    }
  }

  # setup default location
  lamp::vhost::location::nginx { "${title}-default":
    path           => $path,
    vhost          => $site,
    index          => $index,
    proxy          => $proxy,
    proxy_match    => $proxy_match,
    # TODO pass engine here?
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
