ARG base_image=ubuntu
ARG image_tag=latest
FROM ${base_image}:${image_tag}

RUN apt-get update -y && \
    apt-get -y install --no-install-recommends sudo ca-certificates curl git && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd linuxbrew && \
    useradd -s /bin/bash --gid linuxbrew -m linuxbrew && \
    echo "linuxbrew ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/linuxbrew && \
    chmod 0440 /etc/sudoers.d/linuxbrew && \
    cat /etc/passwd

USER linuxbrew
ENV HOME=/home/linuxbrew \
    PATH=/home/linuxbrew/.local/bin:$PATH

ARG HUGGINGFACE_BUILDING=true
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR $HOME

# install chezmoi
RUN curl -sSLfk get.chezmoi.io -o /tmp/install_chezmoi.sh && \
    chmod +x /tmp/install_chezmoi.sh && \
    mkdir -p /home/linuxbrew/.local/bin && \
    /tmp/install_chezmoi.sh -b /home/linuxbrew/.local/bin -t latest -d && \
    rm -f /tmp/install_chezmoi.sh

RUN --mount=type=secret,id=DOTFILES_REPO,mode=0444,required=true \
    /home/linuxbrew/.local/bin/chezmoi init "$(cat /run/secrets/DOTFILES_REPO)" --depth 1 --no-pager --no-tty --keep-going && \
    /home/linuxbrew/.local/bin/chezmoi apply --init --force --no-pager --no-tty --keep-going && \
    /home/linuxbrew/.local/bin/custom/chezmoi-integrity && \
    rm -rf /home/linuxbrew/.cache/chezmoi && \
    rm -rf /home/linuxbrew/.config/chezmoi
