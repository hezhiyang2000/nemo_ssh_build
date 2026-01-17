#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /etc/ssh/ssh_host_rsa_key ]]; then
  ssh-keygen -A
fi

# Optional: populate authorized_keys from env for quick setup
if [[ -n "${DEV_SSH_AUTHORIZED_KEYS:-}" ]]; then
  if [[ "${DEV_USER}" == "root" ]]; then
    user_home="/root"
  else
    user_home="/home/${DEV_USER}"
  fi
  install -d -m 0700 "${user_home}/.ssh"
  printf '%s\n' "${DEV_SSH_AUTHORIZED_KEYS}" > "${user_home}/.ssh/authorized_keys"
  chmod 0600 "${user_home}/.ssh/authorized_keys"
  chown -R "${DEV_USER}:${DEV_USER}" "${user_home}/.ssh"
fi

/usr/sbin/sshd

if [[ -n "${NEMO_ORIGINAL_ENTRYPOINT:-}" ]]; then
  exec "${NEMO_ORIGINAL_ENTRYPOINT}" "$@"
fi

exec "$@"
