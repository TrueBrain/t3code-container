FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/go/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN userdel -r ubuntu

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        fd-find \
        file \
        git \
        git-lfs \
        gnupg \
        htop \
        iproute2 \
        iputils-ping \
        jq \
        less \
        libssl-dev \
        lsof \
        nano \
        netcat-openbsd \
        openssh-client \
        openssh-server \
        pkg-config \
        procps \
        python-is-python3 \
        python3 \
        python3-venv \
        ripgrep \
        rsync \
        sqlite3 \
        sudo \
        tini \
        tmux \
        tree \
        tzdata \
        unzip \
        vim \
        wget \
        xz-utils \
        zip \
        zstd \
    && rm -f /etc/ssh/ssh_host_* \
    && mkdir -p /etc/ssh/authorized_keys.d \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

RUN arch=$(dpkg --print-architecture | sed 's/amd64/x64/') \
    && version=$(curl -fsSL https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts)][0].version') \
    && curl -fsSL "https://nodejs.org/dist/${version}/node-${version}-linux-${arch}.tar.xz" \
        | tar -xJ -C /usr/local --strip-components=1 --exclude=CHANGELOG.md --exclude=LICENSE --exclude=README.md

RUN version=$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version') \
    && curl -fsSL "https://go.dev/dl/${version}.linux-$(dpkg --print-architecture).tar.gz" | tar -xz -C /usr/local

RUN curl -fsSL https://sh.rustup.rs \
        | CARGO_HOME=/usr/local/cargo sh -s -- -y --no-modify-path --profile minimal --component rustfmt,clippy \
    && chmod -R a+w /usr/local/rustup /usr/local/cargo

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

RUN npx -y playwright@latest install-deps chromium firefox \
    && rm -rf /var/lib/apt/lists/* /root/.npm

COPY rootfs/ /

WORKDIR /workspace
EXPOSE 22 3773

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/usr/local/sbin/entrypoint"]
