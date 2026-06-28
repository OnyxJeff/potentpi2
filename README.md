# potentpi2

![Build Status](https://github.com/OnyxJeff/potentpi2/actions/workflows/build.yml/badge.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2026.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![GitHub release](https://img.shields.io/github/v/release/OnyxJeff/potentpi2)
![Issues](https://img.shields.io/github/issues/OnyxJeff/potentpi2)

**Mimir** is the Monitoring server for my homelab, hosted on a Raspberry Pi 4.

## 📁 Repo Structure

```text
potentpi2/
├── .github/workflows/      # CI for YAML validation
├── backup_logs/            # Oldest logs from update script
├── docker/                 # Docker container(s) for Network Monitoring
├── images/                 # Images for README files
├── logs/                   # Most recent update script logs
├── scripts/                # Auto-Updater script for RPi (can be associated with cronjob)
├── U6143_ssd1306/          # Python, C code, and script for UCTronics display screen
└── README.md               # You're reading it!
```

---

## 🧰 Services

  - **UniFi Controller**: Manages UniFi network devices and monitors network performance.

---

## 📝 Preparation

  - Install GIT (app used to download this repo onto your device)
  ```bash
  sudo apt install git -y
  ```

  - Download repo
  ```bash
  cd
  git clone https://github.com/OnyxJeff/potentpi2.git
  ```
---

## 🖥️ Installing U6143_ssd1306 Display

- Launch Raspi-Config
```bash
sudo raspi-config
```
Choose Interface Options Enable i2c

- Run setup_display_service.sh script
```bash
cd ~/potentpi2/U6143_ssd1306
chmod +x setup_display_service.sh
sudo ./setup_display_service.sh
```

- Custom display temperature type
  - Open the U6143_ssd1306/C/ssd1306_i2c.h file. You can modify the value of the TEMPERATURE_TYPE variable to change the type of temperature displayed. (The default is Fahrenheit)
  ![Select Temperature](images/select_temperature.jpg)

- Custom display IPADDRESS_TYPE type
  - Open the U6143_ssd1306/C/ssd1306_i2c.h file. You can modify the value of the IPADDRESS_TYPE variable to change the type of IP displayed. (The default is ETH0)
  ![Select IP](images/select_ip.jpg)

- Custom display information
  - Open the U6143_ssd1306/C/ssd1306_i2c.h file. You can modify the value of the IP_SWITCH variable to determine whether to display the IP address or custom information. (The custom IP address is displayed by default)
  ![Custom Display](images/custom_display.jpg)

> [!Note]
> I did rewrite the initial install script to be more repo friendly.

---

## ⚠️ Updating the OS

- Make the log folder for updates
```bash
mkdir ~/potentpi2/logs
mkdir ~/potentpi2/backup_logs
```

- Update and Upgrade the System via script:
```bash
cd ~/potentpi2/scripts
chmod +x apt-get-autoupdater.sh
sudo ./apt-get-autoupdater.sh
```
It's going to look like this froze, but just let it go.

- Start CronJob (optional but recommended if doing headless/always on installation)
```bash
sudo crontab -e
```

  - add the following to the bottom of the document:
  ```bash
  # OS-Auto-Updater
    00 01 * * 0 bash $HOME/potentpi2/scripts/apt-get-autoupdater.sh
      # execute automatic update script and log every sunday at 01:00 am
    50 00 1 * * /bin/bash -c 'cp $HOME/potentpi2/logs/apt-get-autoupdater.log $HOME/potentpi2/backup_logs/apt-get-autoupdater-$(date +\%Y\%m\%d).log'
      # saves monthly version of "apt-get-autoupdater.log" on the 1st of every month at 00:50 am
    51 00 1 * * rm -f $HOME/potentpi2/logs/apt-get-autoupdater.log
      # deletes old weekly log on the 1st of every month at 00:51 am
  ```

---

## 📦 Installing Docker Compose

- Install Docker
```bash
cd
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

- Add User to Docker Group
```bash
sudo usermod -aG docker $USER
```

> [!IMPORTANT]
> After running this command you will need to log out and log back in (or I recommend just rebooting) for the changes to take effect.

- Install Docker Compose:
```bash
sudo apt install docker-compose-plugin
```

- Verify Installation:
```bash
docker run hello-world
docker compose version
```

### 📝 Installing your first container(s)

- Installing Container Stack (via script)
```bash
cd ~/potentpi2/scripts
chmod +x docker-up-all.sh
./docker-up-all.sh
```

---

## Acknowledgements

This project uses or is inspired by the following repositories:

- [U6143_ssd1306](https://github.com/UCTRONICS/U6143_ssd1306) – Provides the C display code used in the systemd service setup.
- [UniFi-RPi](https://github.com/ryansch/docker-unifi-rpi) - UniFi Controller for Raspberry Pi.
- [Dockprom](https://github.com/stefanprodan/dockprom) – Used for Docker-based Prometheus monitoring and metrics collection.

---

📬 Maintained By
Jeff M. • [@OnyxJeff](https://www.github.com/onyxjeff)