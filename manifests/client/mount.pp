#
#
#== Define nfs::client::mount
#
#Set up NFS server and exports. NFSv3 and NFSv4 supported.
#
#
#=== Parameters
#
#=== Examples
#
#=== Authors
#
#Harald Skoglund <haraldsk@redpill-linpro.com>
#
#=== Copyright
#
#Copyright 2012 Redpill Linpro, unless otherwise noted.
#
#

define nfs::client::mount (
  $server,
  $share,
  $ensure = 'mounted',
  $mount = $title,
  $remounts = false,
  $atboot = false,
  $options = '_netdev',
  $nfstag = undef
) {

  include nfs::client

  if $mount == $title {
    $_mount = "${nfs::client::mount_root}/${share}"
  } else {
    $_mount = $mount
  }

  nfs::mkdir{ $_mount: }

  mount { "shared_${share}_by_${::clientcert}_on_${_mount}":
    ensure   => $ensure,
    device   => "${server}:/${share}",
    fstype   => 'nfs4',
    name     => $_mount,
    options  => $options,
    remounts => $remounts,
    atboot   => $atboot,
    require  => Nfs::Mkdir[$_mount],
  }
}
