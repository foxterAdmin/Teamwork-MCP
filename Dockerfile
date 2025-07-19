# 1) Base Debian slim e instalamos SOLO Node.js v18 (no la vieja npm de bullseye)
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/home/service-user/.npm-global/bin:${PATH}"

# Instala curl y certificados, añade NodeSource para Node 18, y limpia caches
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2) Creamos un usuario sin privilegios
RUN groupadd -r service-user && \
    useradd -r -g service-user service-user && \
    mkdir -p /home/service-user/.npm-global && \
    chown -R service-user:service-user /home/service-user

USER service-user
WORKDIR /home/service-user

# 3) Configuramos npm para instalar globales en ~/.npm-global y evitamos EACCES
RUN npm config set prefix '/home/service-user/.npm-global'

# 4) Instalamos como service-user el proxy sin errores de permisos
RUN npm install -g mcp-proxy@2.10.6

# 5) Preparamos el directorio de la app
WORKDIR /app

# 6) Exponemos el puerto (usaremos el env $PORT que DigitalOcean inyecta)
EXPOSE 3000

# 7) Arrancamos el proxy, respetando $PORT (cae a 3000 si no existe)
CMD ["sh", "-c", "mcp-proxy --port ${PORT:-3000} npx -y @vizioz/teamwork-mcp"]
