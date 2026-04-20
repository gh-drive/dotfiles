ARG BASE_IMAGE=ubuntu
ARG CODE_NAME=noble
FROM ${BASE_IMAGE}:${CODE_NAME}
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get -y install --no-install-recommends build-essential sudo ca-certificates curl git locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    if grep -qE "VERSION_CODENAME=(noble|resolute)" /etc/os-release; then \
    usermod --move-home --home /home/linuxbrew --login linuxbrew ubuntu; \
    groupmod --new-name linuxbrew ubuntu; \
    else \
    groupadd linuxbrew && \
    useradd -s /bin/bash --gid linuxbrew -m linuxbrew; \
    fi && \
    echo "linuxbrew ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/linuxbrew && \
    chmod 0440 /etc/sudoers.d/linuxbrew && \
    cat /etc/passwd

USER linuxbrew
ENV HOME=/home/linuxbrew \
    PATH=/home/linuxbrew/.local/bin:$PATH \
    TERM=xterm-256color

WORKDIR /home/linuxbrew

# install chezmoi
ARG CZ_VERSION=v2.70.2
RUN mkdir -p /home/linuxbrew/.local/bin && \
    sh -c "$(curl -fsLS https://get.chezmoi.io) -b /home/linuxbrew/.local/bin -t ${CZ_VERSION}"  && \
    /home/linuxbrew/.local/bin/chezmoi --version
