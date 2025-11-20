#!/usr/env bash

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run as root."
    exit 1
fi

# Variables
OPT_DIR="/opt"
REPO1="https://github.com/nickvourd/CS-Aggressor-Kit.git"
REPO2="https://github.com/trustedsec/CS-Remote-OPs-BOF.git"
REPO3="https://github.com/trustedsec/CS-Situational-Awareness-BOF.git"
REPO4="https://github.com/nickvourd/GetWebDAVStatus.git"
REPO5="https://github.com/outflanknl/C2-Tool-Collection.git"
REPO6="https://github.com/Nomad0x7/sekken-enum.git"

echo "[+] Cloning CS-Aggressor-Kit by @nickvourd..."
git clone "$REPO1" "$OPT_DIR/CS-Aggressor-Kit"

echo "[+] Cloning CS-Remote-OPs-BOF by @TrustedSec..."
git clone "$REPO2" "$OPT_DIR/CS-Remote-OPs-BOF"

echo "[+] Cloning CS-Situational-Awareness-BOF by @TrustedSec..."
git clone "$REPO3" "$OPT_DIR/CS-Situational-Awareness-BOF"

echo "[+] Cloning GetWebDAVStatus by @nickvourd..."
git clone "$REPO4" "$OPT_DIR/GetWebDAVStatus"

echo "[+] Cloning C2-Tool-Collection by @OutflankNL..."
git clone "$REPO5" "$OPT_DIR/C2-Tool-Collection"

echo "[+] Cloning sekken-enum by Nomad0x7..."
git clone "$REPO6" "$OPT_DIR/sekken-enum"

echo "[+] Setting permissions for make_all.sh of CS-Remote-OPs-BOF..."
chmod +x "$OPT_DIR/CS-Remote-OPs-BOF/make_all.sh"

echo "[+] Setting permissions for make_all.sh of CS-Situational-Awareness-BOF..."
chmod +x "$OPT_DIR/CS-Situational-Awareness-BOF/make_all.sh"

echo "[+] Done!"

