#!/bin/bash

# Script para baixar e aplicar o papel de parede automaticamente
# Lê a URL da configuração salva durante a instalação

# Carregar configuração
if [ -f "/opt/terminal/config.sh" ]; then
    source /opt/terminal/config.sh
else
    echo "Erro: Arquivo de configuração não encontrado"
    exit 1
fi

WALLPAPER_PATH="$HOME/Pictures/wallpaper.png"

# Criar diretório se não existir
mkdir -p "$HOME/Pictures"

# Baixar a imagem
wget -q -O "$WALLPAPER_PATH" "$WALLPAPER_URL" 2>/dev/null

# Verificar se o download foi bem-sucedido
if [ $? -eq 0 ] && [ -f "$WALLPAPER_PATH" ]; then
    # Aplicar o papel de parede usando pcmanfm
    pcmanfm --set-wallpaper="$WALLPAPER_PATH" --wallpaper-mode=stretch 2>/dev/null
else
    # Se falhar, tentar novamente com curl
    curl -s -o "$WALLPAPER_PATH" "$WALLPAPER_URL" 2>/dev/null
    if [ $? -eq 0 ]; then
        pcmanfm --set-wallpaper="$WALLPAPER_PATH" --wallpaper-mode=stretch 2>/dev/null
    fi
fi
