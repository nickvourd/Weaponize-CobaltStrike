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
OPT_DIR="/opt"

REPO1="https://github.com/nickvourd/CS-Aggressor-Kit.git"
REPO2="https://github.com/trustedsec/CS-Remote-OPs-BOF.git"
REPO3="https://github.com/trustedsec/CS-Situational-Awareness-BOF.git"
REPO4="https://github.com/nickvourd/GetWebDAVStatus.git"
REPO5="https://github.com/outflanknl/C2-Tool-Collection.git"
REPO6="https://github.com/Nomad0x7/sekken-enum.git"
REPO7="https://github.com/CodeXTF2/WebcamBOF.git"
REPO8="https://github.com/nickvourd/COM-Hunter.git"
REPO9="https://github.com/mertdas/PrivKit.git"
REPO10="https://github.com/leftp/RegPersist.git"

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

run_as_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

usage() {
    echo "Usage: $0 {install|clean|cna}"
    echo
    echo "  install   Install dependencies, clone repos, and compile everything"
    echo "  clean     Delete everything under /opt except /opt/homebrew"
    echo "  cna       Find all .cna files under /opt; if none exist, run install"
    exit 1
}

install_macos() {
    if [[ "$UID_CHECK" -eq 0 ]]; then
        echo "[!] Do NOT run the full script with sudo on macOS."
        echo "    Homebrew should run as a normal user."
        exit 1
    fi

    if ! command_exists brew; then
        echo "[*] Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "[*] Updating Homebrew..."
    brew update

    if ! command_exists git; then
        echo "[*] Installing git..."
        brew install git
    else
        echo "[+] git already installed"
    fi

    if ! command_exists make; then
        echo "[*] Installing make..."
        brew install make
    else
        echo "[+] make already installed"
    fi

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
        echo "[*] Adding LLVM to PATH for current session"
        export PATH="$LLVM_PATH:$PATH"
        echo "[*] You may also want to add this to ~/.zshrc:"
        echo "    export PATH=\"$LLVM_PATH:\$PATH\""
    fi
}

install_linux() {
    local SUDO=""
    if [[ "$UID_CHECK" -ne 0 ]]; then
        SUDO="sudo"
    fi

    if command_exists apt; then
        $SUDO apt update
        $SUDO apt install -y git make mingw-w64 llvm clang
    elif command_exists dnf; then
        $SUDO dnf install -y git make mingw64-gcc llvm clang
    elif command_exists pacman; then
        $SUDO pacman -Sy --noconfirm git make mingw-w64-gcc llvm clang
    else
        echo "[!] Unsupported Linux distribution"
        exit 1
    fi
}

install_dependencies() {
    echo "[*] Detected OS: $OS"

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

    echo "[+] Installation check completed"
    echo "[*] Versions:"
    command_exists x86_64-w64-mingw32-gcc && x86_64-w64-mingw32-gcc --version | head -n 1
    command_exists clang && clang --version | head -n 1
    command_exists make && make --version | head -n 1
    command_exists git && git --version
}

clone_repo() {
    local repo_url="$1"
    local dest_dir="$2"
    local label="$3"

    echo
    echo "[+] Cloning $label..."

    if [ -d "$dest_dir" ]; then
        echo "[!] $dest_dir already exists. Removing..."
        run_as_root rm -rf "$dest_dir"
    fi

    run_as_root git clone "$repo_url" "$dest_dir"
}

