#!/usr/bin/env bash
set -euo pipefail

readonly CA_DIR="/usr/local/share/ca-certificates"
readonly CA_CERT_URL="https://raw.githubusercontent.com/taehun-kmu/auto/main/apt/crt/KMU.crt"
readonly CERTIFI_PATTERN="cacert.pem"

log_info() {
    echo "[INFO]  $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
}

get_sudo() {
    if command -v sudo > /dev/null 2>&1 && ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"; then
        echo "sudo"
    else
        echo ""
    fi
}

install_packages() {
    local sudo_cmd="$1"
    log_info "Installing required packages..."
    ${sudo_cmd} apt-get update
    ${sudo_cmd} apt-get install -y --no-install-recommends curl wget ca-certificates python3 python3-certifi
}

install_ca() {
    local sudo_cmd="$1"
    log_info "Downloading KMU CA certificate..."
    ${sudo_cmd} wget -q -P "${CA_DIR}/" "${CA_CERT_URL}"

    log_info "Updating OS certificate trust store..."
    ${sudo_cmd} update-ca-certificates
}

patch_certifi() {
    local sudo_cmd="$1"
    local target_dir="$2"
    log_info "Patching Python certifi bundles in ${target_dir}..."
    find "${target_dir}" -name "${CERTIFI_PATTERN}" -exec ${sudo_cmd} sh -c \
        'cat "$1" >> "$2"' _ "${CA_DIR}/KMU.crt" {} \;
}

main() {
    local sudo_cmd
    sudo_cmd=$(get_sudo)

    install_packages "${sudo_cmd}"
    install_ca "${sudo_cmd}"

    patch_certifi "${sudo_cmd}" "${1:-/usr}"
}

main "$@"
