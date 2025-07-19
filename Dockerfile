FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/service-user/.npm-global/bin:/home/service-user/.local/bin:${PATH}"

# 1) Creamos usuario y directorios
RUN groupadd -r service-user && \
    useradd -u 1987 -r -m -g service-user service-user && \
    mkdir -p /home/service-user/.local/bin /app /home/service-user/.npm-global && \
    chown -R service-user:service-user /home/service-user /app

# 2) Instalamos Node.js 22.x
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER service-user
WORKDIR /home/service-user

# 3) Configuramos npm global en usuario
RUN npm config set prefix '/home/service-user/.npm-global'
RUN npm install -g mcp-proxy@2.10.6

WORKDIR /app

# 4) Exponemos el puerto que Render asignará en $PORT
#    (Render inyecta la variable PORT automáticamente)
EXPOSE 3000

# 5) Arrancamos en modo shell para expandir $PORT
CMD ["sh", "-c", "mcp-proxy --port ${PORT:-3000} npx -y @vizioz/teamwork-mcp"]
