#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then
  echo "🚫 Este script precisa ser executado como root (use: sudo ./install.sh)"
  exit 1
fi

rm -rf /var/www/botzap-mk-auth
clear

curl --version | grep "curl"
if [ $? -eq 0 ]
then
  echo "Curl já instalado."
else
  echo "Instalando Curl..."
  sudo apt install curl 
  echo "Instalação concluida do Curl!"
fi

clear
node -v | grep "v16"
if [ $? -eq 0 ]
then
  echo "NodeJS V16 já instalado."
else
  echo "Instalando NodeJS..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

  sleep 2
  nvm install 16.20.2
  nvm use 16.20.2
  echo "Instalação concluida do NodeJS!"
fi

clear
pm2 -v
if [ $? -eq 0 ]
then
  echo "PM2 já instalado!"
else
  echo "Instalando pm2..."
  npm install pm2@latest -g
  pm2 install pm2-logrotate
  pm2 set pm2-logrotate:max_size 50M
  pm2 set pm2-logrotate:retain 10
  pm2 set pm2-logrotate:compress true
  echo "Instalação concluida do PM2!"
fi

clear
echo "Baixando nova API..."
rm -rf botzap-mk-auth-api-main/
rm -rf botzap-mk-auth-api-main
rm -rf botzap-mk-auth-api
rm -rf botzap-mk-auth-api.zip
wget --no-check-certificate -O botzap-mk-auth-api.zip https://github.com/tonvital/botzap-mk-auth-api/archive/main.zip && unzip -o botzap-mk-auth-api.zip

clear
echo "Instalando API..."
cd botzap-mk-auth-api-main
npm install

clear
pm2 stop api
pm2 delete api
pm2 start pm2-run.json --exp-backoff-restart-delay=100
pm2 save
pm2 startup
pm2 save

clear
echo "Checando API..."
sleep 5

curl -Is http://localhost:9657/botzap-mk-auth?f=heathCheck | grep "200"

if [ $? -eq 0 ]
then
echo "API botzap-mk-auth foi instalada com sucesso!"
else
echo "Oops! Algo deu errado na instalação!!!"
fi

pm2 status
