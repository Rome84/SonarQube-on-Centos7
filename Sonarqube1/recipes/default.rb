#
# Cookbook:: Sonarqube1
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user node['sonarqube']['sonar_user'] do
  comment 'Sonarqube User'
  home node['sonarqube']['sonar_home']
  system true
  shell '/bin/false'
end

group node['sonarqube']['sonar_group'] do
  action :create
end

package 'wget' do
   action :install
end

package 'httpd' do
   action :install
end

package 'unzip' do
   action :install
end

package 'java-1.8.0-openjdk' do
   action :install
end

remote_file '/tmp/mysql-community-release-el7-5.noarch.rpm' do
  source 'http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

package 'mysql-community-release-el7-5.noarch' do
  action :install
  source '/tmp/mysql-community-release-el7-5.noarch.rpm'
  provider Chef::Provider::Package::Rpm
end

package 'mysql-server' do
   action :install
end

group "logs" do
  action :manage
  members ['mysql']
end

service 'mysqld' do
  supports :status => true, :restart => true, :reload => true
  action [ :start ]
end

template "/tmp/mysql-init.sql" do
  source 'mysql-init.sql'
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'settingup root password and creating sonarqube DB' do
  command 'mysql < /tmp/mysql-init.sql ; touch /opt/db.created'
  not_if { ::File.exists?("/opt/db.created") }
end

template "/etc/my.cnf" do
  source 'my.cnf'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[mysqld]', :delayed
end

service 'mysqld' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

remote_file '/opt/sonarqube-6.7.1.zip' do
  source 'https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.7.1.zip'
  owner 'sonarqube'
  group 'sonarqube'
  mode '0644'
  action :create
end

execute 'sonarqube-6.7.1.zip' do
  command 'unzip sonarqube-6.7.1.zip'
  cwd '/opt'
  not_if { ::File.exists?("/opt/sonarqube-6.7.1") }
end

#directory '/opt/sonarqube-6.7.1' do
#  owner 'sonarqube'
#  group 'sonarqube'
#  mode '0664'
#  recursive true
#end

execute 'creating symlink' do 
  command 'ln -s /opt/sonarqube-6.7.1 /opt/sonarqube'
  cwd '/opt'
  not_if { ::File.exists?("/opt/sonarqube") }
end

execute 'changing owner' do
  command 'chown -R sonarqube:sonarqube /opt/sonarqube-6.7.1'
  cwd '/opt'
end

execute 'changing permissions' do
  command 'chmod 777 /opt/sonarqube'
  cwd '/opt'
end

template "/opt/sonarqube/conf/sonar.properties" do
  source 'sonar.properties'
  owner 'sonarqube'
  group 'sonarqube'
  mode '0664'
  #notifies :stop, :start, 'service[sonar]', :delayed
end

template "/opt/sonarqube/bin/linux-x86-64/sonar.sh" do
  source 'sonar.sh'
  owner 'sonarqube'
  group 'sonarqube'
  mode '0755'
  #notifies :stop, :start, 'service[sonar]', :delayed
end

template "/etc/systemd/system/sonar.service" do
  source 'sonar.service'
  owner 'root'
  group 'root'
  mode '0755'
  #notifies :stop, :start, 'service[sonar]', :delayed
end

service 'sonar' do
  supports :start => true, :stop => true
  action [ :enable, :start ]
end

link '/usr/bin/sonar' do
  to '/opt/sonarqube/bin/linux-x86-64/sonar.sh'
end

template "/etc/httpd/conf.d/sonarqube.example.com.conf" do
  source 'sonarqube.example.com.conf'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[httpd]', :delayed
end

service 'httpd' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
