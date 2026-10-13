#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: cachemoney
# License: MIT | https://github.com/community-scripts/DevScripts/raw/main/LICENSE
# Source: https://github.com/seakee/CPA-Manager-Plus

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "cpa-manager-plus" "seakee/CPA-Manager-Plus" "prebuild" "latest" "/opt/cpa-manager-plus" "cpa-manager-plus_*_linux_$(arch_resolve "amd64" "arm64").tar.gz"

msg_info "Setting up CPA Manager Plus"
mkdir -p /var/lib/cpa-manager-plus
mkdir -p -m 700 /etc/cpa-manager-plus
cat <<EOF >/etc/cpa-manager-plus/cpamp-admin-key
cpamp_$(random_password 32)
EOF
chmod 600 /etc/cpa-manager-plus/cpamp-admin-key
cat <<EOF >/opt/cpa-manager-plus/config.json
{
  "httpAddr": "0.0.0.0:18317",
  "dataDir": "/var/lib/cpa-manager-plus",
  "adminKeyFile": "/etc/cpa-manager-plus/cpamp-admin-key",
  "dataKeyPath": "/var/lib/cpa-manager-plus/data.key"
}
EOF
msg_ok "Set up CPA Manager Plus"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/cpa-manager-plus.service
[Unit]
Description=CPA Manager Plus Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/cpa-manager-plus
ExecStart=/opt/cpa-manager-plus/cpa-manager-plus
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now cpa-manager-plus
msg_ok "Created Service"

echo -e "${INFO}${YW}CPA Manager Plus admin key: \$(cat /etc/cpa-manager-plus/cpamp-admin-key)${CL}"

motd_ssh
customize
cleanup_lxc
