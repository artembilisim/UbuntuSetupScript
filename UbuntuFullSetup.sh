#!/bin/bash
# Ubuntu Setup Script
# Snap-free, Bloatware-clean, Flatpak-enabled, Telemetry-disabled, DNS 1.1.1.1, UFW active
# Dev tools: Coretto21 JDK, .NET 9 SDK/Runtime, VS Code, Node.js, Python 3
# Test & Automation: JMeter, Docker + Compose
# Design: GIMP, Krita, Darktable
# Business & Data apps: Postman, Zoom, Teams, DBeaver, FileZilla
# Browsers: Firefox, Google Chrome, Brave

echo "=== Starting Ubuntu Full Setup ==="

# 1️⃣ Remove Snap
echo "[1/22] Removing Snap packages..."
sudo snap remove --purge firefox snap-store gnome-3-38-2004 core20 >/dev/null 2>&1
sudo apt purge -y snapd
sudo apt autoremove -y
sudo rm -rf /snap /var/snap /var/lib/snapd

# 2️⃣ Remove games and media apps
echo "[2/22] Removing bloatware games and media..."
sudo apt remove --purge -y aisleriot gnome-mahjongg gnome-mines gnome-sudoku
sudo apt remove --purge -y rhythmbox cheese totem
sudo apt autoremove -y

# 3️⃣ Disable telemetry
echo "[3/22] Disabling telemetry and crash reports..."
sudo apt purge -y ubuntu-report popularity-contest
sudo systemctl disable whoopsie apport
sudo systemctl stop whoopsie apport

# 4️⃣ Disable restricted & multiverse repos
echo "[4/22] Switching to fully open-source repositories..."
sudo sed -i 's/^deb http:\/\/.*restricted/#&/g' /etc/apt/sources.list
sudo sed -i 's/^deb http:\/\/.*multiverse/#&/g' /etc/apt/sources.list
sudo apt update -y

# 5️⃣ Flatpak and Flathub
echo "[5/22] Installing Flatpak and Flathub..."
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 6️⃣ Set DNS 1.1.1.1
echo "[6/22] Configuring DNS 1.1.1.1..."
sudo bash -c 'echo -e "[Resolve]\nDNS=1.1.1.1 1.0.0.1\nFallbackDNS=9.9.9.9" > /etc/systemd/resolved.conf'
sudo systemctl restart systemd-resolved

# 7️⃣ Enable UFW
echo "[7/22] Enabling UFW firewall..."
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 8️⃣ Remove unused packages
echo "[8/22] Removing unused dependencies..."
sudo apt autoremove -y

# 9️⃣ Install core open-source apps
echo "[9/22] Installing core open-source apps..."
sudo apt install -y libreoffice vlc gnome-tweaks wget software-properties-common apt-transport-https ca-certificates curl gnupg lsb-release filezilla

# 🔹 10️⃣ Developer Tools: Coretto21 JDK
echo "[10/22] Installing Coretto 21 JDK..."
wget -O- https://apt.corretto.aws/corretto.key | sudo tee /etc/apt/trusted.gpg.d/corretto.asc
sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
sudo apt update
sudo apt install -y java-21-amazon-corretto-jdk

# 11️⃣ .NET 9 SDK / Runtime
echo "[11/22] Installing .NET 9 SDK and Runtime..."
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-9.0
sudo apt install -y dotnet-runtime-9.0
sudo apt install -y aspnetcore-runtime-9.0

# 12️⃣ VS Code
echo "[12/22] Installing VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

# 13️⃣ Postman (Flatpak)
echo "[13/22] Installing Postman..."
flatpak install flathub com.getpostman.Postman -y

# 14️⃣ Docker & Compose
echo "[14/22] Installing Docker & Docker Compose..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker
sudo apt install -y docker-compose-plugin

# 15️⃣ Business & Data Apps (Flatpak)
echo "[15/22] Installing Zoom, Teams, DBeaver..."
flatpak install flathub us.zoom.Zoom -y
flatpak install flathub com.microsoft.Teams -y
flatpak install flathub io.dbeaver.DBeaverCommunity -y

# FileZilla already installed

# 16️⃣ JMeter
echo "[16/22] Installing Apache JMeter..."
JMETER_VERSION="5.6.2"
sudo mkdir -p /opt/jmeter
wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz -O /tmp/apache-jmeter.tgz
sudo tar -xzf /tmp/apache-jmeter.tgz -C /opt/jmeter --strip-components=1
sudo ln -s /opt/jmeter/bin/jmeter /usr/local/bin/jmeter
rm /tmp/apache-jmeter.tgz

# 17️⃣ Node.js (LTS)
echo "[17/22] Installing Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# 18️⃣ Python 3 + pip
echo "[18/22] Installing Python 3 & pip..."
sudo apt install -y python3 python3-pip python3-venv

# 19️⃣ Design tools: GIMP, Krita, Darktable
echo "[19/22] Installing Design tools..."
sudo apt install -y gimp krita darktable

# 20️⃣ Browsers: Firefox & Google Chrome
echo "[20/22] Installing Firefox & Google Chrome..."
sudo apt install -y firefox
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb
sudo dpkg -i /tmp/google-chrome.deb || sudo apt install -f -y
rm /tmp/google-chrome.deb

# 21️⃣ Brave Browser
echo "[21/22] Installing Brave Browser..."
sudo apt install -y apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser.list
sudo apt update
sudo apt install -y brave-browser

# 21️⃣ Printer Driver
echo "[22/22] Installing Printer Driver..."
sudo apt install cups printer-driver-gutenprint system-config-printer
sudo systemctl restart cups

# ✅ Completed
echo "=== Ubuntu Full Setup Complete! ==="
echo "All tools installed: Dev, Test, Design, Browsers (Firefox, Chrome, Brave), Docker, JMeter, Node.js, Python"

echo "⚠️ Note: Docker and Flatpak apps may require logging out/in to use."
