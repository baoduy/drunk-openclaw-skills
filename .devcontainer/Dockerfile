FROM mcr.microsoft.com/devcontainers/python:3.11

# Set shell environment
ENV SHELL=/bin/bash

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc

# Install Node.js and npm (required for pnpm)
RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs npm wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install clawhub globally with pnpm
RUN npm install -g clawhub

# Upgrade pip and install Python packages
RUN pip3 install --upgrade pip --no-cache-dir && \
    pip3 install --no-cache-dir \
    requests \
    pandas \
    pytest \
    black \
    pylint \
    mypy \
    ipython \
    jupyter

# Set working directory
WORKDIR /code

# Keep container running
CMD ["tail", "-f", "/dev/null"]
