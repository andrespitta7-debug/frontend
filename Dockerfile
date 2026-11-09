# ==========================================
# SysQuest Frontend: Servidor Web Nginx ultraliviano
# ==========================================
FROM nginx:alpine

# Copiar configuración optimizada de Nginx para SPA Flutter
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los artefactos estáticos compilados de Flutter Web
COPY build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
