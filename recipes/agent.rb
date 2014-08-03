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
  home   node[:bamboo][:agent][:home]
  action :create
end

# Create a home directory for the Atlassian Bamboo user
directory node[:bamboo][:agent][:home] do
  owner node[:bamboo][:run_as]
  group node[:bamboo][:run_as]
  mode 0755
  recursive true
  action :create
end

# If SSL agent support is enabled
if node[:bamboo][:agent][:ssl][:enable]
  # Download the client keystore
  remote_file "#{node[:bamboo][:agent][:home]}/bamboo_client.ks" do
    source "#{node[:bamboo][:agent][:ssl][:client_keystore]}"
    owner node[:bamboo][:run_as]
    action :create
  end

  # Download the client truststore
  remote_file "#{node[:bamboo][:agent][:home]}/bamboo_client.ts" do
    source "#{node[:bamboo][:agent][:ssl][:client_truststore]}"
    owner node[:bamboo][:run_as]
    action :create
  end
end

# Download the bamboo agent drivers
remote_file "/tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar" do
  source "https://bamboo.sdlc.appriss.com/agentServer/agentInstaller/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar"
  owner node[:bamboo][:run_as]
  action :create
end

# Install the bamboo agent
execute "install bamboo agent" do
  command "java -jar /tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar https://bamboo.sdlc.appriss.com/agentServer/ install"
  user node[:bamboo][:run_as]
  action :run
end

# Clone and modify the JRE truststore
#case node["platform_family"]
#when "debian"
  # do things on debian-ish platforms (debian, ubuntu, linuxmint)
#  execute "copy jre cacerts truststore for modification" do
#    command "cp /usr/lib/jvm/default-java/jre/lib/security/cacerts /tmp && "
#    user node[:bamboo][:run_as]
#  end
#when "rhel"
  # do things on RHEL platforms (redhat, centos, scientific, etc)
#  execute "copy jre cacerts truststore for modification" do
#    command "cp /usr/lib/jvm/java/jre/lib/security/cacerts /tmp && "
#    user node[:bamboo][:run_as]
#  end
#when "fedora"
#  execute "copy jre cacerts truststore for modification" do
#    command "cp /usr/lib/jvm/jre/lib/security/cacerts /tmp && "
#    user node[:bamboo][:run_as]
#  end
#when "suse"
  # do things on SuSe platforms (opensuse, SLES)
#end

# Configure wrapper
template File.join(node[:bamboo][:agent][:home],"bamboo-agent-home","conf","wrapper.conf") do
  owner node[:bamboo][:run_as]
  source "wrapper.conf.agent.erb"
  mode 0644
end

# Install capabilities file
if node[:bamboo][:agent][:capabilities_url] != ""
  remote_file File.join(node[:bamboo][:agent][:home],"bamboo-agent-home","bin","bamboo-capabilities.properties") do
  owner node[:bamboo][:run_as]
  source node[:bamboo][:agent][:capabilities_url]
end

# Start the bamboo agent
execute "start bamboo agent" do
  command "#{node[:bamboo][:agent][:home]}/bamboo-agent-home/bin/bamboo-agent.sh start"
  user node[:bamboo][:run_as]
  action :run
end
