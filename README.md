# Guacamole Auto Install Script

This repository contains an automated installation script for setting up Guacamole with Tomcat, MySQL, and Guacamole Server on an Ubuntu server.

## Features

- Automates the installation of Tomcat 9
- Installs and configures MySQL for Guacamole
- Configures Guacamole server with Tomcat
- Prompts for MySQL and Guacamole settings (with default values)
- Handles installation failures and exits gracefully

## Fetch the Install Script

To fetch the latest version of the `guac-autoinstall.sh` script, run the following command:

```bash
wget https://raw.githubusercontent.com/KevinRexFromDk/guacamole/refs/heads/main/guac-autoinstall.sh -O guac-autoinstall.sh
