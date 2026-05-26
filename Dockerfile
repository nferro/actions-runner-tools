# Custom runner image for the dotpt-linux-dind ARC scale set.
# Adds the tooling that GitHub-hosted `ubuntu-latest` ships with but that
# the lean `ghcr.io/actions/actions-runner` base image omits.
#
# Built by .github/workflows/build.yml on push to main.
# Published to ghcr.io/dotpt-private/actions-runner-tools.
# Consumed by applications/arc-runners-dotpt-linux-dind.yaml in dotpt-private/argocd
# (containers[0].image).

FROM ghcr.io/actions/actions-runner:latest

USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        unzip \
        wget \
        xz-utils \
        zstd; \
    install -m 0755 -d /etc/apt/keyrings; \
    \
    # GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null; \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list; \
    \
    # Docker buildx + compose plugins (talk to the in-pod dind sidecar)
    . /etc/os-release; \
    curl -fsSL "https://download.docker.com/linux/${ID}/gpg" -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" \
        > /etc/apt/sources.list.d/docker.list; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        gh \
        docker-buildx-plugin \
        docker-compose-plugin; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER runner
