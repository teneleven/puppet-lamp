class lamp (
  $vhosts = {},
  $php    = {},
  $db     = {}
) inherits lamp::params {

  /* ensure web user/group are properly setup */
  ensure_resource('group', $web_group, {
    ensure => present,
    gid    => $web_gid
  })
  ensure_resource('user', $web_user, {
    ensure => present,
    gid    => $web_gid,
    uid    => $web_uid
  })

  $vhosts.each |$name, $vhost| {
    if ($vhost['server']) {
      $server = $vhost['server']
      contain "lamp::server::${server}"
    } else {
      contain "lamp::server::${lamp::params::default_vhost_server}"
    }

    create_resources('lamp::vhost', { $name => merge(
      {
        engine => $lamp::params::default_vhost_engine,
        server => $lamp::params::default_vhost_server,
      },
      $vhost
    )})
  }

  if ($php) {
    create_resources('class', { 'lamp::php' => $php })
  }

  /* if ($db) { */
  /* } */

}
