# =========================
# Stage 1 : Build React
# =========================
FROM node:18-alpine AS builder

WORKDIR /app

# نستغل Docker cache
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

# ننسخو السورس بعد
COPY . .

# Build React
RUN npm run build


# =========================
# Stage 2 : Nginx Runtime
# =========================
FROM nginx:stable-alpine

# تنظيف default files
RUN rm -rf /usr/share/nginx/html/*

# نسخو build فقط
COPY --from=builder /app/build /usr/share/nginx/html

# Healthcheck (اختياري)
HEALTHCHECK CMD wget -qO- http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
