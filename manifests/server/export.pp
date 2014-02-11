define nfs::server::export (
  $server = $::clientcert,
  $v4_export_name = regsubst($name, '.*/(.*)', '\1' ),
  $clients = 'localhost(ro)',
  $ensure = 'mounted',
  $mount = undef,
  $remounts = false,
  $atboot = false,
  $options = '_netdev',
  $bindmount = undef,
  $nfstag = undef
) {

  concat::fragment { $name:
    target  => '/etc/exports',
    content => "${name} ${clients}\n",
    order   => 10,
  }

  @@nfs::client::mount {"shared_${v4_export_name}_by_${::clientcert}":
    ensure    => $ensure,
    mount     => $mount,
    remounts  => $remounts,
    atboot    => $atboot,
    options   => $options,
    nfstag    => $nfstag,
    share     => $v4_export_name,
    server    => $server,
  }
}
