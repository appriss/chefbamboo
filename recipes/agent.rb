#
# Cookbook Name:: bamboo
# Recipe:: agent
#
# Copyright 2013, Appriss Inc.
#
# All rights reserved - Do Not Redistribute
#
#
require 'uri'
include_recipe 'java'

bamboo_base_dir = File.join(node[:bamboo][:install_path],node[:bamboo][:base_name])

# Create a system user account on the server to run the Atlassian Bamboo server
user node[:bamboo][:run_as] do
  system true
  shell  '/bin/bash'
  home   node[:bamboo][:home]
  action :create
end

# Create a home directory for the Atlassian Bamboo user
directory node[:bamboo][:home] do
  owner node[:bamboo][:run_as]
  group node[:bamboo][:run_as]
  mode 0755
  recursive true
  action :create
end

# If SSL agent support is enabled
if node[:bamboo][:agent][:enable_ssl]
  # Download the client keystore
  remote_file "#{node[:bamboo][:home]}/bamboo_client.ks" do
    source "#{node[:bamboo][:agent][:enable_ssl][:client_keystore]}"
    owner node[:bamboo][:run_as]
    action :create
  end

  # Download the client truststore
  remote_file "#{node[:bamboo][:home]}/bamboo_client.ts" do
    source "#{node[:bamboo][:agent][:enable_ssl][:client_truststore]}"
    owner node[:bamboo][:run_as]
    action :create
  end
end

# Install bamboo agent drivers
remote_file "/tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar" do
  source "https://bamboo.sdlc.appriss.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar"
  owner node[:bamboo][:run_as]
  action :create
end

# Install the bamboo agent
execute "install bamboo agent" do
  command "java -Djavax.net.ssl.keyStore=#{node[:bamboo][:home]}/bamboo_client.ks -Djavax.net.ssl.keyStorePassword=#{node[:bamboo][:agent][:enable_ssl][:keystore_password]} -Djavax.net.ssl.trustStore=#{node[:bamboo][:home]}/bamboo_client.ts -jar /tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar https://bamboo.sdlc.appriss.com/agentServer/ install"
  user node[:bamboo][:run_as]
  action :run
end

# Start the bamboo agent
execute "install bamboo agent" do
  command "java -Djavax.net.ssl.keyStore=#{node[:bamboo][:home]}/bamboo_client.ks -Djavax.net.ssl.keyStorePassword=#{node[:bamboo][:agent][:enable_ssl][:keystore_password]} -Djavax.net.ssl.trustStore=#{node[:bamboo][:home]}/bamboo_client.ts -jar /tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar https://bamboo.sdlc.appriss.com/agentServer/ start"
  user node[:bamboo][:run_as]
  action :run
end
