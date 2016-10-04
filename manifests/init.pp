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
    } else {
      $server = $lamp::params::default_vhost_server
    }

    contain "lamp::server::${server}"

    create_resources("lamp::server::${server}::vhost", { $name => merge(
      { engine => $lamp::params::default_vhost_engine },
      delete($vhost, 'server')
    )})
  }

  if ($php) {
    create_resources('class', { 'lamp::php' => $php })
  }

  /* if ($db) { */
  /* } */

}
