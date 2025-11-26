FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    sudo \
    python3 python3-pip python3-venv \
    swi-prolog \
    build-essential \
    vim \
    bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USERNAME
ARG UID
ARG GID

RUN groupadd -g $GID $USERNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $USERNAME

USER $USERNAME
ENV WORKSPACE=/home/$USERNAME/vscode_petta_mork
WORKDIR $WORKSPACE

RUN echo 'cd ~/vscode_petta_mork 2>/dev/null || true' >> /home/$USERNAME/.bashrc && \
    echo 'if [ -d "$HOME/vscode_petta_mork/.venv" ]; then' >> /home/$USERNAME/.bashrc && \
    echo '  . "$HOME/vscode_petta_mork/.venv/bin/activate"' >> /home/$USERNAME/.bashrc && \
    echo 'fi' >> /home/$USERNAME/.bashrc

CMD ["/bin/bash"]
