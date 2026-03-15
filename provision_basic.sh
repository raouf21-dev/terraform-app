#!/bin/bash

set -e 

 Run the script in non-interactive mode so that the installation does not 
# prompt for input
export DEBIAN_FRONTEND=noninteractive

# Install required packages
apt-get update
apt-get install -y ca-certificates curl sqlite3 apache2-utils

# Setup Docker

## Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
