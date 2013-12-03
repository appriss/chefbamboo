#
# Cookbook Name:: bamboo
# Attributes:: bamboo
#
# Copyright 2008-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The openssl cookbook supplies the secure_password library to generate random passwords
default[:bamboo][:virtual_host_name]  = "bamboo.#{domain}"
default[:bamboo][:virtual_host_alias] = "bamboo.#{domain}"
# type-version-standalone
default[:bamboo][:base_name]	    = "atlassian-bamboo"
default[:bamboo][:version]           = "2.1.1"
default[:bamboo][:install_path]      = "/opt/bamboo"
default[:bamboo][:home]              = "/var/lib/bamboo"
default[:bamboo][:source]            = "http://www.atlassian.com/software/bamboo/downloads/binary/#{node[:bamboo][:base_name]}-#{node[:bamboo][:version]}.tar.gz"
default[:bamboo][:run_as]          = "bamboo"
default[:bamboo][:min_mem]	    = 256
default[:bamboo][:max_mem]	    = 384
default[:bamboo][:ssl]		    = true
default[:bamboo][:database][:type]   = "mysql"
default[:bamboo][:database][:host]     = "localhost"
default[:bamboo][:database][:user]     = "bamboo"
default[:bamboo][:database][:name]     = "bamboo"
default[:bamboo][:service][:type]      = "jsw"
if node[:opsworks][:instance][:architecture]
  default[:bamboo][:jsw][:arch]          = node[:opsworks][:instance][:architecture].gsub!(/_/,"-")
else
  default[:bamboo][:jsw][:arch]          = node[:kernel][:machine].gsub!(/_/,"-")
end
default[:bamboo][:jsw][:base_name]     = "wrapper-linux-#{node[:bamboo][:jsw][:arch]}"
default[:bamboo][:jsw][:version]       = "3.5.20"
default[:bamboo][:jsw][:install_path]  = ::File.join(node[:bamboo][:install_path],"#{node[:bamboo][:base_name]}")
default[:bamboo][:jsw][:source]        = "http://wrapper.tanukisoftware.com/download/#{node[:bamboo][:jsw][:version]}/wrapper-linux-#{node[:bamboo][:jsw][:arch]}-#{node[:bamboo][:jsw][:version]}.tar.gz"
# Confluence doesn't support OpenJDK http://bamboo.atlassian.com/browse/CONF-16431
# FIXME: There are some hardcoded paths like JAVA_HOME
set[:java][:install_flavor]    = "oracle"
set[:oracledb][:jdbc][:install_dir] = ::File.join(node[:bamboo][:install_path],node[:bamboo][:base_name],"lib")
