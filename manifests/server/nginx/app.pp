define lamp::server::nginx::app (
  $site   = undef,

  $engine = undef,
  $match  = undef,
  $path   = undef,

  $script = undef, /* script to forward all requests to */
  $listen = undef  /* fcgi listen address */
) {

  if ($engine == 'php') {
    $custom_cfg = {
      'fastcgi_split_path_info' => '^(.*\.php)(.*)$',
      /* fixes nginx path_info bug: https://forum.nginx.org/read.php?2,238825,238860 */
      'fastcgi_param PATH_INFO' => '$path_info',
      'set $path_info' => '$fastcgi_path_info',
    }

    /* don't allow access if file doesn't exist */
    $custom_raw = 'if (!-f $document_root$fastcgi_script_name) { return 404; }'

    $app_root   = '/$document_root'
  } else {
    $custom_cfg = undef
    $custom_raw = undef
    $app_root   = undef
  }

  lamp::server::nginx::fcgi { "${title}":
    /* ensure          => present, */
    site            => $site,
    path            => $path,
    location        => "~ ${match}",
    host            => $listen,
    proxy           => $proxy,
    app             => $script,
    app_root        => $app_root,

    /* TODO can we do this automatically ? */
    /* fastcgi_param   => { */
    /*   'SCRIPT_FILENAME' => "${app_root}/${app}" */
    /* }, */

    custom_cfg => $custom_cfg,
    custom_raw => $custom_raw
  }

}
