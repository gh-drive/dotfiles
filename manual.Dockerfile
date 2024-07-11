ARG IMAGE_NAME
ARG CODE_NAME=noble
FROM ${IMAGE_NAME}:${CODE_NAME}
ARG USER_ID=1000
ARG GROUP_ID=1000
USER root
RUN groupmod --gid $GROUP_ID linuxbrew && \
    usermod --uid $USER_ID --gid $GROUP_ID linuxbrew && \
    chown -R linuxbrew:linuxbrew /home/linuxbrew
USER linuxbrew
