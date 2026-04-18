#!/bin/bash

# Script de instalação para Terminais Inteligentes
# Uso: sudo bash install.sh [DASHBOARD_URL] [WALLPAPER_URL]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cor
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Header
echo ""
print_header "╔════════════════════════════════════════════════════════╗"
print_header "║        Instalação - Terminal Inteligente              ║"
print_header "╚════════════════════════════════════════════════════════╝"
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    print_error "Este script deve ser executado com sudo"
    echo "Tente: sudo bash install.sh"
    exit 1
fi

# Definir variáveis
INSTALL_DIR="/opt/terminal"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
USER_HOME="/home/$(logname)"
CURRENT_USER=$(logname)

# Parâmetros de entrada (com valores padrão vazios)
DASHBOARD_URL="${1:-}"
WALLPAPER_URL="${2:-}"

# Logo fixa (não customizável)
LOGO_URL="https://app.brendon.com.br/logo.png"

# Função para validar URL
validate_url() {
    local url=$1
    if [[ $url =~ ^https?:// ]]; then
        return 0
    else
        return 1
    fi
}

# Solicitar URLs se não forem fornecidas
print_info "Configuração de URLs"
echo ""

if [ -z "$DASHBOARD_URL" ]; then
    echo -e "${YELLOW}Digite a URL do Dashboard (ex: https://app.example.com/dashboard):${NC}"
    read -p "> " DASHBOARD_URL
    while ! validate_url "$DASHBOARD_URL"; do
        print_error "URL inválida. Deve começar com http:// ou https://"
        read -p "> " DASHBOARD_URL
    done
fi

if [ -z "$WALLPAPER_URL" ]; then
    echo -e "${YELLOW}Digite a URL do papel de parede (ex: https://example.com/wallpaper.png):${NC}"
    read -p "> " WALLPAPER_URL
    while ! validate_url "$WALLPAPER_URL"; do
        print_error "URL inválida. Deve começar com http:// ou https://"
        read -p "> " WALLPAPER_URL
    done
fi



echo ""
print_status "Configuração de URLs:"
echo "  Dashboard: $DASHBOARD_URL"
echo "  Papel de Parede: $WALLPAPER_URL"
echo "  Logo: $LOGO_URL (fixa)"
echo ""

# Salvar configuração
print_status "Salvando configuração..."
mkdir -p "$INSTALL_DIR"

cat > "$INSTALL_DIR/config.sh" << EOF
#!/bin/bash
# Configurações do Terminal Inteligente
# Gerado automaticamente durante a instalação

DASHBOARD_URL="$DASHBOARD_URL"
WALLPAPER_URL="$WALLPAPER_URL"
LOGO_URL="$LOGO_URL"

INSTALL_DIR="/opt/terminal"
SCRIPTS_DIR="\$INSTALL_DIR/scripts"
SPLASH_DIR="/opt/splash"
EOF

chmod 644 "$INSTALL_DIR/config.sh"

# Criar diretórios
print_status "Criando diretórios..."
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$USER_HOME/terminal_scripts"
mkdir -p "/opt/splash"

# Atualizar sistema
print_status "Atualizando pacotes do sistema..."
apt-get update > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1

# Instalar dependências
print_status "Instalando dependências..."
apt-get install -y \
    xrdp \
    chromium-browser \
    unclutter \
    wget \
    curl \
    feh \
    pcmanfm \
    fbi \
    psplash \
    imagemagick \
    > /dev/null 2>&1

# Configurar XRDP
print_status "Configurando XRDP..."
systemctl enable xrdp > /dev/null 2>&1
systemctl start xrdp > /dev/null 2>&1
adduser $CURRENT_USER ssl-cert 2>/dev/null || true

# Baixar scripts do repositório
print_status "Baixando scripts do repositório..."

REPO_RAW="https://raw.githubusercontent.com/brendoncarvalho/dashboard-rpi-3/master"

wget -q -O "$SCRIPTS_DIR/update_wallpaper.sh" "$REPO_RAW/scripts/update_wallpaper.sh"
chmod +x "$SCRIPTS_DIR/update_wallpaper.sh"

wget -q -O "$SCRIPTS_DIR/show_splash.sh" "$REPO_RAW/scripts/show_splash.sh"
chmod +x "$SCRIPTS_DIR/show_splash.sh"

# Baixar logo
print_status "Baixando logo personalizada..."
wget -q -O "/opt/splash/logo.png" "$LOGO_URL" 2>/dev/null

if [ -f "/opt/splash/logo.png" ]; then
    print_status "Redimensionando logo para splash screen..."
    convert "/opt/splash/logo.png" -resize 320x240 -background white -gravity center -extent 320x240 "/opt/splash/splash.png" > /dev/null 2>&1
else
    print_error "Não foi possível baixar a logo"
fi

# Configurar autostart do LXDE
print_status "Configurando autostart (Kiosk Mode)..."
mkdir -p "$USER_HOME/.config/lxsession/LXDE-pi/"

cat > "$USER_HOME/.config/lxsession/LXDE-pi/autostart" << 'AUTOSTART_EOF'
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash

# Mostrar splash screen com logo
@/opt/splash/show_splash.sh

# Atualizar papel de parede
@/opt/terminal/scripts/update_wallpaper.sh

# Desativar protetor de tela e gerenciamento de energia
@xset s off
@xset s noblank
@xset -dpms

# Ocultar cursor do mouse
@unclutter -idle 5 -root

# Iniciar Chromium em modo Kiosk
@chromium-browser --kiosk --noerrdialogs --disable-infobars --check-for-update-interval=31536000 "DASHBOARD_URL_PLACEHOLDER"
AUTOSTART_EOF

# Substituir placeholder pela URL real
sed -i "s|DASHBOARD_URL_PLACEHOLDER|$DASHBOARD_URL|g" "$USER_HOME/.config/lxsession/LXDE-pi/autostart"

chown $CURRENT_USER:$CURRENT_USER "$USER_HOME/.config/lxsession/LXDE-pi/autostart"

# Otimizar boot
print_status "Otimizando boot..."
if ! grep -q "quiet splash" /boot/cmdline.txt; then
    cp /boot/cmdline.txt /boot/cmdline.txt.bak
    sed -i '$ s/$/ quiet splash loglevel=3 logo.nologo vt.global_cursor_default=0/' /boot/cmdline.txt
fi

# Criar script de atualização
print_status "Criando script de atualização..."
cat > "$INSTALL_DIR/update.sh" << 'UPDATE_EOF'
#!/bin/bash
source /opt/terminal/config.sh

echo "Atualizando configuração do terminal..."

# Atualizar papel de parede
echo "Atualizando papel de parede..."
/opt/terminal/scripts/update_wallpaper.sh

# Atualizar logo
echo "Atualizando logo..."
wget -q -O "/opt/splash/logo.png" "$LOGO_URL" 2>/dev/null
if [ -f "/opt/splash/logo.png" ]; then
    convert "/opt/splash/logo.png" -resize 320x240 -background white -gravity center -extent 320x240 "/opt/splash/splash.png" > /dev/null 2>&1
fi

echo "Atualização concluída!"
UPDATE_EOF

chmod +x "$INSTALL_DIR/update.sh"

# Criar script de diagnóstico
print_status "Criando script de diagnóstico..."
cat > "$INSTALL_DIR/diagnose.sh" << 'DIAGNOSE_EOF'
#!/bin/bash
source /opt/terminal/config.sh

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Diagnóstico - Terminal Inteligente                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "[1] Verificando XRDP..."
if systemctl is-active --quiet xrdp; then
    echo "✓ XRDP está rodando"
else
    echo "✗ XRDP não está rodando"
fi

echo ""
echo "[2] Verificando Chromium..."
if command -v chromium-browser &> /dev/null; then
    echo "✓ Chromium instalado"
else
    echo "✗ Chromium não instalado"
fi

echo ""
echo "[3] Verificando logo..."
if [ -f "/opt/splash/logo.png" ]; then
    echo "✓ Logo encontrada"
else
    echo "✗ Logo não encontrada"
fi

echo ""
echo "[4] Verificando papel de parede..."
if [ -f "$HOME/Pictures/wallpaper.png" ]; then
    echo "✓ Papel de parede encontrado"
else
    echo "✗ Papel de parede não encontrado"
fi

echo ""
echo "[5] Verificando autostart..."
if [ -f "$HOME/.config/lxsession/LXDE-pi/autostart" ]; then
    echo "✓ Autostart configurado"
else
    echo "✗ Autostart não configurado"
fi

echo ""
echo "[6] Testando conectividade..."
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "✓ Internet conectada"
else
    echo "✗ Sem conexão com internet"
fi

echo ""
echo "[7] URLs Configuradas:"
echo "  Dashboard: $DASHBOARD_URL"
echo "  Papel de Parede: $WALLPAPER_URL"
echo "  Logo: $LOGO_URL"
echo ""
DIAGNOSE_EOF

chmod +x "$INSTALL_DIR/diagnose.sh"

# Criar script de desinstalação
print_status "Criando script de desinstalação..."
cat > "$INSTALL_DIR/uninstall.sh" << 'UNINSTALL_EOF'
#!/bin/bash
echo "Desinstalando Terminal Inteligente..."
rm -rf /opt/terminal
rm -rf /opt/splash
systemctl stop xrdp
systemctl disable xrdp
echo "Desinstalação concluída!"
UNINSTALL_EOF

chmod +x "$INSTALL_DIR/uninstall.sh"

# Summary
echo ""
print_header "╔════════════════════════════════════════════════════════╗"
print_header "║   ✓ Instalação Concluída com Sucesso!                ║"
print_header "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Próximos passos:"
echo ""
print_info "1. Reinicie o Raspberry Pi:"
echo "   sudo reboot"
echo ""
print_info "2. Verifique se tudo está funcionando:"
echo "   /opt/terminal/diagnose.sh"
echo ""
print_info "3. Para atualizar configurações:"
echo "   /opt/terminal/update.sh"
echo ""
print_info "4. Para desinstalar:"
echo "   sudo /opt/terminal/uninstall.sh"
echo ""
print_info "5. Acesso remoto (XRDP):"
echo "   Use Remote Desktop Connection do Windows"
echo "   Endereço: $(hostname).local"
echo "   Usuário: $CURRENT_USER"
echo ""