clone_repos() {
    clone_repo "$REPO1"  "$OPT_DIR/CS-Aggressor-Kit"             "CS-Aggressor-Kit by @nickvourd"
    clone_repo "$REPO2"  "$OPT_DIR/CS-Remote-OPs-BOF"            "CS-Remote-OPs-BOF by @TrustedSec"
    clone_repo "$REPO3"  "$OPT_DIR/CS-Situational-Awareness-BOF" "CS-Situational-Awareness-BOF by @TrustedSec"
    clone_repo "$REPO4"  "$OPT_DIR/GetWebDAVStatus"              "GetWebDAVStatus by @nickvourd"
    clone_repo "$REPO5"  "$OPT_DIR/C2-Tool-Collection"           "C2-Tool-Collection by @OutflankNL"
    clone_repo "$REPO6"  "$OPT_DIR/sekken-enum"                  "sekken-enum by nomad0x7"
    clone_repo "$REPO7"  "$OPT_DIR/WebcamBOF"                    "WebcamBOF by @codex_tf2"
    clone_repo "$REPO8"  "$OPT_DIR/COM-Hunter"                   "COM-Hunter by @nickvourd"
    clone_repo "$REPO9"  "$OPT_DIR/PrivKit"                      "PrivKit by @merterpreter"
    clone_repo "$REPO10" "$OPT_DIR/RegPersist"                   "RegPersist by @lefterispan"

    echo
    echo -e "[+] Cloning complete\n"
}

compile_all() {
    echo "[+] Compile BOFs..."

    if [ -d "$OPT_DIR/CS-Remote-OPs-BOF" ]; then
        cd "$OPT_DIR/CS-Remote-OPs-BOF"
        run_as_root bash make_all.sh
    else
        echo "[!] Missing: $OPT_DIR/CS-Remote-OPs-BOF"
    fi

    if [ -d "$OPT_DIR/CS-Situational-Awareness-BOF" ]; then
        cd "$OPT_DIR/CS-Situational-Awareness-BOF"
        run_as_root bash make_all.sh
    else
        echo "[!] Missing: $OPT_DIR/CS-Situational-Awareness-BOF"
    fi

    if [ -d "$OPT_DIR/COM-Hunter" ]; then
        cd "$OPT_DIR/COM-Hunter/BOF"
        run_as_root bash make_all.sh
    else
        echo "[!] Missing: $OPT_DIR/COM-Hunter"
    fi

    if [ -d "$OPT_DIR/PrivKit" ]; then
        cd "$OPT_DIR/PrivKit"
        run_as_root bash make_all.sh
    else
        echo "[!] Missing: $OPT_DIR/PrivKit"
    fi

    if [ -d "$OPT_DIR/GetWebDAVStatus/GetWebDAVStatus_BOF/Source" ]; then
        cd "$OPT_DIR/GetWebDAVStatus/GetWebDAVStatus_BOF/Source"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/GetWebDAVStatus/GetWebDAVStatus_BOF/Source"
    fi

    if [ -d "$OPT_DIR/sekken-enum/src" ]; then
        cd "$OPT_DIR/sekken-enum/src"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/sekken-enum"
    fi

    if [ -d "$OPT_DIR/WebcamBOF" ]; then
        cd "$OPT_DIR/WebcamBOF"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/WebcamBOF"
    fi

    if [ -d "$OPT_DIR/RegPersist" ]; then
        cd "$OPT_DIR/RegPersist"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/RegPersist"
    fi

    if [ -d "$OPT_DIR/C2-Tool-Collection/BOF" ]; then
        cd "$OPT_DIR/C2-Tool-Collection/BOF"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/C2-Tool-Collection"
    fi

    echo
    echo "[+] Done!"

    find_cna_internal
}

find_cna_internal() {
    echo
    echo "[+] Searching for CNA files..."

    CNA_FILES=$(find /opt -type f -name "*.cna" 2>/dev/null)

    if [[ -z "$CNA_FILES" ]]; then
        return 1
    else
        echo "[+] CNA files found:"
        echo "$CNA_FILES" | sort
        echo
        return 0
    fi
}

find_cna() {
    if ! find_cna_internal; then
        echo "[!] No CNA files found under /opt"
        echo -e "[!] Please Run install Command...\n"
    fi
}

do_install() {
    install_dependencies
    clone_repos
    compile_all
}

do_clean() {
    echo "[*] Cleaning up /opt (except /opt/homebrew)..."
    run_as_root find /opt -maxdepth 1 -mindepth 1 -type d ! -name homebrew -exec rm -rf {} +
    echo -e "[+] Cleanup complete\n"
}

case "$1" in
    install)
        do_install
        ;;
    clean)
        do_clean
        ;;
    cna)
        find_cna
        ;;
    *)
        usage
        ;;
esac