#!/usr/bin/env bash
#
# crooksec | Tenant Domain Enumerator
# Bulk + Per-domain Output Edition
#

set -o pipefail

# =======================
# Config
# =======================
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
OUTDIR="crooksec-results"

RED="\033[1;31m"
CYAN="\033[1;36m"
NC="\033[0m"
BLINK="\033[5m"

# =======================
# Banner (non-blocking)
# =======================
banner() {
    [[ "$SILENT_MODE" == true ]] && return
    echo -ne "${CYAN}${BLINK}crooksec | tenant script${NC}\r" >&2
}

log() {
    [[ "$SILENT_MODE" == false ]] && echo -e "$1" >&2
}

die() {
    echo "[!] $1" >&2
    exit 1
}

show_help() {
    cat <<EOF
crooksec Tenant Domain Enumerator

Usage:
  $0 [OPTIONS]

Options:
  -d, --domain <domain>   Single domain
  -l, --list <file>       File with domain list (bulk)
  -o, --output <dir>      Output directory (default: crooksec-results)
  -s, --silent            Silent mode (no banner/logs)
  -h, --help              Help

Examples:
  $0 -d hackerone.com
  $0 -l targets.txt
  $0 -l targets.txt -o tenants
  $0 -l targets.txt -s | httpx
EOF
}

# =======================
# Core Logic
# =======================
tenant_lookup() {
    local domain="$1"

    banner
    log "[*] Processing: $domain"

    local oidc
    oidc=$(curl -fsL \
        "https://login.microsoftonline.com/$domain/.well-known/openid-configuration" \
        -H "User-Agent: $USER_AGENT") || return

    local tenant_id
    tenant_id=$(echo "$oidc" | jq -r '.token_endpoint' | cut -d'/' -f4)

    [[ -z "$tenant_id" || "$tenant_id" == "null" ]] && return

    sleep "$(awk 'BEGIN{srand(); print 1 + rand()*4}')"

    local response
    response=$(curl -fsL \
        "https://tenant-api.micahvandeusen.com/search?tenant_id=$tenant_id" \
        -H "User-Agent: $USER_AGENT") || return

    local domains
    domains=$(echo "$response" | jq -r '.domains[]' 2>/dev/null | sort -u)

    [[ -z "$domains" ]] && return

    mkdir -p "$OUTDIR"
    local outfile="$OUTDIR/${domain}.txt"

    echo "$domains" | tee "$outfile"
    log "[+] Saved → $outfile"
}

run_single() {
    tenant_lookup "$DOMAIN_SEARCH"
}

run_list() {
    [[ ! -f "$LIST_FILE" ]] && die "List file not found: $LIST_FILE"

    while read -r domain; do
        [[ -z "$domain" ]] && continue
        tenant_lookup "$domain"
    done < "$LIST_FILE"
}

# =======================
# Args
# =======================
DOMAIN_SEARCH=""
LIST_FILE=""
SILENT_MODE=false

[[ "$#" -eq 0 ]] && { show_help; exit 0; }

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -s|--silent) SILENT_MODE=true ;;
        -d|--domain) DOMAIN_SEARCH="$2"; shift ;;
        -l|--list) LIST_FILE="$2"; shift ;;
        -o|--output) OUTDIR="$2"; shift ;;
        *) die "Unknown option: $1" ;;
    esac
    shift
done

# =======================
# Execution
# =======================
[[ -n "$DOMAIN_SEARCH" ]] && run_single
[[ -n "$LIST_FILE" ]] && run_list

