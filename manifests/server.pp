# == Class: nfs::server
#
# Set up NFS server and exports. NFSv3 and NFSv4 supported.
#
#
# === Parameters
#
# [nfs_v4]
#   NFSv4 support. Will set up automatic bind mounts to export root.
#   Disabled by default.
#
# [nfs_v4_export_root]
#   Export root, where we bind mount shares, default /export
#
# [nfs_v4_idmap_domain]
#  Domain setting for idmapd, must be the same across server
#  and clients.
#  Default is to use $domain fact.
#
# === Examples
#
#
#  class { nfs::server:
#    nfs_v4                      => true,
#     nfs_v4_export_root_clients => "*.${::domain}(ro,fsid=root,insecure,no_subtree_check,async,root_squash)",
#    # Generally parameters below have sane defaults.
#    nfs_v4_export_root  => "/export",
#    nfs_v4_idmap_domain => $::domain,
#  }
#
# === Authors
#
# Harald Skoglund <haraldsk@redpill-linpro.com>
#
# === Copyright
#
# Copyright 2012 Redpill Linpro, unless otherwise noted.
#

class nfs::server (
  $idmap_domain = $::domain
) inherits nfs::params {

  package { $nfs::params::server_package_name:
    ensure => present,
  }

  concat { '/etc/exports':
    require => Package[$nfs::params::server_package_name],
  }

  concat::fragment { 'nfs_exports_header':
    target  => '/etc/exports',
    content => "# This file is managed by puppet\n",
    order   => 00,
  }

  if ! defined(Class['nfs::common']) {
    class { 'nfs::common':
      idmap_domain => $idmap_domain,
      require      => Concat['/etc/exports'],
    }
  }

  service { $nfs::params::server_service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => $nfs::params::server_service_hasstatus,
    hasrestart => $nfs::params::server_service_hasrestart,
    require    => Class['nfs::common'],
  }
}
