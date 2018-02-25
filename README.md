# SonarQube-Chef.io to Automate
Install and uninstall SonarQube on Centos7 


Install And  Configure Sonarqube On Linux
Setup Sonarqube MYSQL Database
1. Install wget
1
sudo yum install wget -y
2. Add mysql repositor, install and update it.
1
2
3
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
sudo yum update -y
3. Install MySQL server.
1
sudo yum install mysql-server

Add Mysql to the log group
1
Usermod mysql –aG logs
Cat /etc/group | grep logs
4. Start MySQL service.
1
sudo systemctl start mysqld
Change MSQL Root Password
1
systemctl is-active msql

If the above command doesn’t return active as output or its stopped, you willk need to restart the data base before proceeding.
systemctl start mysql.service 
5. Set Mysql password for you MYSQL instance using the following command. The command will prompt for current root password, you can hit enter as there is no default password. All the other prompts are self-explanatory.
1
sudo mysql_secure_installation
6. Login using MySQL client and check the MySQL engine using the following commands. The storage engine should be InnoDB.
1
2
Switch to the MSQL  shell
mysql -u root -p

For compatibily across versions, we will use the following statement to update the user table in the mysql database.
NB: you need to replace “YourPasswordHere” with the new password you have chosen for root.
1
2
USE mysql;
UPDATE user SET password=PASSWORD(‘YourPasswordHere’)WHERE User=‘root’ AND host = ‘localhost’;
FLUSH PRIVILEGES;
Msql



7. Create a sonarqube user and a database from MySQL CLI.
1
2
CREATE USER 'sonarqube'@'localhost' IDENTIFIED BY 'password';
CREATE DATABASE sonarqube;
8. Grant all privileges on sonarqube database to the sonarqube user.
1
GRANT ALL PRIVILEGES ON sonarqube.* TO 'sonarqube'@'localhost';
9. Open /etc/my.cnf file and under [mysqld] section add the query cache parameter. The minimum size should be 15 MB. You can increase the size based on your server type.
1
query_cache_size = 15M
 ==Ctr +D to get out from the shell
Setup Sonarcube Web Server
1. Download the latest sonarqube installation file to /opt folder. You can get the latest download link from here. http://www.sonarqube.org/downloads/
1
2
cd ~
sudo wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.6.zip 
mv sonarqube-6.6.zip /opt
cd /opt 

2. Install unzip and java.
1
2
sudo yum install unzip -y
sudo yum install java-1.8.0-openjdk -y
3. Unzip sonarqube source files and rename the folder.
1
2
sudo unzip sonarqube-6.6.zip
mv sonarqube-6.6 sonarqube
Perrmissions to edit sonarqube config file and change ownership of sonarqube
1
2
sudo chown –R <user>sonarqube/ 
4. Open /opt/sonarqube/conf/sonar.properties, uncomment and edit the parameters as shown below. Change the password accordingly.
1
2
3
cd sonarqube
sudo vi conf/sonar.properties 
sonar.jdbc.username=sonarqube                                                                                                                     
sonar.jdbc.password=password
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube?useUnicode=true&amp;characterEncoding=utf8&amp;rewriteBatchedStatements=true&amp;useConfigs=maxPerformance 
By default, sonar will run on 9000. If you want on port 80 or any other port,change the following parameters for accessing the web console on that specific port.
1
2
sonar.web.host=0.0.0.0
sonar.web.port=80
If you want to access sonarqube some path like http://url:/sonar, change the following parameter.

1
sonar.web.context=/sonar
Start Sonarqube Service
To start sonar service, you need to use the script in sonarqube bin directory.
1. Navigate to the start script directory.
1
 cd /opt/sonarqube/bin/linux-x86-64
2. Start the sonarqube service.
1
sudo ./sonar.sh start
3.Check the application status. If it is in running state, you can access the sonarqube dashboard using the DNS name or Ip address of your server.
1
sudo ./sonar.sh start
Setting Up Sonarcube As A Service
1. Create a file /etc/systemd/system/sonar.service  and copy the following content on to the file.

$ sudo vi /etc/systemd/system/sonar.service
Populate the file with:
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target

2. Now, create a symbolic link for /usr/bin/sonar with out sonarqube start scripts in the source file directory. i.e /opt/sonarqube/bin/linux-x86-64
1
sudo ln -s /opt/sonarqube/bin/linux-x86-64/sonar.sh /usr/bin/sonar
3. Change the file permissions and add sonar to the boot.
1
2
sudo chmod 755 /etc/systemd/sonar
sudo chkconfig --add sonar
4. Once you are done with all the above configurations, you can manage sonar using the following commands.
1
2
3
sudo systemctl start sonar 
sudo systemctl stop sonar 
sudo systemctl  enable  sonar 
To check if the service is running, run:
1
2
sudo systemctl status sonar

Step 5: Configure reverse proxy
By default, SonarQube listens to localhost on port 9000. In this tutorial, we will use Apache as the reverse proxy so that the application can be accessed via the standard HTTP port. Install the Apache web server by running:
1
2
sudo yum -y install httpd

Create a new virtual host.
1
2
sudo vi /etc/httpd/conf.d/sonar.yourdomain.com.conf

Populate the file with:
1
2
<VirtualHost *:80>  
    ServerName sonar.yourdomain.com
    ServerAdmin me@yourdomain.com
    ProxyPreserveHost On
    ProxyPass / http://localhost:9000/
    ProxyPassReverse / http://localhost:9000/
    TransferLog /var/log/httpd/sonar.yourdomain.com_access.log
    ErrorLog /var/log/httpd/sonar.yourdomain.com_error.log
</VirtualHost>

Start Apache and enable it to start automatically at boot time:
1
2
sudo systemctl start httpd
sudo systemctl enable httpd

Step 6: Configure firewall
Allow the required HTTP port through the system firewall.
1
2
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

Start the SonarQube service:
1
2
sudo systemctl start sonar

You will also need to disable SELinux:
1
2
sudo setenforce 0


SonarQube is installed on your server, access the dashboard at the following address.
1
2

http://sonar.yourdomain.com



