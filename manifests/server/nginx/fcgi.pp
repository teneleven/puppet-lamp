define lamp::server::nginx::fcgi (
  $site = undef, /* vhost */

  $path = "${teneleven::params::web_root}/${title}/${teneleven::params::web_suffix}",

  /* fcgi socket or HOST:PORT */
  $host = '127.0.0.1:9000',

  /* fcgi app root in the fcgi container (e.g. /var/www or /app) */
  $app_root = $teneleven::params::app_root,

  $app      = undef,
  $location = undef,
  $priority = 401,

  $custom_cfg = {},    /* custom nginx location directive(s) */
  $custom_raw = undef, /* custom, raw, nginx location directive(s) */
) {
  $apps = $app ? {
    default => any2array($app),
    undef   => ['$fastcgi_script_name']
  }

  $apps.each |$app| {
    ::nginx::resource::location { "${title}_${app}":
      ensure          => present,
      vhost           => $site,
      www_root        => $path,
      location        => $location ? {
        default => $location,
        undef   => "~ ^/${app}(/|\$)"
      },
      fastcgi         => $host,
      fastcgi_param   => {
        'SCRIPT_FILENAME' => "${app_root}/${app}"
      },
      priority        => $priority,

      location_cfg_prepend => merge({
        fastcgi_buffers => '16 16k',
        fastcgi_buffer_size => '32k'
      }, $custom_cfg),
      raw_prepend          => $custom_raw,
    }
  }
}
