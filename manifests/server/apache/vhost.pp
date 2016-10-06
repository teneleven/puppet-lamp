define lamp::server::apache::vhost (
  $site   = $title, /* used as nginx identifier */
  $path   = undef,
  $engine = undef,

  /* nginx options */
  $options = {},

  /* hash with keys: match => regex, listen => FCGI addr */
  $apps = {},

  /* TODO consolidate location syntax */
  $locations = {},

  /* proxy all requests to this url */
  $proxy       = undef,
  $proxy_match = undef,
) {

  include lamp::params

  contain lamp::server::apache

  contain apache::mod::rewrite

  if ($proxy) {
    contain apache::mod::proxy

    $proxy_pass = {
      url  => $proxy,
      path => $proxy_match ? {
        undef   => "/",
        default => $proxy_match,
      },
    }
  } else {
    $proxy_pass = undef
  }

  if ($engine == 'php') {
    contain apache::mod::proxy
    contain apache::mod::proxy_fcgi

    $engine_match = '\\.php(/.*)?$'
  } else {
    $engine_match = undef
  }

  /* expand listen URL for apache-specific syntax */
  if ('unix:' in $lamp::params::fcgi_listen or 'fcgi:' in $lamp::params::fcgi_listen) {
    $engine_listen = "${lamp::params::fcgi_listen}"
  } else {
    $engine_listen = "fcgi://${lamp::params::fcgi_listen}"
  }

  /* setup apache vhost */
  create_resources('::apache::vhost', { "${title}" => merge(
    $options,
    {
      proxy_pass => $proxy_pass,
      custom_fragment => template('lamp/vhost/apache.erb')
    }
  ) })

}
