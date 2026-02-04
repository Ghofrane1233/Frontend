# -------------------------------
# Étape 1 : Builder (Node)
# -------------------------------
FROM node:18-alpine AS builder

# Définir le dossier de travail
WORKDIR /app

# Copier seulement les fichiers de dépendances pour utiliser le cache Docker
COPY package*.json ./

# Installer les dépendances de production uniquement + cache npm
RUN npm ci --only=production --cache /tmp/.npm-cache

# Copier le reste du code source
COPY . .

# Build React en mode production
RUN npm run build

# -------------------------------
# Étape 2 : Image finale (Nginx)
# -------------------------------
FROM nginx:stable-alpine

# Labels pour info
LABEL maintainer="Ghofrane <ghofrane@example.com>" \
      version="1.0" \
      description="Frontend React build with nginx"

# Copier le build React depuis l'étape builder
COPY --from=builder /app/build /usr/share/nginx/html

# Exposer le port HTTP
EXPOSE 80

# Commande par défaut pour lancer nginx
CMD ["nginx", "-g", "daemon off;"]
