FROM node:20-alpine

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependências
RUN npm install --legacy-peer-deps

# Copiar código da aplicação
COPY . .

# Expor portas do Expo
EXPOSE 8081
EXPOSE 19000
EXPOSE 19001
EXPOSE 19002

# Comando para iniciar Expo web
CMD ["npx", "expo", "start", "--web", "--port", "8081"]
