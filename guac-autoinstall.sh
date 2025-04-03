#!/bin/bash

# Function to add a short delay for each operation
sleep_duration=1  # Adjust sleep duration (in seconds) between commands

# Function to handle errors
handle_error() {
    echo -e "\e[31mError: $1\e[0m"  # Print error in red
    exit 1  # Exit the script with an error status
}

# Prompt for MySQL password
read -p "Enter MySQL password (default 'Passw0rd'): " mysqlPwd
mysqlPwd=${mysqlPwd:-Passw0rd}  # Default to 'Passw0rd' if no input is given
echo -e "\e[34mMySQL Password: $mysqlPwd\e[0m"

# Prompt for Guacamole password
read -p "Enter Guacamole password (default 'Passw0rd'): " guacPwd
guacPwd=${guacPwd:-Passw0rd}  # Default to 'Passw0rd' if no input is given
echo -e "\e[34mGuacamole Password: $guacPwd\e[0m"

# Prompt for Guacamole database name
read -p "Enter Guacamole database name (default 'guac_db'): " guacDb
guacDb=${guacDb:-guac_db}  # Default to 'guac_db' if no input is given
echo -e "\e[34mGuacamole Database: $guacDb\e[0m"

# Prompt for Guacamole username
read -p "Enter Guacamole username (default 'guacadmin'): " guacUser
guacUser=${guacUser:-guacadmin}  # Default to 'guacadmin' if no input is given
echo -e "\e[34mGuacamole User: $guacUser\e[0m"

# Update and upgrade the system
echo -e "\e[34mUpdating and upgrading the system...\e[0m"
sudo apt-get update -y && sudo apt-get upgrade -y || handle_error "System update/upgrade failed."
sleep $sleep_duration

# Install OpenJDK 11
echo -e "\e[34mInstalling OpenJDK 11...\e[0m"
sudo apt-get install openjdk-11-jdk -y || handle_error "OpenJDK 11 installation failed."
sleep $sleep_duration

# Download and install Tomcat 9 (with quiet flag to suppress output)
echo -e "\e[34mDownloading Tomcat 9...\e[0m"
wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.102/bin/apache-tomcat-9.0.102.tar.gz || handle_error "Tomcat download failed."
sleep $sleep_duration

echo -e "\e[34mInstalling Tomcat 9...\e[0m"
sudo mkdir /etc/tomcat9 || handle_error "Failed to create Tomcat directory."
sudo tar -xvzf apache-tomcat-9.0.102.tar.gz -C /etc/tomcat9 || handle_error "Failed to extract Tomcat files."
sudo mv /etc/tomcat9/apache-tomcat-9.0.102/* /etc/tomcat9 || handle_error "Failed to move Tomcat files."
sudo rm -rf /etc/tomcat9/apache-tomcat-9.0.102 || handle_error "Failed to remove extracted files."
sudo rm -f apache-tomcat-9.0.102.tar.gz || handle_error "Failed to remove Tomcat tar file."
sleep $sleep_duration

# Download and place the systemd service file for Tomcat9
echo -e "\e[34mDownloading systemd service file for Tomcat9...\e[0m"
wget -q https://raw.githubusercontent.com/KevinRexFromDk/guacamole/refs/heads/main/tomcat9.service -O /etc/systemd/system/tomcat9.service || handle_error "Failed to download tomcat9.service file."
sleep $sleep_duration

# Start and enable Tomcat9 service
echo -e "\e[34mStarting and enabling Tomcat9 service...\e[0m"
sudo systemctl start tomcat9 || handle_error "Failed to start Tomcat service."
sudo systemctl enable tomcat9 || handle_error "Failed to enable Tomcat service."
sleep $sleep_duration

# Download and prepare Guacamole installation script
echo -e "\e[34mDownloading Guacamole installation script...\e[0m"
wget -q https://git.io/fxZq5 -O guac-install.sh || handle_error "Guacamole installation script download failed."
chmod +x guac-install.sh || handle_error "Failed to make Guacamole script executable."
sleep $sleep_duration

# Modify guac-install.sh as needed
echo -e "\e[34mModifying Guacamole installation script...\e[0m"
sed -i '/if \[\[ $( apt-cache show tomcat9 /,/^fi$/d' guac-install.sh || handle_error "Failed to modify Guacamole installation script."
sed -i 's/^#TOMCAT=""/TOMCAT=tomcat9/' guac-install.sh || handle_error "Failed to set TOMCAT variable in script."
sed -i '/${MYSQL} ${LIBJAVA} ${TOMCAT} &>> ${LOG}/c\${MYSQL} ${LIBJAVA} &>> ${LOG}' guac-install.sh || handle_error "Failed to modify MySQL, LIBJAVA, TOMCAT logging in script."
sed -i 's|ln -sf /etc/guacamole/guacamole.war /var/lib/${TOMCAT}/webapps/|ln -sf /etc/guacamole/guacamole.war /etc/${TOMCAT}/webapps/|' guac-install.sh || handle_error "Failed to update the ln command in script."
sleep $sleep_duration

# Run Guacamole installation script
echo -e "\e[34mRunning Guacamole installation script...\e[0m"
sudo ./guac-install.sh --mysqlpwd $mysqlPwd --guacpwd $guacPwd --guacdb $guacDb --guacuser $guacUser --nomfa --installmysql
sleep $sleep_duration

# Success message
echo -e "\e[32mInstallation completed successfully!\e[0m"

# Cleanup
echo -e "\e[34mCleaning up...\e[0m"
sudo rm -f apache-tomcat-9.0.102.*
sudo rm -f guac-install.sh
sudo rm -f guac-autoinstall.sh
echo -e "\e[32mCleanup completed successfully!\e[0m"
