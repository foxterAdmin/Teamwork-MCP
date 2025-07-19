# Usa la imagen oficial de Node 18 con Debian slim
FROM node:18-bullseye-slim

# Crea y usa un usuario no root (opcional)
RUN groupadd -r service-user \
 && useradd -r -g service-user service-user

USER service-user
WORKDIR /home/service-user/app

# Instala el proxy mcp-proxy globalmente
RUN npm install -g mcp-proxy@2.10.6

# Expón el puerto que Render asignará en $PORT
EXPOSE 3000

# Arranca sustituyendo ${PORT} en runtime (cae a 3000 si no existe)
CMD ["sh", "-c", "mcp-proxy --port ${PORT:-3000} npx -y @vizioz/teamwork-mcp"]
