# 1) Base Node 18 oficial (sin apt‑get de Node antiguo)
FROM node:18-bullseye-slim

# 2) Crea usuario no root
RUN groupadd -r service-user \
 && useradd -r -g service-user service-user

USER service-user
WORKDIR /home/service-user/app

# 3) Copia y instala deps (prod only)
COPY --chown=service-user:service-user package*.json ./
RUN npm ci --omit=dev

# 4) Copia el código y compila
COPY --chown=service-user:service-user . .
RUN npm run build

# 5) Expón el puerto que n8n conectará
#    (App Platform inyecta $PORT, por defecto 8080)
EXPOSE 3000

# 6) Arranca el servidor HTTP de Teamwork‑MCP
#    Usa process.env.PORT dentro del código o pásalo aquí:
ENV PORT=${PORT:-3000}
CMD ["node", "build/index.js"]
