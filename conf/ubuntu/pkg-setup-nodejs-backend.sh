cd ~

sudo apt -y update
sudo apt -y upgrade

sudo apt -y install ca-certificates curl gnupg

# Node environment
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
source "$HOME/.bashrc"

sudo nvm install --lts
sudo apt -y install npm
npm i -g nodemon
npm i -g pm2

# MySQL
sudo apt -y install mysql-server

# DOCKER
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt -y remove $pkg; done
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt -y update
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# FirewallD
sudo apt -y install firewalld
sudo systemctl stop firewalld

sudo systemctl stop ufw

sudo apt install net-tools
