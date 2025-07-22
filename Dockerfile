# Development Environment Docker Container
# Includes: Latest npm, Vim as Python IDE, Claude Code with MCP servers, VS Code with Azure/Git/Python tools

FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Set up user and directories
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    tmux \
    zsh \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    sudo \
    openssh-client \
    jq \
    tree \
    htop \
    unzip \
    zip \
    ripgrep \
    fd-find \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim (latest version)
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
    && tar -C /opt -xzf nvim-linux64.tar.gz \
    && ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim \
    && ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/vim \
    && rm nvim-linux64.tar.gz

# Install Node.js 20 (latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Verify and install latest npm
RUN npm install -g npm@latest

# Install global Node packages
RUN npm install -g \
    @anthropic-ai/claude-code \
    @upstash/context7-mcp \
    @beehiveinnovations/zen-mcp-server \
    @modelcontextprotocol/server-filesystem \
    desktop-commander \
    @anthropic-ai/mcp-web-search \
    mcp-frontend-testing \
    mcp-jest \
    typescript \
    ts-node \
    eslint \
    prettier \
    nodemon

# Install VS Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt-get update \
    && apt-get install -y code \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Docker CLI (for Docker-in-Docker if needed)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install Python development tools
RUN pip3 install --upgrade pip \
    && pip3 install \
    black \
    flake8 \
    pylint \
    mypy \
    isort \
    pre-commit \
    poetry \
    pipenv \
    virtualenv \
    jupyter \
    ipython \
    requests \
    fastapi \
    uvicorn \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    pytest \
    pytest-cov \
    httpx \
    python-lsp-server[all]

# Create user with sudo privileges
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Oh My Zsh for better terminal experience
USER $USERNAME
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Switch back to root for remaining setup
USER root

# Set up workspace directory
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace

# Copy configuration files
COPY --chown=$USERNAME:$USERNAME configs/ /home/$USERNAME/

# Set up VS Code extensions directory
RUN mkdir -p /home/$USERNAME/.vscode-server/extensions \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.vscode-server

# Final user setup
USER $USERNAME
WORKDIR /workspace

# Set default shell to zsh
ENV SHELL=/bin/zsh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node --version && python3 --version && code --version || exit 1

# Default command
CMD ["/bin/zsh"]
