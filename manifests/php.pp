/**
 * Wraps mayflower PHP & sets up initial FPM pool, extensions, and PHP.ini
 * settings.
 *
 * Feel free to define custom settings/resources using hiera. For example, if
 * you want to change the PHP config_root setting, set it in your hiera config
 * like:
 *
 *   php::globals::config_root: '/etc/php/7.0'
 *
 * See more info & examples here: https://github.com/voxpupuli/puppet-php
 */
class lamp::php (
  /* set to version string, i.e. 7.0 or 5.6 */
  $version    = latest,

  /* PHP extensions */
  $extensions = {},

  /* PHP.ini config */
  $ini        = {},

  /* use $dev_settings when $lamp::params::dev is true */
  $dev_settings = {
    'PHP/display_errors' => 'On',
    'opcache/opcache.enable' => '0',
    'xdebug/xdebug.remote_enable' => '1',
    'xdebug/xdebug.remote_connect_back' => '1',
    'xdebug/xdebug.max_nesting_level' => '10000'
  }
) inherits lamp::params {

  class { '::php':
    ensure   => $version,
    settings => $dev ? {
      true  => merge($dev_settings, $ini),
      false => $ini
    }
  }

  if (is_hash($extensions)) {
    create_resources('::php::extension', { $extensions => {} })
  } else {
    php::extension { $extensions: }
  }

}
