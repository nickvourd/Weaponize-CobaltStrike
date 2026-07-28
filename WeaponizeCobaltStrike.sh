#!/bin/bash

cat << 'EOF'


██     ██ ▄▄▄▄▄  ▄▄▄  ▄▄▄▄   ▄▄▄  ▄▄  ▄▄ ▄▄ ▄▄▄▄▄ ▄▄▄▄▄   ▄█████  ▄▄▄  ▄▄▄▄   ▄▄▄  ▄▄   ▄▄▄▄▄▄   ▄█████ ▄▄▄▄▄▄ ▄▄▄▄  ▄▄ ▄▄ ▄▄ ▄▄▄▄▄
██ ▄█▄ ██ ██▄▄  ██▀██ ██▄█▀ ██▀██ ███▄██ ██   ▄█▀ ██▄▄    ██     ██▀██ ██▄██ ██▀██ ██     ██     ▀▀▀▄▄▄   ██   ██▄█▄ ██ ██▄█▀ ██▄▄
 ▀██▀██▀  ██▄▄▄ ██▀██ ██    ▀███▀ ██ ▀██ ██ ▄██▄▄ ██▄▄▄   ▀█████ ▀███▀ ██▄█▀ ██▀██ ██▄▄▄  ██     █████▀   ██   ██ ██ ██ ██ ██ ██▄▄▄

                                                Created with ❤ by @nickvourd
EOF

set -e

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
REPO13="https://github.com/jhalon/cSessionHop.git"
REPO14="https://github.com/CodeXTF2/ScreenshotBOF.git"

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
        echo -e "${RED}[!]${NC} Do NOT run the full script with sudo on macOS."
        echo "    Homebrew should run as a normal user."
        exit 1
    fi

    if ! command_exists brew; then
        echo -e "${YELLOW}[*]${NC} Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo -e "${YELLOW}[*]${NC} Updating Homebrew..."
    brew update

    if ! command_exists git; then
        echo -e "${YELLOW}[*]${NC} Installing git..."
        brew install git
    else
        echo -e "${GREEN}[+]${NC} git already installed"
    fi

    if ! command_exists make; then
        echo -e "${YELLOW}[*]${NC} Installing make..."
        brew install make
    else
        echo -e "${GREEN}[+]${NC} make already installed"
    fi

    if ! command_exists x86_64-w64-mingw32-gcc; then
        echo -e "${YELLOW}[*]${NC} Installing mingw-w64..."
        brew install mingw-w64
    else
        echo -e "${GREEN}[+]${NC} mingw-w64 already installed"
    fi

    if ! command_exists clang; then
        echo -e "${YELLOW}[*]${NC} Installing LLVM..."
        brew install llvm
    else
        echo -e "${GREEN}[+]${NC} LLVM already installed"
    fi

    LLVM_PATH="/opt/homebrew/opt/llvm/bin"
    if [[ ":$PATH:" != *":$LLVM_PATH:"* ]]; then
        echo -e "${YELLOW}[*]${NC} Adding LLVM to PATH for current session"
        export PATH="$LLVM_PATH:$PATH"
        echo -e "${YELLOW}[*]${NC} You may also want to add this to ~/.zshrc:"
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
        echo -e "${RED}[!]${NC} Unsupported Linux distribution"
        exit 1
    fi
}

install_dependencies() {
    echo -e "${YELLOW}[*]${NC} Detected OS: $OS"

    case "$OS" in
        Darwin)
            install_macos
            ;;
        Linux)
            install_linux
            ;;
        *)
            echo -e "${RED}[!]${NC} Unsupported OS: $OS"
            exit 1
            ;;
    esac

    echo -e "${GREEN}[+]${NC} Installation check completed"
    echo -e "${YELLOW}[*]${NC} Versions:"
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
    echo -e "${BLUE}[+]${NC} Cloning $label..."

    if [ -d "$dest_dir" ]; then
        echo -e "${RED}[!]${NC} $dest_dir already exists. Removing..."
        run_as_root rm -rf "$dest_dir"
    fi

    run_as_root git clone "$repo_url" "$dest_dir"
}

combine_outflank_cna() {
    TARGET_DIR="$OPT_DIR/C2-Tool-Collection"
    OUTPUT_DIR="$OPT_DIR/C2-Tool-Collection/BOF"
    OUTPUT_FILE="$OUTPUT_DIR/Outflank-OpenSource.cna"

    echo
    echo -e "${BLUE}[+]${NC} Combining CNA files from C2-Tool-Collection..."

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}[!]${NC} Missing: $TARGET_DIR"
        return 1
    fi

    # FIX: ensure we can write
    sudo chown $(whoami) "$OUTPUT_DIR"

    > "$OUTPUT_FILE"

    CNA_FILES=$(find "$TARGET_DIR/BOF" -type f -name "*.cna" 2>/dev/null | sort)

    if [[ -z "$CNA_FILES" ]]; then
        echo -e "${RED}[!]${NC} No CNA files found"
        return 1
    fi

    for file in $CNA_FILES; do
        echo -e "${YELLOW}[*]${NC} Adding: $file"

        {
            echo ""
            echo "# ===== FILE: $file ====="
            echo ""
            cat "$file"
            echo ""
        } >> "$OUTPUT_FILE"
    done

    echo
    echo -e "${GREEN}[+]${NC} Combined CNA saved to:"
    echo "    $OUTPUT_FILE"
    echo
}

