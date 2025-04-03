#!/bin/bash

# Update and upgrade the system
sudo apt-get update && sudo apt-get upgrade -y

# Install OpenJDK 11
sudo apt-get install openjdk-11-jdk -y

# Download and install Tomcat 9
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.102/bin/apache-tomcat-9.0.102.tar.gz
sudo mkdir /etc/tomcat9
sudo tar -xvzf apache-tomcat-9.0.102.tar.gz -C /etc/tomcat9
sudo mv /etc/tomcat9/apache-tomcat-9.0.102/* /etc/tomcat9
sudo rm -rf /etc/tomcat9/apache-tomcat-9.0.102
sudo rm -f apache-tomcat-9.0.102.tar.gz

# Set Java alternatives
update-java-alternatives -l

# Create and edit systemd service for Tomcat9
sudo bash -c 'cat > /etc/systemd/system/tomcat9.service << EOF
[Unit]
Description=Apache Tomcat 9
After=syslog.target network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
Environment=CATALINA_PID=/etc/tomcat9/temp/tomcat.pid
Environment=CATALINA_HOME=/etc/tomcat9/
Environment=CATALINA_BASE=/etc/tomcat9/
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"
WorkingDirectory=/etc/tomcat9/
ExecStart=/etc/tomcat9/bin/startup.sh
ExecStop=/etc/tomcat9/bin/shutdown.sh
User=root
Group=root
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Start and enable Tomcat9 service
sudo systemctl start tomcat9
sudo systemctl enable tomcat9
sudo systemctl status tomcat9

# Download and prepare Guacamole installation script
wget https://git.io/fxZq5 -O guac-install.sh
chmod +x guac-install.sh

# Modify guac-install.sh as needed
sed -i '/if \[\[ $( apt-cache show tomcat9 /,/^fi$/d' guac-install.sh
sed -i 's/^#TOMCAT=""/TOMCAT=tomcat9/' guac-install.sh
sed -i '/${MYSQL} ${LIBJAVA} ${TOMCAT} &>> ${LOG}/c\${MYSQL} ${LIBJAVA} &>> ${LOG}' guac-install.sh
sed -i 's|ln -sf /etc/guacamole/guacamole.war /var/lib/${TOMCAT}/webapps/|ln -sf /etc/guacamole/guacamole.war /etc/${TOMCAT}/webapps/|' guac-install.sh

# Run Guacamole installation script
sudo ./guac-install.sh --mysqlpwd Passw0rd --guacpwd Passw0rd --guacdb guac_db --guacuser guac --nomfa --installmysql