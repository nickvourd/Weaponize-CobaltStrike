#!/bin/bash

cat << 'EOF'
                                                                                                                                    
                                                                                                                                    
██     ██ ▄▄▄▄▄  ▄▄▄  ▄▄▄▄   ▄▄▄  ▄▄  ▄▄ ▄▄ ▄▄▄▄▄ ▄▄▄▄▄   ▄█████  ▄▄▄  ▄▄▄▄   ▄▄▄  ▄▄   ▄▄▄▄▄▄   ▄█████ ▄▄▄▄▄▄ ▄▄▄▄  ▄▄ ▄▄ ▄▄ ▄▄▄▄▄ 
██ ▄█▄ ██ ██▄▄  ██▀██ ██▄█▀ ██▀██ ███▄██ ██   ▄█▀ ██▄▄    ██     ██▀██ ██▄██ ██▀██ ██     ██     ▀▀▀▄▄▄   ██   ██▄█▄ ██ ██▄█▀ ██▄▄  
 ▀██▀██▀  ██▄▄▄ ██▀██ ██    ▀███▀ ██ ▀██ ██ ▄██▄▄ ██▄▄▄   ▀█████ ▀███▀ ██▄█▀ ██▀██ ██▄▄▄  ██     █████▀   ██   ██ ██ ██ ██ ██ ██▄▄▄ 

                                                Created with ❤ by @nickvourd                                                                                                                                                                                                                                                                                                                                                                        
EOF

set -e

OS="$(uname -s)"
UID_CHECK="$(id -u)"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "[*] Detected OS: $OS"

install_macos() {
    if [[ "$UID_CHECK" -eq 0 ]]; then
        echo "[!] Do NOT run this script with sudo on macOS."
        echo "    Homebrew must be executed as a normal user."
        exit 1
    fi

    if ! command_exists brew; then
        echo "[*] Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "[*] Updating Homebrew..."
    brew update

    if ! command_exists x86_64-w64-mingw32-gcc; then
        echo "[*] Installing mingw-w64..."
        brew install mingw-w64
    else
        echo "[+] mingw-w64 already installed"
    fi

    if ! command_exists clang; then
        echo "[*] Installing LLVM..."
        brew install llvm
    else
        echo "[+] LLVM already installed"
    fi

    LLVM_PATH="/opt/homebrew/opt/llvm/bin"
    if [[ ":$PATH:" != *":$LLVM_PATH:"* ]]; then
        echo "[*] Adding LLVM to PATH"
        echo "export PATH=\"$LLVM_PATH:\$PATH\"" >> ~/.zshrc
        export PATH="$LLVM_PATH:$PATH"
    fi
}

install_linux() {
    if [[ "$UID_CHECK" -ne 0 ]]; then
        SUDO="sudo"
    fi

    if command_exists apt; then
        $SUDO apt update
        $SUDO apt install -y mingw-w64 llvm clang

    elif command_exists dnf; then
        $SUDO dnf install -y mingw64-gcc llvm clang

    elif command_exists pacman; then
        $SUDO pacman -Sy --noconfirm mingw-w64-gcc llvm clang

    else
        echo "[!] Unsupported Linux distribution"
        exit 1
    fi
}

case "$OS" in
    Darwin)
        install_macos
        ;;
    Linux)
        install_linux
        ;;
    *)
        echo "[!] Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "[✓] Installation check completed"

echo "[*] Versions:"
command_exists x86_64-w64-mingw32-gcc && x86_64-w64-mingw32-gcc --version | head -n 1
command_exists clang && clang --version | head -n 1

# Variables
OPT_DIR="/opt"

