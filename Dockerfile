FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Node.js v22, npm, git, and mcp-proxy system-wide as root
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl git && \
    # Install NodeSource Node.js v22 and matching npm
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    # Explicitly install both nodejs and npm from NodeSource
    apt-get install -y nodejs npm && \
    # Verify versions as root
    echo "--- Root Node Version ---" && \
    node --version && \
    echo "--- Root NPM Version ---" && \
    npm --version && \
    echo "--- Root Node Path ---" && \
    which node && \
    echo "--- Root NPM Path ---" && \
    which npm && \
    # Install mcp-proxy globally
    npm install -g mcp-proxy@2.10.6 && \
    # Clean up apt caches
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create service user and app directory
RUN groupadd -r service-user && \
    useradd -u 1987 -r -m -g service-user service-user && \
    mkdir -p /app && \
    chown -R service-user:service-user /app

# Switch to service-user
USER service-user
WORKDIR /app

# --- Debugging as service-user ---
RUN echo "--- Service User PATH ---" && \
    echo $PATH && \
    echo "--- Service User Node Path ---" && \
    which node && \
    echo "--- Service User Node Version ---" && \
    node --version && \
    echo "--- Service User NPM Path ---" && \
    which npm && \
    echo "--- Service User NPM Version ---" && \
    npm --version
# --- End Debugging ---

# Clone the specific commit
# git is available system-wide now
RUN git clone https://github.com/Vizioz/Teamwork-MCP . && \
    git checkout feb05ea8a839ca61b88aa78ff28b0e9e23a8fdc3

# Install project dependencies (will use system Node v22)
RUN npm install

# Build the project
RUN npm run build

# Run the built application
# mcp-proxy is available system-wide in PATH
CMD ["mcp-proxy", "node", "build/index.js"]
