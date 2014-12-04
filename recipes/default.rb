#
# Cookbook Name:: lvsf-opsworks-php-cookbook
# Recipe:: default
#
# Copyright (C) 2014 LiveSafe
#

include_recipe 'apt'
include_recipe 'nginx'

nginx_user = 'www-data'

# For testing
package 'vim' do
  action :install
end

# setup php fpm
execute 'CGI Fix pathinfo' do
  command "sed 's/^;cgi\.fix_pathinfo=1$/cgi.fix_pathinfo=0/'"\
    " -i #{node['php_fpm']['base_path']}/php.ini"
  not_if "grep '^cgi\.fix_pathinfo=0$' #{node['php_fpm']['base_path']}/php.ini"
end

# setup nginx stuff
directory '/usr/share/nginx/www' do
  owner nginx_user
  action :create
end

# enable our nginx config
template "#{node['nginx']['dir']}/sites-available/php-app" do
  source 'nginx/sites-available/php-app.erb'
end

link "#{node['nginx']['dir']}/sites-enabled/php-app" do
  to "#{node['nginx']['dir']}/sites-available/php-app"
end

link "#{node['nginx']['dir']}/sites-enabled/default" do
  action :delete
end

# basic app for testing
template '/usr/share/nginx/www/info.php' do
  source 'info.php.erb'
end

# restart services
service 'php5-fpm' do
  action :restart
end

service 'nginx' do
  action :restart
end
