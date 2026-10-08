# Utiliser une image de base Node.js légère (Alpine Linux)
FROM node:18-alpine

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier les fichiers de dépendances (package.json)
COPY package.json ./

# Installer les dépendances
RUN npm install

# Copier le reste du code de l'application
COPY . .

# Exposer le port sur lequel l'application tourne
EXPOSE 3000

# Commande pour démarrer l'application
CMD ["node", "index.js"]
