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

  if ($path and $engine == 'php') {
    notice("creating php engine for ${title}")

    /* handle *.php files */
    lamp::vhost::location::nginx { "${title}_php":
      path   => $path,
      vhost  => $site,
      index  => $index,
      engine => 'fcgi',
      match  => '[^/]\.php(/|$)',
      fcgi_config => { 'fastcgi_split_path_info' => '^(.*\.php)(.*)$' },
      fcgi_raw    => 'if (!-f $document_root$fastcgi_script_name) { return 404; }',
    }
  }

  # setup default location
  lamp::vhost::location::nginx { "${title}-default":
    path           => $path,
    vhost          => $site,
    index          => $index,
    proxy          => $proxy,
    proxy_match    => $proxy_match,
    engine         => $engine ? {
      # we already include a location matching .php files above
      'php'   => undef,
      default => $engine,
    },
  }

  $locations.each |$key, $location| {
    create_resources('lamp::vhost::location::nginx', { "${key}" => merge(
      { 'vhost' => $site, 'path' => $path },
      $location
    )})
  }

}
