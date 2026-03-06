#!/bin/bash
# ==========================================================
# Ubuntu Full Setup Script (NTFS Support)
# ==========================================================
# Flatpak-enabled, DNS 1.1.1.1, UFW active
# Dev tools: Coretto21 JDK, .NET 9/10 SDK & Runtime, VS Code, Node.js, Python 3
# Test & Automation: JMeter, Docker + Compose
# Design: GIMP, Krita, Darktable, draw.io
# Business & Data apps: Postman, Zoom, Teams, DBeaver, FileZilla, Thunderbird
# Browsers: Firefox, Google Chrome, Brave
# Remote Desktop: Remmina, AnyDesk, Gnome Network Displays
# ==========================================================

echo "=== 🚀 Starting Snap-Free Ubuntu Full Setup ==="

# 1️⃣ System Update
echo "[1/27] Updating system..."
sudo apt update && sudo apt upgrade -y

# 2️⃣ Base Dependencies + NTFS Support
echo "[2/27] Installing base dependencies..."
sudo apt install -y \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  filezilla \
  ntfs-3g

# 3️⃣ Enable UFW Firewall
echo "[3/27] Enabling UFW firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw --force enable

# 4️⃣ Configure DNS (Cloudflare)
echo "[4/27] Configuring DNS 1.1.1.1..."
sudo bash -c 'cat > /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=9.9.9.9
EOF'
sudo systemctl restart systemd-resolved

# 5️⃣ Flatpak + Flathub
echo "[5/27] Installing Flatpak..."
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 6️⃣ Core Apps
echo "[6/27] Installing core apps..."
sudo apt install -y libreoffice vlc gnome-tweaks

# 7️⃣ Amazon Corretto 21 (JDK)
echo "[7/27] Installing Amazon Corretto 21..."
wget -O- https://apt.corretto.aws/corretto.key | sudo tee /etc/apt/trusted.gpg.d/corretto.asc
sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
sudo apt update
sudo apt install -y java-21-amazon-corretto-jdk

# 8️⃣ Microsoft Repo (for .NET & VS Code)
echo "[8/27] Adding Microsoft repository..."
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update

# 9️⃣ .NET 9 SDK + Runtime
# echo "[9/27] Installing .NET 9 SDK & Runtime..."
# sudo apt install -y dotnet-sdk-9.0 dotnet-runtime-9.0 aspnetcore-runtime-9.0

# 🔟 .NET 10 SDK + Runtime
echo "[10/27] Installing .NET 10 SDK & Runtime..."
sudo apt install -y dotnet-sdk-10.0 dotnet-runtime-10.0 aspnetcore-runtime-10.0 || echo "⚠️ .NET 10 not available in repo for this Ubuntu version."

# 1️⃣1️⃣ VS Code
echo "[11/27] Installing VS Code..."
sudo snap install code --classic

# 1️⃣2️⃣ Docker + Compose
echo "[12/27] Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker
sudo apt install -y docker-compose-plugin

# 1️⃣3️⃣ Node.js (LTS)
echo "[13/27] Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# 1️⃣4️⃣ Python 3
echo "[14/27] Installing Python..."
sudo apt install -y python3 python3-pip python3-venv

# 1️⃣5️⃣ Apache JMeter
echo "[15/27] Installing Apache JMeter..."
JMETER_VERSION="5.6.2"
sudo mkdir -p /opt/jmeter
wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz -O /tmp/apache-jmeter.tgz
sudo tar -xzf /tmp/apache-jmeter.tgz -C /opt/jmeter --strip-components=1
sudo ln -sf /opt/jmeter/bin/jmeter /usr/local/bin/jmeter
rm /tmp/apache-jmeter.tgz

# 1️⃣6️⃣ Design Tools
echo "[16/27] Installing design tools..."
sudo apt install -y gimp krita darktable

# 1️⃣7️⃣ Snap Firefox & Thunderbird Kaldır
echo "[17/27] Removing Snap versions of Firefox & Thunderbird..."
# sudo snap remove firefox thunderbird || echo "No Snap versions found."

# 1️⃣8️⃣ Install Firefox & Thunderbird via APT
echo "[18/27] Installing Firefox & Thunderbird via APT..."
sudo apt update
# sudo apt install -y firefox thunderbird

# 1️⃣9️⃣ Google Chrome
echo "[19/27] Installing Google Chrome..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo dpkg -i /tmp/chrome.deb || sudo apt install -f -y
rm /tmp/chrome.deb

# 2️⃣0️⃣ Brave Browser
echo "[20/27] Installing Brave..."
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] \
https://brave-browser-apt-release.s3.brave.com/ stable main" | \
sudo tee /etc/apt/sources.list.d/brave-browser.list
sudo apt update
sudo apt install -y brave-browser

# 2️⃣1️⃣ Remote Desktop Tools: Remmina, AnyDesk Gnome Network Displays
echo "[21/27] Installing Remote Desktop Apps..."
sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-secret

# AnyDesk (modern keyring method)
curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | gpg --dearmor | sudo tee /usr/share/keyrings/anydesk-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/anydesk-archive-keyring.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk.list
sudo apt update
sudo apt install -y anydesk

# GNOME Network Display
flatpak install -y flathub org.gnome.NetworkDisplays

sudo ufw allow 7236/tcp
sudo ufw allow 5353/udp
sudo ufw reload

# 2️⃣2️⃣ Business Apps (Flatpak)
echo "[22/27] Installing business apps..."
flatpak install -y flathub \
com.getpostman.Postman \
com.microsoft.Teams \
io.dbeaver.DBeaverCommunity \
com.jgraph.drawio.desktop

# 2️⃣3️⃣ Printer Support
echo "[23/27] Installing printer support..."
sudo apt install -y cups printer-driver-gutenprint system-config-printer
sudo systemctl restart cups

# 2️⃣4️⃣ Cleanup
echo "[24/27] Cleaning up..."
sudo apt autoremove -y

# 2️⃣5️⃣ Verify .NET
echo "[25/27] Verifying .NET installation..."
dotnet --list-sdks
dotnet --list-runtimes

# 2️⃣6️⃣ Optional Shortcuts
echo "[26/27] Ensuring Flatpak apps appear in GNOME menu..."
flatpak update --appstream -y
sudo update-desktop-database

# 2️⃣7️⃣ End
echo "[27/27] Script fully finished!"
echo "All tools installed and ready to use."
echo "⚠️ Logout/Login required for Docker, Flatpak, Remmina, AnyDesk & GNOME Wired Desktop."






