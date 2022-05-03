# bash script for upgrading the instance and setting up docker 
# (subject to modifications in event of errors)

#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certicates \
curl \
gnupg-agent \
software-properties-common &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -&&
sudo add-apt-repository "deb [arch-amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-get update -y &&
sudo apt-get docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker ubuntu

