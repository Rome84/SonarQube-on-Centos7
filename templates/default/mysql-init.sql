CREATE USER '<%= node['sonarqube']['dbuser'] -%>'@'localhost' IDENTIFIED BY '<%= node['sonarqube']['dbpassword'] -%>';
CREATE DATABASE <%= node['sonarqube']['db'] -%>;
GRANT ALL PRIVILEGES ON <%= node['sonarqube']['db'] -%>.* TO '<%= node['sonarqube']['dbuser'] -%>'@'localhost';
