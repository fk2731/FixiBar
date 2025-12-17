#!/usr/bin/env bash

# --------------------------------------------------
# Colors
# --------------------------------------------------
RESET='\e[0m'
RED='\e[1;31m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
YELLOW='\e[1;33m'
PURPLE='\e[1;35m'
CYAN='\e[1;36m'

# --------------------------------------------------
# UI / Logging
# --------------------------------------------------
log_info() { echo -e "${BLUE}[INFO] ${RESET} $1"; }
log_ok() { echo -e "${GREEN}[OK] ${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN] ${RESET} $1"; }
log_err() { echo -e "${RED}[ERROR] ${RESET} $1"; }