REPO1="https://github.com/nickvourd/CS-Aggressor-Kit.git"
REPO2="https://github.com/trustedsec/CS-Remote-OPs-BOF.git"
REPO3="https://github.com/trustedsec/CS-Situational-Awareness-BOF.git"
REPO4="https://github.com/nickvourd/GetWebDAVStatus.git"
REPO5="https://github.com/outflanknl/C2-Tool-Collection.git"
REPO6="https://github.com/Nomad0x7/sekken-enum.git"
REPO7="https://github.com/CodeXTF2/ScreenshotBOF.git"
REPO8="https://github.com/CodeXTF2/WebcamBOF.git"
REPO9="https://github.com/CodeXTF2/WindowSpy.git"
REPO10="https://gtihub.com/nickvourd/COM-Hunter.git"
REPO11="https://github.com/cube0x0/LdapSignCheck.git"
REPO12="https://github.com/mertdas/PrivKit.git"
REPO13="https://github.com/leftp/RegPersist.git"
REPO14="https://github.com/Octoberfest7/Inline-Execute-PE.git"
REPO15="https://github.com/Octoberfest7/MemFiles.git"
REPO16="https://github.com/jhalon/cSessionHop.git"
REPO17="https://github.com/CCob/BOF.NET.git"
REPO18="https://github.com/netero1010/RDPHijack-BOF.git"
REPO19="https://github.com/incursi0n/ClipboardStealBOF.git"
REPO20="https://github.com/netero1010/ServiceMove-BOF.git"

clone_repo() {
    local repo_url="$1"
    local dest_dir="$2"
    local label="$3"

    echo -e "\n[+] Cloning $label..."

    if [ -d "$dest_dir" ]; then
        echo "[!] $dest_dir already exists. Removing..."
        sudo rm -rf "$dest_dir"
    fi

    sudo git clone "$repo_url" "$dest_dir"
}

clone_repo "$REPO1"  "$OPT_DIR/CS-Aggressor-Kit"                 "CS-Aggressor-Kit by @nickvourd"
clone_repo "$REPO2"  "$OPT_DIR/CS-Remote-OPs-BOF"                "CS-Remote-OPs-BOF by @TrustedSec"
clone_repo "$REPO3"  "$OPT_DIR/CS-Situational-Awareness-BOF"     "CS-Situational-Awareness-BOF by @TrustedSec"
clone_repo "$REPO4"  "$OPT_DIR/GetWebDAVStatus"                  "GetWebDAVStatus by @nickvourd"
clone_repo "$REPO5"  "$OPT_DIR/C2-Tool-Collection"               "C2-Tool-Collection by @OutflankNL"
clone_repo "$REPO6"  "$OPT_DIR/sekken-enum"                      "sekken-enum by nomad0x7"
clone_repo "$REPO7"  "$OPT_DIR/ScreenshotBOF"                    "ScreenshotBOF by @codex_tf2"
clone_repo "$REPO8"  "$OPT_DIR/WebcamBOF"                        "WebcamBOF by @codex_tf2"
clone_repo "$REPO9"  "$OPT_DIR/WindowSpy"                        "WindowSpy by @codex_tf2"
clone_repo "$REPO10" "$OPT_DIR/COM-Hunter"                       "COM-Hunter by @nickvourd"
clone_repo "$REPO11" "$OPT_DIR/LdapSignCheck"                    "LdapSignCheck by @cube0x0"
clone_repo "$REPO12" "$OPT_DIR/PrivKit"                          "PrivKit by @merterpreter"
clone_repo "$REPO13" "$OPT_DIR/RegPersist"                       "RegPersist by @lefterispan"
clone_repo "$REPO14" "$OPT_DIR/Inline-Execute-PE"                "Inline-Execute-PE by @Octoberfest73"
clone_repo "$REPO15" "$OPT_DIR/MemFiles"                         "MemFiles by @Octoberfest73"
clone_repo "$REPO16" "$OPT_DIR/cSessionHop"                      "cSessionHop by @jack_halon"
clone_repo "$REPO17" "$OPT_DIR/BOF.NET"                          "BOF.NET by @_EthicalChaos_"
clone_repo "$REPO18" "$OPT_DIR/RDPHijack-BOF"                    "RDPHijack-BOF by @netero_1010"
clone_repo "$REPO19" "$OPT_DIR/ClipboardStealBOF"                "ClipboardStealBOF by @Incursi0n"
clone_repo "$REPO20" "$OPT_DIR/ServiceMove-BOF"                  "ServiceMove-BOF by @netero_1010"

echo -e "\n[+] Done!"
