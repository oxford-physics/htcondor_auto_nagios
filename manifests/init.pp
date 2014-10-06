# == Class: htcondor_auto_nagios
#
# Full description of class htcondor_auto_nagios here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { htcondor_auto_nagios:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class htcondor_auto_nagios {
    $plugin_dir = '/usr/lib64/nagios/plugins'
    $nrpe_cfg_dir = '/etc/nrpe.d'
    
    file { "${plugin_dir}/check_condor_all.py":
    source  => "puppet:///modules/${module_name}/check_condor_all.py",
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package['nrpe'],
    notify  => Service['nrpe'],
   }
   
    file { "${nrpe_cfg_dir}/check_condor_all.cfg":
    content => template('htcondor_auto_nagios/check_condor_all.cfg'),
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package['nrpe'],
    notify  => Service['nrpe'],
   }

   
   @@nagios_service { "condor_all${::fqdn}":
    check_command       => 'check_nrpe!check_condor_all',
    host_name           => $::fqdn,
    service_description => 'Condor All',
   # servicegroups       => 'condor',
    use                 => '30min-service',
    target              => "/etc/nagios/nagios_services.d/${::fqdn}.cfg",
  }

   @@nagios_service { "condor_health${::fqdn}":
    check_command       => 'check_dummy!1 No passive checks for at least 48h',
    host_name           => $::fqdn,
    active_checks_enabled => 0,
    service_description => 'Condor Health check',
   # servicegroups       => 'condor',
    use                 => '30min-service',
    target              => "/etc/nagios/nagios_services.d/${::fqdn}.cfg",
  }

}
