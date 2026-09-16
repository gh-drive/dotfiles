ARG IMAGE_NAME
ARG CODE_NAME=noble
FROM ${IMAGE_NAME}:${CODE_NAME}-base
ARG DEBIAN_FRONTEND=noninteractive
ARG REF=master
RUN --mount=type=secret,id=DOTFILES_REPO,mode=0444,required=true \
    --mount=type=secret,id=gh_token,mode=0444,required=true \
    GITHUB_TOKEN="$(cat /run/secrets/gh_token)" \
    /home/linuxbrew/.local/bin/chezmoi init "$(cat /run/secrets/DOTFILES_REPO)" --depth 1 --no-pager --no-tty && \
    git -C /home/linuxbrew/.local/share/chezmoi checkout $REF && \
    /home/linuxbrew/.local/bin/chezmoi apply --init --force --no-pager --no-tty && \
    /home/linuxbrew/.local/bin/chezmoi apply --force --no-pager --no-tty && \
    /home/linuxbrew/bin/chezmoi-check && \
    /bin/rm -rf /home/linuxbrew/.cache/chezmoi && \
    /bin/rm -rf /home/linuxbrew/.cache/mise && \
    /bin/rm -rf /home/linuxbrew/.cache/pip && \
    /bin/rm -rf /home/linuxbrew/.config/chezmoi && \
    /bin/rm -rf /tmp/* && \
    /home/linuxbrew/bin/clean-dir /home/linuxbrew

RUN --mount=type=secret,id=gh_token,mode=0444,required=true \
    --mount=type=secret,id=repository,mode=0444,required=true \
    CZ_BACKUP_REPO="$(cat /run/secrets/repository)" GH_TOKEN="$(cat /run/secrets/gh_token)" \
    /home/linuxbrew/bin/chezmoi-backuphome

CMD [ "zsh", "-l" ]
