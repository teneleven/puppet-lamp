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

  include ::nodejs::params

  class { '::nodejs':
    manage_package_repo => $manage_package_repo,
    repo_url_suffix     => $version ? {
      undef   => $::nodejs::params::repo_url_suffix,
      default => $version,
    },
    npm_package_ensure  => $npm ? {
      true  => 'present',
      false => 'absent',
    },

    # this is necessary otherwise npm tries to keep removing itself...
    nodejs_dev_package_name => undef,
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
      # use manual exec so we don't hit timeout
      exec { "npm_install_${path}":
        command => "${::nodejs::npm_path} install",
        cwd     => $path,
        require => $::nodejs::npm_package_name ? {
          false   => Class['nodejs'],
          default => Package[$::nodejs::npm_package_name],
        },
        timeout => 0, # this can take a long time
      }
    }
  }

}
