/**
 * Wraps Node.JS installing npm modules, etc.
 */
class lamp::nodejs (
  /* set to version string, i.e. 0.10 or 5.x */
  $version      = undef,

  /* install npm? */
  $npm          = true,

  /* global npm modules */
  $npm_modules  = {},

  /* dirs to locally execute npm install */
  $install      = [],

  /* whether to manage the repo - set to false to use native nodejs package */
  $manage_package_repo = true,
) inherits lamp::params {

  class { '::nodejs':
    repo_url_suffix     => $version,
    manage_package_repo => $manage_package_repo,
    npm_package_ensure  => $npm ? {
      true  => 'present',
      false => 'absent',
    },
  }

  if (is_hash($npm_modules)) {
    create_resources('package', $npm_modules)
  } else {
    package { $npm_modules:
      ensure   => 'present',
      provider => 'npm',
    }
  }

  if (is_hash($install)) {
    create_resources('nodejs::npm', $install)
  } else {
    # not hash - assume a list of install dirs
    $install.each |$path| {
      nodejs::npm { $path:
        ensure  => 'present',
        target  => $path,
        package => $path,
      }
    }
  }

}
