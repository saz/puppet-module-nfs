# Class: nfs::params
class nfs::params {
  case $::osfamily {
    'Debian': {
      $server_package_name = 'nfs-kernel-server'
      $server_service_name = 'nfs-kernel-server'
      $server_service_onlyif = "systemctl status ${server_service_name}"
      $server_service_reload = 'exportfs -ra'
      $server_service_hasstatus = true
      $server_service_hasrestart = true
      $client_package_name = 'nfs-common'
      $client_service_name = 'rpcbind'
      $nfs4_package_name = 'nfs4-acl-tools'
    }
    default: {
      case $::operatingsystem {
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