combine_outflank_cna() {
    TARGET_DIR="$OPT_DIR/C2-Tool-Collection/BOF"
    OUTPUT_FILE="$OPT_DIR/C2-Tool-Collection/BOF/Outflank-OpenSource.cna"

    echo
    echo -e "${BLUE}[+]${NC} Combining CNA files from C2-Tool-Collection..."

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${RED}[!]${NC} Missing: $TARGET_DIR"
        return 1
    fi

    CNA_FILES=$(find "$TARGET_DIR" -type f -name "*.cna" ! -name "Outflank-OpenSource.cna" 2>/dev/null | sort)

    if [[ -z "$CNA_FILES" ]]; then
        echo -e "${RED}[!]${NC} No CNA files found"
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

    echo -e "${GREEN}[+]${NC} Combined CNA saved to:"
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
    clone_repo "$REPO13" "$OPT_DIR/cSessionHop"                   "cSessionHop by @jhalon"
    clone_repo "$REPO14" "$OPT_DIR/ScreenshotBOF"                 "ScreenshotBOF by @CodeXTF2"
    echo
    echo -e "${GREEN}[+]${NC} Cloning complete\n"
}

compile_all() {
    echo -e "${BLUE}[+]${NC} Compile BOFs..."

    if [ -d "$OPT_DIR/CS-Remote-OPs-BOF" ]; then
        cd "$OPT_DIR/CS-Remote-OPs-BOF"
        run_as_root bash make_all.sh
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/CS-Remote-OPs-BOF"
    fi

    if [ -d "$OPT_DIR/CS-Situational-Awareness-BOF" ]; then
        cd "$OPT_DIR/CS-Situational-Awareness-BOF"
        run_as_root bash make_all.sh
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/CS-Situational-Awareness-BOF"
    fi

    if [ -d "$OPT_DIR/COM-Hunter" ]; then
        cd "$OPT_DIR/COM-Hunter/BOF"
        run_as_root bash make_all.sh
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/COM-Hunter"
    fi

    if [ -d "$OPT_DIR/PrivKit" ]; then
        cd "$OPT_DIR/PrivKit"
        run_as_root bash make_all.sh
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/PrivKit"
    fi

    if [ -d "$OPT_DIR/GetWebDAVStatus/GetWebDAVStatus_BOF/Source" ]; then
        cd "$OPT_DIR/GetWebDAVStatus/GetWebDAVStatus_BOF/Source"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/GetWebDAVStatus/GetWebDAVStatus_BOF/Source"
    fi

    if [ -d "$OPT_DIR/sekken-enum/src" ]; then
        cd "$OPT_DIR/sekken-enum/src"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/sekken-enum"
    fi

    if [ -d "$OPT_DIR/WebcamBOF" ]; then
        cd "$OPT_DIR/WebcamBOF"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/WebcamBOF"
    fi

    if [ -d "$OPT_DIR/RegPersist" ]; then
        cd "$OPT_DIR/RegPersist"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/RegPersist"
    fi

    if [ -d "$OPT_DIR/PersisTask-BOF" ]; then
        cd "$OPT_DIR/PersisTask-BOF"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/PersisTask-BOF"
    fi

    if [ -d "$OPT_DIR/cSessionHop" ]; then
        cd "$OPT_DIR/cSessionHop"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/cSessionHop"
    fi

    if [ -d "$OPT_DIR/ScreenshotBOF" ]; then
        cd "$OPT_DIR/ScreenshotBOF"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/ScreenshotBOF"
    fi

    if [ -d "$OPT_DIR/C2-Tool-Collection/BOF" ]; then
        cd "$OPT_DIR/C2-Tool-Collection/BOF"
        run_as_root make
    else
        echo -e "${RED}[!]${NC} Missing: $OPT_DIR/C2-Tool-Collection"
    fi

    echo
    echo -e "${GREEN}[+]${NC} Done!"

    combine_outflank_cna

    find_cna_internal
}

find_cna_internal() {
    echo
    echo -e "${BLUE}[+]${NC} Searching for CNA files..."

    FOUND=0

    for repo in CS-Aggressor-Kit CS-Remote-OPs-BOF CS-Situational-Awareness-BOF GetWebDAVStatus C2-Tool-Collection sekken-enum WebcamBOF COM-Hunter PrivKit RegPersist HelpColor cSessionHop ScreenshotBOF; do
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
            cSessionHop) AUTHOR="@jhalon" ;;
            ScreenshotBOF) AUTHOR="@CodeXTF2" ;;
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
            echo -e "${GREEN}[+]${NC} $repo CNA by $AUTHOR:"

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
        echo -e "${RED}[!]${NC} No CNA files found under /opt"
        echo -e "${RED}[!]${NC} Please Run install Command...\n"
    fi
}

do_install() {
    install_dependencies
    clone_repos
    compile_all
}

do_clean() {
    echo -e "${YELLOW}[*]${NC} Cleaning up /opt (except /opt/homebrew)..."
    run_as_root find /opt -maxdepth 1 -mindepth 1 -type d ! -name homebrew -exec rm -rf {} +
    echo -e "${GREEN}[+]${NC} Cleanup complete\n"
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
