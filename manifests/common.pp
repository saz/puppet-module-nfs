class nfs::common(
  $idmap_domain
) {
  augeas { '/etc/idmapd.conf':
    context => '/files/etc/idmapd.conf/General',
    lens    => 'Puppet.lns',
    incl    => '/etc/idmapd.conf',
    changes => "set Domain ${idmap_domain}",
    require => Package[$nfs::params::client_package_name],
  }

  case $::osfamily {
    'Debian': {
      augeas { '/etc/default/nfs-common':
        context => '/files/etc/default/nfs-common',
        changes => 'set NEED_IDMAPD yes',
        require => Augeas['/etc/idmapd.conf'],
      }
    }
    default: {
    }
  }
}
