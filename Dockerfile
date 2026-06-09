FROM node:20-slim

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Copy source files and config first
COPY tsconfig.json ./
COPY src ./src

# Install dependencies (which triggers the build via the prepare script)
RUN npm ci

# Config (OAuth keys + credentials) lives under the user's home dir by default
# (os.homedir() => /root, so CONFIG_DIR => /root/.gmail-mcp). Mount a named volume
# there to persist auth across runs — no env path overrides needed.
ENV NODE_ENV=production

# During the one-time `auth` command the OAuth callback server must bind to all
# interfaces so a host-published port (-p 127.0.0.1:3000:3000) can reach it;
# published ports never forward to a container's loopback interface. Outside
# Docker the server still defaults to 127.0.0.1.
ENV GMAIL_OAUTH_BIND_ADDR=0.0.0.0

# Set entrypoint command
ENTRYPOINT ["node", "dist/index.js"]
