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
REPO11="https://github.com/outflanknl/HelpColor.git"
REPO12="https://github.com/nickzer0/PersisTask-BOF.git"

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

combine_outflank_cna() {
    TARGET_DIR="$OPT_DIR/C2-Tool-Collection"
    OUTPUT_DIR="$OPT_DIR/C2-Tool-Collection/BOF"
    OUTPUT_FILE="$OUTPUT_DIR/Outflank-OpenSource.cna"

    echo
    echo "[+] Combining CNA files from C2-Tool-Collection..."

    if [ ! -d "$TARGET_DIR" ]; then
        echo "[!] Missing: $TARGET_DIR"
        return 1
    fi

    # FIX: ensure we can write
    sudo chown $(whoami) "$OUTPUT_DIR"

    > "$OUTPUT_FILE"

    CNA_FILES=$(find "$TARGET_DIR/BOF" -type f -name "*.cna" 2>/dev/null | sort)

    if [[ -z "$CNA_FILES" ]]; then
        echo "[!] No CNA files found"
        return 1
    fi

    for file in $CNA_FILES; do
        echo "[*] Adding: $file"

        {
            echo ""
            echo "# ===== FILE: $file ====="
            echo ""
            cat "$file"
            echo ""
        } >> "$OUTPUT_FILE"
    done

    echo
    echo "[+] Combined CNA saved to:"
    echo "    $OUTPUT_FILE"
    echo
}

combine_outflank_cna() {
    TARGET_DIR="$OPT_DIR/C2-Tool-Collection/BOF"
    OUTPUT_FILE="$OPT_DIR/C2-Tool-Collection/BOF/Outflank-OpenSource.cna"

    echo
    echo "[+] Combining CNA files from C2-Tool-Collection..."

    if [ ! -d "$TARGET_DIR" ]; then
        echo "[!] Missing: $TARGET_DIR"
        return 1
    fi

    CNA_FILES=$(find "$TARGET_DIR" -type f -name "*.cna" ! -name "Outflank-OpenSource.cna" 2>/dev/null | sort)

    if [[ -z "$CNA_FILES" ]]; then
        echo "[!] No CNA files found"
        return 1
    fi

    sudo truncate -s 0 "$OUTPUT_FILE"

    for file in $CNA_FILES; do
        # Extract the subdirectory name (e.g., "Klist" from "/opt/.../BOF/Klist/Klist.cna")
        subdir=$(basename $(dirname "$file"))

        echo "" | sudo tee -a "$OUTPUT_FILE" > /dev/null
        echo "# ===== FILE: $file =====" | sudo tee -a "$OUTPUT_FILE" > /dev/null
        echo "" | sudo tee -a "$OUTPUT_FILE" > /dev/null

        # Fix script_resource() paths to include subdirectory
        cat "$file" | sed "s/script_resource(\"\([^/]*\.o\)\"/script_resource(\"$subdir\/\1\"/g" | sudo tee -a "$OUTPUT_FILE" > /dev/null

        echo "" | sudo tee -a "$OUTPUT_FILE" > /dev/null
        echo "" | sudo tee -a "$OUTPUT_FILE" > /dev/null
    done

    echo "[+] Combined CNA saved to:"
    echo "    $OUTPUT_FILE"
    echo
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
    clone_repo "$REPO11" "$OPT_DIR/HelpColor"                    "HelpColor by @OutflankNL"
    clone_repo "$REPO12" "$OPT_DIR/PersisTask-BOF"                "PersisTask-BOF by @nickzer0"
    clone_repo "REPO14"  "OPT_DIR/PersisTask-BOF"                "PersisTask-BOF by @nickzer0"

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

    if [ -d "$OPT_DIR/PersisTask-BOF" ]; then
        cd "$OPT_DIR/PersisTask-BOF"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/PersisTask-BOF"
    fi


    if [ -d "$OPT_DIR/C2-Tool-Collection/BOF" ]; then
        cd "$OPT_DIR/C2-Tool-Collection/BOF"
        run_as_root make
    else
        echo "[!] Missing: $OPT_DIR/C2-Tool-Collection"
    fi

    echo
    echo "[+] Done!"

    combine_outflank_cna

    find_cna_internal
}

find_cna_internal() {
    echo
    echo "[+] Searching for CNA files..."

    FOUND=0

    for repo in CS-Aggressor-Kit CS-Remote-OPs-BOF CS-Situational-Awareness-BOF GetWebDAVStatus C2-Tool-Collection sekken-enum WebcamBOF COM-Hunter PrivKit RegPersist HelpColor; do
        REPO_PATH="$OPT_DIR/$repo"

        [ ! -d "$REPO_PATH" ] && continue

        case "$repo" in
            CS-Aggressor-Kit) AUTHOR="@nickvourd" ;;
            CS-Remote-OPs-BOF) AUTHOR="@TrustedSec" ;;
            CS-Situational-Awareness-BOF) AUTHOR="@TrustedSec" ;;
            GetWebDAVStatus) AUTHOR="@nickvourd" ;;
            C2-Tool-Collection) AUTHOR="@OutflankNL" ;;
            sekken-enum) AUTHOR="@nomad0x7" ;;
            WebcamBOF) AUTHOR="@codex_tf2" ;;
            COM-Hunter) AUTHOR="@nickvourd" ;;
            PrivKit) AUTHOR="@merterpreter" ;;
            RegPersist) AUTHOR="@lefterispan" ;;
            HelpColor) AUTHOR="@OutflankNL" ;;
            PersisTask-BOF) AUTHOR="@nickzer0" ;;
            *) AUTHOR="@unknown" ;;
        esac

        if [[ "$repo" == "C2-Tool-Collection" ]]; then
            CNA_FILES=$(find "$REPO_PATH" -type f -name "*.cna" \
                ! -path "$REPO_PATH/BOF/*" \
                ! -path "$REPO_PATH/Other/*" \
                2>/dev/null | sort)

            if [ -f "$REPO_PATH/BOF/Outflank-OpenSource.cna" ]; then
                if [[ -n "$CNA_FILES" ]]; then
                    CNA_FILES="$CNA_FILES
$REPO_PATH/BOF/Outflank-OpenSource.cna"
                else
                    CNA_FILES="$REPO_PATH/BOF/Outflank-OpenSource.cna"
                fi
            fi
        else
            CNA_FILES=$(find "$REPO_PATH" -type f -name "*.cna" 2>/dev/null | sort)
        fi

        if [[ -n "$CNA_FILES" ]]; then
            FOUND=1
            echo
            echo "[+] $repo CNA by $AUTHOR:"

            while IFS= read -r file; do
                [ -n "$file" ] && echo "-> $file"
            done <<EOF
$CNA_FILES
EOF
        fi
    done

    echo

    if [[ "$FOUND" -eq 0 ]]; then
        return 1
    else
        return 0
    fi
    echo
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
