#!/bin/bash

set -euo pipefail

vars_file="/etc/default/one-context"

if [ ! -e "${vars_file}" ]; then
    echo 'provision_user_create="true"' > "${vars_file}"
fi

. "${vars_file}"

if [ "${provision_user_create:-}" = "true" ]; then
    [ -z "${PROVISION_USER_USERNAME:-}" ] && exit 1
    [ -z "${PROVISION_USER_CRYPTED_PASSWORD_BASE64:-}" ] && exit 1
    [ -z "${PROVISION_USER_PUBLIC_KEY:-}" ] && exit 1

    provision_user_password="$(echo "${PROVISION_USER_CRYPTED_PASSWORD_BASE64}" | base64 -d)"

    if [ -z "$(getent passwd "${PROVISION_USER_USERNAME}")" ]; then
        useradd --create-home --shell /bin/bash "${PROVISION_USER_USERNAME}"
        mkdir -m u=rwx,g=,o= "/home/${PROVISION_USER_USERNAME}/.ssh"
        echo "${PROVISION_USER_PUBLIC_KEY}" > "/home/${PROVISION_USER_USERNAME}/.ssh/authorized_keys"
        chmod u=rw,g=,o= "/home/${PROVISION_USER_USERNAME}/.ssh/authorized_keys"
        chown -R "${PROVISION_USER_USERNAME}:${PROVISION_USER_USERNAME}" "/home/${PROVISION_USER_USERNAME}/.ssh"
        echo "${PROVISION_USER_USERNAME}:${provision_user_password}" | chpasswd
        usermod --append --groups sudo "${PROVISION_USER_USERNAME}"
    fi

    sed -i -e 's/[[:space:]]*provision_user_create=.*/provision_user_create="false"/' "${vars_file}"
fi
