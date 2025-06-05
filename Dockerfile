# Étape 1 : Build avec Node.js (léger)
FROM node:18-alpine AS builder

# Réduire la taille des dépendances et des couches intermédiaires
ENV NODE_ENV=production

WORKDIR /app

COPY package*.json ./

RUN npm ci --prefer-offline --no-audit

COPY . .

RUN npm run build

# Étape 2 : Image finale ultra légère avec NGINX
FROM nginx:stable-alpine

# Supprimer les fichiers de conf par défaut
RUN rm -rf /usr/share/nginx/html/*

# Copier uniquement le build final (léger)
COPY --from=builder /app/build /usr/share/nginx/html

# (Optionnel) Personnaliser la config nginx si nécessaire
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
