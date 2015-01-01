#
# Cookbook Name:: lvsf-opsworks-php-cookbook
# Recipe:: configure
#
# This is the app deploy recipe for a PHP app.
#
# Copyright (C) 2014 LiveSafe
#

node['deploy'].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  template "#{node['lvsf_opsworks_php']['php_app_srv_dir']}/opsworks.php" do
    source 'opsworks.php.erb'
    mode '0660'
    owner node['lvsf_opsworks_php']['nginx_user']
    group node['lvsf_opsworks_php']['nginx_user']
    variables(
      database: deploy[:database],
      memcached: deploy[:memcached],
      layers: node['opsworks'][:layers],
      stack_name: node['opsworks']['stack'][:name]
    )
  end
end
