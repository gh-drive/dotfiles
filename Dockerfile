ARG BASE_IMAGE=ubuntu
ARG CODE_NAME=latest
FROM registry.cn-shanghai.aliyuncs.com/cn-mirrors/${BASE_IMAGE}:${CODE_NAME}
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get -y install --no-install-recommends build-essential sudo ca-certificates curl git tig locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    if grep -q "VERSION_CODENAME=noble" /etc/os-release; then \
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

WORKDIR $HOME

# install chezmoi
RUN curl -sSLfk get.chezmoi.io -o /tmp/install_chezmoi.sh && \
    chmod +x /tmp/install_chezmoi.sh && \
    mkdir -p /home/linuxbrew/.local/bin && \
    /tmp/install_chezmoi.sh -b /home/linuxbrew/.local/bin -t latest -d && \
    rm -f /tmp/install_chezmoi.sh

ARG REF=master
RUN --mount=type=secret,id=DOTFILES_REPO,mode=0444,required=true \
    /home/linuxbrew/.local/bin/chezmoi init "$(cat /run/secrets/DOTFILES_REPO)" --depth 1 --no-pager --no-tty && \
    git -C /home/linuxbrew/.local/share/chezmoi checkout $REF && \
    /home/linuxbrew/.local/bin/chezmoi apply --init --force --no-pager --no-tty && \
    /home/linuxbrew/.local/bin/chezmoi apply --force --no-pager --no-tty && \
    /home/linuxbrew/.local/bin/custom/chezmoi-integrity && \
    /bin/rm -rf /home/linuxbrew/.cache/chezmoi && \
    /bin/rm -rf /home/linuxbrew/.config/chezmoi && \
    /bin/rm -rf /tmp/*

CMD [ "zsh", "-l" ]
