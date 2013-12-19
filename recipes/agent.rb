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

# Install bamboo agent drivers if needed
if node[:bamboo][:agent][:bucket] != nil
    s3_file "/tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar" do
      bucket node[:bamboo][:agent][:bucket]
      remote_path node[:bamboo][:agent][:path]
      owner node[:bamboo][:run_as]
      # mode "0644"
      action :create
    end
end

# Set the permissions of the Atlassian Bamboo directory
# execute "configure bamboo permissions" do
#   command "chown -R #{node[:bamboo][:run_as]} #{node[:bamboo][:install_path]}"
#   action :nothing
# end

# Install the bamboo agent
execute "install bamboo agent" do
  command "java -jar /tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar https://bamboo.sdlc.appriss.com/agentServer/ install"
  user node[:bamboo][:run_as]
  action :run
end

# Start the bamboo agent
execute "install bamboo agent" do
  command "java -jar /tmp/atlassian-bamboo-agent-installer-#{node[:bamboo][:version]}.jar https://bamboo.sdlc.appriss.com/agentServer/ start"
  user node[:bamboo][:run_as]
  action :run
end