# Class: bamboo
#
# This module manages Atlassian Bamboo
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class bamboo (
  $version = '5.6.0',
  $install_prefix = '/usr/local',
  $home_prefix= '/var/local',
  $user = 'bamboo') {

  $exec_path = '/bin/:/sbin/:/usr/bin/:/usr/sbin/'

  $download_url = "http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${version}.tar.gz"
  $zip_file = "/tmp/atlassian-bamboo-${version}.tar.gz"
  $zip_output = "/tmp/atlassian-bamboo-${version}"
  $install_dir = "${install_prefix}/bamboo-${version}"

  $home_dir = "${home_prefix}/bamboo"

  user { $user:
      ensure     => present,
      home       => $home,
      managehome => false,
      system     => true,
  } ->
  exec { 'download bamboo':
    command => "wget ${download_url}",
    creates => $zip_file,
    user    => $user,
    cwd     => '/tmp',
    path    => $exec_path,
  } ->
  exec { 'unzip bamboo':
    command => "tar zxf ${zip_file}",
    creates => $zip_output,
    user    => $user,
    cwd     => '/tmp',
    path    => $exec_path,
  } ->
  exec { 'copy bamboo to installation directory':
    command => "mv ${zip_output} ${install_dir}",
    creates => $install_dir,
    user    => $user,
    path    => $exec_path,
  } ->
  file { $install_dir:
    ensure  => directory,
    owner   => $user,
    group   => 'root',
    mode    => 0640,
    recurse => true,
  } ->
  file { "${install_dir}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties":
    content => template('bamboo/bamboo-init.properties.erb'),
  } ->
  file { $home:
    ensure  => directory,
    owner   => $user,
    group   => 'root',
    mode    => 0640,
    recurse => true,
  } ->
  file { "${home}/logs":
    ensure => directory,
  } ->
  file { '/etc/init.d/bamboo':
    ensure  => present,
    content => template('bamboo/bamboo.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0770
  } ~>
  exec { 'configure bamboo service':
    command => 'update-rc.d bamboo defaults'
  } ~>
  service { 'bamboo':
    ensure     => running,
    hasrestart => true,
    hasstatus  => false,
  }
}
