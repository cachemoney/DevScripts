#!/usr/bin/env bash
_CS_DEFAULT_URL="https://raw.githubusercontent.com/community-scripts/DevScripts/main"
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2021-2026 community-scripts ORG
# Author: cachemoney
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://github.com/seakee/CPA-Manager-Plus

APP="CPA Manager Plus"
var_tags="${var_tags:-ai;dashboard;monitoring}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_arm64="${var_arm64:-yes}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/cpa-manager-plus ]]; then
    msg_error "No CPA Manager Plus Installation Found!"
    exit
  fi

  if check_for_gh_release "cpa-manager-plus" "seakee/CPA-Manager-Plus"; then
    msg_info "Stopping CPA Manager Plus"
    systemctl stop cpa-manager-plus
    msg_ok "Stopped CPA Manager Plus"

    create_backup /opt/cpa-manager-plus/config.json

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "cpa-manager-plus" "seakee/CPA-Manager-Plus" "prebuild" "latest" "/opt/cpa-manager-plus" "cpa-manager-plus_*_linux_$(arch_resolve "amd64" "arm64").tar.gz"

    restore_backup

    msg_info "Starting CPA Manager Plus"
    systemctl start cpa-manager-plus
    msg_ok "Started CPA Manager Plus"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Open the panel at http://${IP}:18317/management.html${CL}"
echo -e "${INFO}${YW}The admin key is in /etc/cpa-manager-plus/cpamp-admin-key inside the container${CL}"
