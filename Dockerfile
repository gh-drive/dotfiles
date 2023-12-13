ARG base_image=ubuntu
ARG image_tag=latest
FROM ${base_image}:${image_tag}
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get -y install --no-install-recommends build-essential sudo ca-certificates curl git tig locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    groupadd linuxbrew && \
    useradd -s /bin/bash --gid linuxbrew -m linuxbrew && \
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

RUN --mount=type=secret,id=DOTFILES_REPO,mode=0444,required=true \
    /home/linuxbrew/.local/bin/chezmoi init "$(cat /run/secrets/DOTFILES_REPO)" --depth 1 --no-pager --no-tty && \
    /home/linuxbrew/.local/bin/chezmoi apply --init --force --no-pager --no-tty && \
    /home/linuxbrew/.local/bin/chezmoi apply --force --no-pager --no-tty && \
    /home/linuxbrew/.local/bin/custom/chezmoi-integrity && \
    rm -rf /home/linuxbrew/.cache/chezmoi && \
    rm -rf /home/linuxbrew/.config/chezmoi

CMD [ "zsh", "-l" ]
