# ==========================================
# Servidor Web Nginx ultraliviano para SysQuest Frontend
# ==========================================
FROM nginx:alpine

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar artefactos estáticos compilados de Flutter Web
COPY build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
