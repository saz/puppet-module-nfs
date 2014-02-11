# ## Class: nfs::server
#
# Set up NFS server and exports. NFSv3 and NFSv4 supported.
#
# ## Parameters
#
# [export_root]
#   NFSv4 support. Will set up automatic bind mounts to export root.
#   Disabled by default.
#
# [export_root]
#   Export root
#   Default: '/export'
# [export_root_clients]
#   Export root client options
#   Default: "*.${::domain}(rw,fsid=root,insecure,no_subtree_check,no_root_squash)"
#
# [idmap_domain]
#   Domain setting for idmapd, must be the same across server and clients.
#   Default: $::domain
#
# [service_enable]
#   Enable nfs service at boot
#   Default: true
#
# [service_ensure]
#   Ensure nfs service
#   Default: 'running'
#
# ## Example
#
#  class { nfs::server: }
#
# ### Unmanaged service (good for Heartbeat/Pacemaker management)
#
#  class { nfs::server:
#    service_enable = false,
#    service_ensure = false,
#  }
#
# ## Authors
#
# Steffen Zieger <me@saz.sh>
#
# ## Copyright
#
# Copyright 2014 Steffen Zieger
#

class nfs::server (
  $export_root = '/export',
  $export_root_clients = "*.${::domain}(rw,fsid=root,insecure,no_subtree_check,no_root_squash)",
  $idmap_domain = $::domain,
  $service_enable = true,
  $service_ensure = 'running'
) inherits nfs::params {

  if ! defined(Package[$nfs::params::server_package_name]) {
    package { $nfs::params::server_package_name:
      ensure => present,
    }
  }

  concat { '/etc/exports':
    require => Package[$nfs::params::server_package_name],
  }

  concat::fragment { 'nfs_exports_header':
    target  => '/etc/exports',
    content => "# This file is managed by puppet\n",
    order   => 00,
  }

  concat::fragment { 'nfs_exports_root':
    target  => '/etc/exports',
    content => "${export_root} ${export_root_clients}\n",
    order   => 01,
  }

  file { $export_root:
    ensure  => directory,
  }

  if ! defined(Class['nfs::common']) {
    class { 'nfs::common':
      idmap_domain => $idmap_domain,
      require      => File[$export_root],
    }
  }

  exec { 'reload_nfs_srv':
    command     => $nfs::params::server_service_reload,
    onlyif      => $nfs::params::server_service_onlyif,
    refreshonly => true,
    require     => Class['nfs::common'],
    subscribe   => Concat['/etc/exports'],
  }

  if $service_ensure != false {
    $service_ensure_real = $service_ensure
  } else {
    $service_ensure_real = undef
  }

  service { $nfs::params::server_service_name:
    ensure     => $service_ensure_real,
    enable     => $service_enable,
    hasstatus  => $nfs::params::server_service_hasstatus,
    hasrestart => $nfs::params::server_service_hasrestart,
    require    => Class['nfs::common'],
  }
}
