
#
# Cookbook Name:: bamboo
# Recipe:: default
#
# Copyright 2013, Appriss Inc.
#
# All rights reserved - Do Not Redistribute
#
#
require 'uri'
include_recipe 'java'
#include_recipe 'apache2'
#include_recipe 'apache2::mod_rewrite'
#include_recipe 'apache2::mod_proxy'
#include_recipe 'apache2::mod_ssl'
include_recipe 'labrea'

bamboo_base_dir = File.join(node[:bamboo][:install_path],node[:bamboo][:base_name])

# Create a system user account on the server to run the Atlassian Bamboo server
user node[:bamboo][:run_as] do
  system true
  shell  '/bin/bash'
  action :create
end

# Create a home directory for the Atlassian Bamboo user
directory node[:bamboo][:home] do
  owner node[:bamboo][:run_as]
end

# Install or Update the Atlassian Bamboo package
labrea "atlassian-bamboo" do
  source node[:bamboo][:source]
  version node[:bamboo][:version]
  install_dir node[:bamboo][:install_path]
  config_files [File.join("atlassian-bamboo-#{node[:bamboo][:version]}","atlassian-bamboo","WEB-INF","classes","bamboo-init.properties"),
	        File.join("atlassian-bamboo-#{node[:bamboo][:version]}","conf","server.xml")]
  notifies :run, "execute[configure bamboo permissions]", :immediately
end

# Install database drivers if needed
if node[:bamboo][:database][:type] == "oracle"
  uri = ::URI.parse(node[:bamboo][:database][:driver_url])
  if uri.scheme == "s3"
    Chef::Log.info ("URI #{node[:bamboo][:database][:driver_url]}")
    Chef::Log.info ("HOST #{uri.host}")
    Chef::Log.info ("PATH #{uri.path}")
    s3_file ::File.join(bamboo_base_dir,"lib","oracle_jdbc_driver.jar") do
      bucket uri.host
      remote_path uri.path
      owner node[:bamboo][:run_as]
      #mode 0644
      action :create
    end
  else
    remote_file ::File.join(bamboo_base_dir,"lib","oracle_jdbc_driver.jar") do
      source node[:bamboo][:database][:driver_url]
      owner node[:bamboo][:run_as]
      mode 0644
      action :create
    end
  end
end


# Set the permissions of the Atlassian Bamboo directory
execute "configure bamboo permissions" do
  command "chown -R #{node[:bamboo][:run_as]} #{node[:bamboo][:install_path]}"
  action :nothing
end

# Install main config file
template ::File.join(bamboo_base_dir,"atlassian-bamboo","WEB-INF","classes","bamboo-init.properties") do
  owner node[:bamboo][:run_as]
  source "bamboo-init.properties.erb"
  mode 0644
end

# Add the server.xml configuration for Crowd using the erb template
template ::File.join(bamboo_base_dir,"conf","server.xml") do
  owner node[:bamboo][:run_as]
  source "server.xml.erb"
  mode 0644
end

# Install service wrapper

wrapper_home = File.join(bamboo_base_dir,node[:bamboo][:jsw][:base_name])

labrea node[:bamboo][:jsw][:base_name] do
  source node[:bamboo][:jsw][:source]
  version node[:bamboo][:jsw][:version]
  install_dir node[:bamboo][:jsw][:install_path]
  config_files [File.join("#{node[:bamboo][:jsw][:base_name]}-#{node[:bamboo][:jsw][:version]}","conf","wrapper.conf")]
  notifies :run, "execute[configure wrapper permissions]", :immediately
end

# Configure wrapper permissions
execute "configure wrapper permissions" do
  command "chown -R #{node[:bamboo][:run_as]} #{wrapper_home} #{wrapper_home}/*"
  action :nothing
end

# Configure wrapper
template File.join(wrapper_home,"conf","wrapper.conf") do
  owner node[:bamboo][:run_as]
  source "wrapper.conf.erb"
  mode 0644
  variables({
    :wrapper_home => wrapper_home,
    :bamboo_base_dir => bamboo_base_dir
  })
end

# Create wrapper startup script
template File.join(wrapper_home,"bin","bamboo") do
  owner node[:bamboo][:run_as]
  source "bamboo-startup.erb"
  mode 0755
  variables({
    :wrapper_home => wrapper_home
  })
  notifies :run, "execute[install startup script]", :immediately
end

execute "install startup script" do
  command "#{::File.join(wrapper_home,"bin","bamboo")} install"
  action :nothing
  returns [0,1]
  notifies :restart, "service[bamboo]", :immediately
end

service "bamboo" do
  action :nothing
end

#Install plugins
if node[:bamboo][:plugins]
  node[:bamboo][:plugins].keys.each do |key|
    Chef::Log.info("Installing plugin #{key}")
    Chef::Log.info("Plugin URL is #{node[:bamboo][:plugins][key]}")
  end
end
  

# Enable the Apache2 proxy_http module
#execute "a2enmod proxy_http" do
#  command "/usr/sbin/a2enmod proxy_http"
#  notifies :restart, resources(:service => "apache2")
#  action :run
#end

# Add the setenv.sh environment script using the erb template
#template File.join("#{node[:bamboo][:install_path]}/atlassian-bamboo","/bin/setenv.sh") do
#  owner node[:bamboo][:run_as]
#  source "setenv.sh.erb"
#  mode 0644
#end

# Setup the virtualhost for Apache
#web_app "bamboo" do
#  docroot File.join("#{node[:bamboo][:install_path]}/atlassian-bamboo","/") 
#  template "bamboo.vhost.erb"
#  server_name node[:fqdn]
#  server_aliases [node[:hostname], "bamboo"]
#end
