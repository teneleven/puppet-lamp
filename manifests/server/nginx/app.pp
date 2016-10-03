define lamp::server::nginx::app (
  $match  = undef,
  $listen = undef,
  $site   = undef
) {

  ::nginx::resource::location { "${title}":
    ensure          => present,
    vhost           => $site,

    /* TODO necessary ? */
    /* www_root        => $path, */
    /* priority        => $priority, */

    location        => "~ ^/${match}",
    fastcgi         => $listen,

    /* TODO can we do this automatically ? */
    /* fastcgi_param   => { */
    /*   'SCRIPT_FILENAME' => "${app_root}/${app}" */
    /* }, */

    location_cfg_prepend => {
      fastcgi_buffers => '16 16k',
      fastcgi_buffer_size => '32k'
    }
  }

}
