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

  /* install composer? */
  $composer   = false,

  /* PHP extensions */
  $extensions = {},

  /* PHP.ini config */
  $ini        = {}
) inherits lamp::params {

  # prefix our PHP.ini settings with the section
  $real_ini = hash(flatten($ini.map |$k, $v| {
    if $k =~ '/' {
      [$k, $v]
    } else {
      # attempt to guess the section
      if $k =~ 'date.' {
        ["Date/$k", $v]
      } elsif $k =~ 'xdebug.' {
        ["xdebug/$k", $v]
      } else {
        ["PHP/$k", $v]
      }
    }
  }))

  class { '::php':
    ensure   => $version,
    settings => $real_ini
  }

  contain ::php

  if ($composer) {
    contain ::php::composer
  }

  if (is_hash($extensions)) {
    create_resources('::php::extension', $extensions)
  } else {
    $extensions.each |$extension| {
      if (is_hash($extension)) {
        create_resources('::php::extension', $extension)
      } else {
        ::php::extension { $extension: }
      }
    }
  }

}
