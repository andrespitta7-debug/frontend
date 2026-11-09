# ==========================================
# Etapa 1: Compilación de Flutter Web
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copiar archivos de dependencias para aprovechar caché
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiar código fuente
COPY . .

# Argumentos de entorno para conectar con Supabase en tiempo de compilación
ARG SUPABASE_URL=https://jctulgfdweeurqbmugot.supabase.co
ARG SUPABASE_ANON_KEY=""

# Compilar Flutter para Web en modo release con flags de optimización
RUN flutter build web --release \
    --dart-define=SUPABASE_URL=${SUPABASE_URL} \
    --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# ==========================================
# Etapa 2: Servidor Web Nginx ultraliviano
# ==========================================
FROM nginx:alpine

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los artefactos estáticos compilados de Flutter Web
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
