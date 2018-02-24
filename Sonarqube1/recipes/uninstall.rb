#
# Cookbook:: Sonarqube1
# Description: "Seek and Destroy"
# Recipe:: uninstall
#
# Copyright:: 2018, The Authors, All Rights Reserved.

service 'httpd' do
  supports :status => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :stop ]
  only_if { ::File.exists?("/usr/sbin/httpd") }
end

service 'sonar' do
  supports :start => true, :stop => true
  action [ :enable, :stop ]
  only_if { ::File.exists?("/usr/bin/sonar") }
end

service 'mysqld' do
  supports :status => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :stop ]
  only_if { ::File.exists?("/usr/sbin/mysqld") }
end

package %w(mysql-server wget httpd unzip java-1.8.0-openjdk )  do
  action :remove
end

execute 'clearing the service link' do
  command 'unlink /usr/bin/sonar'
  only_if { ::File.exists?("/usr/bin/sonar") }
end

execute 'clearing the link' do
  command 'unlink /opt/sonarqube'
  only_if { ::File.exists?("/opt/sonarqube") }
end

execute 'clearing the link' do
  command 'unlink /opt/sonarqube'
  only_if { ::File.exists?("/opt/sonarqube") }
end

execute 'clearing the DB foot print' do
  command 'unlink /opt/db.created'
  only_if { ::File.exists?("/opt/db.created") }
end

execute 'removing sonarqube-6.7.1.zip file' do
  command 'unlink /opt/sonarqube-6.7.1.zip'
  only_if { ::File.exists?("/opt/sonarqube-6.7.1.zip") }
end

directory "/opt/sonarqube-6.7.1" do
  recursive true
  action :delete
  only_if { ::File.exists?("/opt/sonarqube-6.7.1") }
end

user node['sonarqube']['sonar_user'] do
  action :remove
end

group node['sonarqube']['sonar_group'] do
  action :remove
end
