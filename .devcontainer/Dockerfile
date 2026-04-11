FROM registry.fedoraproject.org/fedora:43

# Install baseline utilities that Codespaces needs to attach and run properly
RUN dnf upgrade -y && \
    dnf install -y \
    curl \
    git \
    tar \
    sudo \
    shadow-utils \
    findutils \
    procps-ng \
    nodejs \
    && dnf clean all

# Create the standard dev container user (vscode)
RUN useradd -s /bin/bash -m vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

USER vscode