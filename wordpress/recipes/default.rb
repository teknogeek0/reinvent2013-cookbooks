#
# Cookbook Name:: wordpress
# Recipe:: default
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

if node.has_key?("ec2")
  server_fqdn = node['ec2']['public_hostname']
else
  server_fqdn = node['fqdn']
end

#if node['wordpress']['version'] == 'latest'
#  # WordPress.org does not provide a sha256 checksum, so we'll use the sha1 they do provide
#  require 'digest/sha1'
#  require 'open-uri'
#  local_file = "#{Chef::Config[:file_cache_path]}/wordpress-latest.tar.gz"
#  latest_sha1 = open('http://wordpress.org/latest.tar.gz.sha1') {|f| f.read }
#  unless File.exists?(local_file) && ( Digest::SHA1.hexdigest(File.read(local_file)) == latest_sha1 )
#    remote_file "#{Chef::Config[:file_cache_path]}/wordpress-latest.tar.gz" do
#      source "http://wordpress.org/latest.tar.gz"
#      mode "0644"
#    end
#  end
#else
#  remote_file "#{Chef::Config[:file_cache_path]}/wordpress-#{node['wordpress']['version']}.tar.gz" do
#    source "#{node['wordpress']['repourl']}/wordpress-#{node['wordpress']['version']}.tar.gz"
#    mode "0644"
#  end
#end

directory node['wordpress']['dir'] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

#execute "untar-wordpress" do
#  cwd node['wordpress']['dir']
#  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/wordpress-#{node['wordpress']['version']}.tar.gz"
#  creates "#{node['wordpress']['dir']}/wp-settings.php"
#end

template "#{node['wordpress']['dir']}/wp-config.php" do
  source "wp-config.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :database        => node['wordpress']['db']['database'],
    :user            => node['wordpress']['db']['user'],
    :password        => node['wordpress']['db']['password'],
    :dbhost          => node['wordpress']['dbhost'],
    :lang            => node['wordpress']['languages']['lang']
  )
end

apache_site "000-default" do
  enable false
end

web_app "wordpress" do
  template "wordpress.conf.erb"
  docroot node['wordpress']['dir']
  server_name server_fqdn
  server_aliases node['wordpress']['server_aliases']
end
