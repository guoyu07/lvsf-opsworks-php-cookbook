#
# Cookbook Name:: lvsf-opsworks-php-cookbook
# Recipe:: deploy
#
# This is the app deploy recipe for a PHP app.
#
# Copyright (C) 2014 LiveSafe
#

include_recipe 'deploy'

node['deploy'].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  # TODO: Use cap properly and kill the following with fire
  bash 'copy to nginx www dir' do
    code "cp -Rv #{deploy[:deploy_to]}/current/* #{node['lvsf_opsworks_php']['php_app_srv_dir']}"
  end
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
