
#!/bin/sh
set -eu

PACKAGES=""

if ! command -v git >/dev/null 2>&1; then
    PACKAGES="$PACKAGES git"
fi

if ! command -v ssh >/dev/null 2>&1; then
    PACKAGES="$PACKAGES openssh-client"
fi

# Nothing to install if both tools already exist
if [ -z "$PACKAGES" ]; then
    echo "Git and SSH already installed. Skipping."
    exit 0
fi

echo "Installing missing packages:$PACKAGES"

if command -v apt-get >/dev/null 2>&1; then
    . /etc/os-release

    if [ "${ID:-}" = "debian" ]; then
        case "${VERSION_CODENAME:-}" in
            buster)
                printf '%s\n' \
                  'deb [check-valid-until=no] http://archive.debian.org/debian buster main' \
                  'deb [check-valid-until=no] http://archive.debian.org/debian buster-updates main' \
                  'deb [check-valid-until=no] http://archive.debian.org/debian-security buster/updates main' \
                  > /etc/apt/sources.list
                ;;
            bullseye)
                printf '%s\n' \
                  'deb [check-valid-until=no] http://archive.debian.org/debian bullseye main' \
                  'deb [check-valid-until=no] http://archive.debian.org/debian bullseye-updates main' \
                  'deb [check-valid-until=no] http://archive.debian.org/debian-security bullseye-security main' \
                  > /etc/apt/sources.list
                ;;
        esac
    fi

    apt-get update

    DEBIAN_FRONTEND=noninteractive \
      apt-get install -y --no-install-recommends $PACKAGES

    rm -rf /var/lib/apt/lists/*

elif command -v apk >/dev/null 2>&1; then
    apk add --no-cache $PACKAGES

else
    echo "Unsupported package manager" >&2
    exit 1
fi

echo "Git and SSH installation completed."
