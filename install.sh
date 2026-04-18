#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ps() { echo -e "${GREEN}[✓]${NC} $1"; }
pi() { echo -e "${YELLOW}[i]${NC} $1"; }
pe() { echo -e "${RED}[✗]${NC} $1"; }
ph() { echo -e "${BLUE}$1${NC}"; }

echo ""
ph "╔════════════════════════════════════════════════════════╗"
ph "║        Instalação - Terminal Inteligente              ║"
ph "╚════════════════════════════════════════════════════════╝"
echo ""

[ "$EUID" -eq 0 ] || { pe "Execute com sudo"; exit 1; }

INSTALL_DIR="/opt/terminal"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
USER_HOME="/home/$(logname)"
CURRENT_USER=$(logname)
DASHBOARD_URL="${1:-}"
WALLPAPER_URL="${2:-}"
LOGO_URL="https://app.brendon.com.br/logo.png"

validate_url() { [[ $1 =~ ^https?:// ]]; }

pi "Configuração de URLs"
echo ""

if [ -z "$DASHBOARD_URL" ]; then
    echo -e "${YELLOW}Digite a URL do Dashboard:${NC}"
    read -p "> " DASHBOARD_URL
    while ! validate_url "$DASHBOARD_URL"; do
        pe "URL inválida"
        read -p "> " DASHBOARD_URL
    done
fi

if [ -z "$WALLPAPER_URL" ]; then
    echo -e "${YELLOW}Digite a URL do papel de parede:${NC}"
    read -p "> " WALLPAPER_URL
    while ! validate_url "$WALLPAPER_URL"; do
        pe "URL inválida"
        read -p "> " WALLPAPER_URL
    done
fi

echo ""
ps "URLs configuradas:"
echo "  Dashboard: $DASHBOARD_URL"
echo "  Papel de Parede: $WALLPAPER_URL"
echo "  Logo: $LOGO_URL (fixa)"
echo ""

ps "Criando diretórios..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "/opt/splash"
mkdir -p "$USER_HOME/.config/lxsession/LXDE-pi"
mkdir -p "$USER_HOME/Pictures"

ps "Salvando configuração..."
cat > "$INSTALL_DIR/config.sh" << EOF
DASHBOARD_URL="$DASHBOARD_URL"
WALLPAPER_URL="$WALLPAPER_URL"
LOGO_URL="$LOGO_URL"
INSTALL_DIR="/opt/terminal"
SCRIPTS_DIR="\$INSTALL_DIR/scripts"
SPLASH_DIR="/opt/splash"
EOF
chmod 644 "$INSTALL_DIR/config.sh"

ps "Atualizando sistema..."
apt-get update -qq
apt-get upgrade -y -qq

ps "Instalando dependências..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
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
    lxsession \
    lxde-core

ps "Configurando XRDP..."
systemctl enable xrdp 2>/dev/null || true
systemctl start xrdp 2>/dev/null || true
usermod -aG ssl-cert $CURRENT_USER 2>/dev/null || true

ps "Criando scripts..."
cat > "$SCRIPTS_DIR/update_wallpaper.sh" << 'WALLPAPER'
#!/bin/bash
[ -f "/opt/terminal/config.sh" ] && source /opt/terminal/config.sh || exit 1
WALLPAPER_PATH="$HOME/Pictures/wallpaper.png"
mkdir -p "$HOME/Pictures"
wget -q -O "$WALLPAPER_PATH" "$WALLPAPER_URL" 2>/dev/null || curl -s -o "$WALLPAPER_PATH" "$WALLPAPER_URL" 2>/dev/null
if [ -f "$WALLPAPER_PATH" ]; then
    DISPLAY=:0 pcmanfm --set-wallpaper="$WALLPAPER_PATH" --wallpaper-mode=stretch 2>/dev/null || true
fi
WALLPAPER

cat > "$SCRIPTS_DIR/show_splash.sh" << 'SPLASH'
#!/bin/bash
SPLASH_IMAGE="/opt/splash/splash.png"
if [ -f "$SPLASH_IMAGE" ]; then
    DISPLAY=:0 fbi -T 1 -noverbose -a "$SPLASH_IMAGE" 2>/dev/null &
    FBI_PID=$!
    sleep 5
    kill $FBI_PID 2>/dev/null || true
fi
SPLASH

chmod +x "$SCRIPTS_DIR/update_wallpaper.sh" "$SCRIPTS_DIR/show_splash.sh"

ps "Baixando logo..."
wget -q -O "/opt/splash/logo.png" "$LOGO_URL" 2>/dev/null || curl -s -o "/opt/splash/logo.png" "$LOGO_URL" 2>/dev/null
if [ -f "/opt/splash/logo.png" ]; then
    ps "Redimensionando logo..."
    convert "/opt/splash/logo.png" -resize 320x240 -background white -gravity center -extent 320x240 "/opt/splash/splash.png" 2>/dev/null || true
fi

ps "Configurando autostart..."
cat > "$USER_HOME/.config/lxsession/LXDE-pi/autostart" << AUTOSTART
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@/opt/terminal/scripts/show_splash.sh
@sleep 6
@/opt/terminal/scripts/update_wallpaper.sh
@xset s off
@xset s noblank
@xset -dpms
@unclutter -idle 5 -root
@chromium-browser --kiosk --noerrdialogs --disable-infobars --check-for-update-interval=31536000 "$DASHBOARD_URL"
AUTOSTART

chown -R $CURRENT_USER:$CURRENT_USER "$USER_HOME/.config"
chmod 644 "$USER_HOME/.config/lxsession/LXDE-pi/autostart"

ps "Otimizando boot..."
if [ -f /boot/cmdline.txt ]; then
    if ! grep -q "quiet splash" /boot/cmdline.txt; then
        cp /boot/cmdline.txt /boot/cmdline.txt.bak
        sed -i '$ s/$/ quiet splash loglevel=3 logo.nologo vt.global_cursor_default=0/' /boot/cmdline.txt || true
    fi
fi

ps "Criando scripts auxiliares..."
cat > "$INSTALL_DIR/update.sh" << 'UPDATE'
#!/bin/bash
source /opt/terminal/config.sh
echo "Atualizando..."
/opt/terminal/scripts/update_wallpaper.sh
wget -q -O "/opt/splash/logo.png" "$LOGO_URL" 2>/dev/null || curl -s -o "/opt/splash/logo.png" "$LOGO_URL" 2>/dev/null
if [ -f "/opt/splash/logo.png" ]; then
    convert "/opt/splash/logo.png" -resize 320x240 -background white -gravity center -extent 320x240 "/opt/splash/splash.png" 2>/dev/null || true
fi
echo "Concluído!"
UPDATE

cat > "$INSTALL_DIR/diagnose.sh" << 'DIAGNOSE'
#!/bin/bash
source /opt/terminal/config.sh 2>/dev/null || true
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Diagnóstico - Terminal Inteligente                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
systemctl is-active --quiet xrdp && echo "✓ XRDP rodando" || echo "✗ XRDP não rodando"
echo ""
command -v chromium-browser &>/dev/null && echo "✓ Chromium instalado" || echo "✗ Chromium não instalado"
echo ""
[ -f "/opt/splash/logo.png" ] && echo "✓ Logo encontrada" || echo "✗ Logo não encontrada"
echo ""
[ -f "$HOME/Pictures/wallpaper.png" ] && echo "✓ Papel de parede encontrado" || echo "✗ Papel de parede não encontrado"
echo ""
[ -f "$HOME/.config/lxsession/LXDE-pi/autostart" ] && echo "✓ Autostart configurado" || echo "✗ Autostart não configurado"
echo ""
ping -c 1 8.8.8.8 &>/dev/null && echo "✓ Internet conectada" || echo "✗ Sem internet"
echo ""
[ -f /opt/terminal/config.sh ] && {
    echo "URLs Configuradas:"
    echo "  Dashboard: $(grep DASHBOARD_URL /opt/terminal/config.sh | cut -d'"' -f2)"
    echo "  Papel de Parede: $(grep WALLPAPER_URL /opt/terminal/config.sh | cut -d'"' -f2)"
    echo "  Logo: $(grep LOGO_URL /opt/terminal/config.sh | cut -d'"' -f2)"
}
echo ""
DIAGNOSE

cat > "$INSTALL_DIR/uninstall.sh" << 'UNINSTALL'
#!/bin/bash
echo "Desinstalando..."
rm -rf /opt/terminal /opt/splash
systemctl stop xrdp 2>/dev/null || true
systemctl disable xrdp 2>/dev/null || true
echo "Concluído!"
UNINSTALL

chmod +x "$INSTALL_DIR/update.sh" "$INSTALL_DIR/diagnose.sh" "$INSTALL_DIR/uninstall.sh"

echo ""
ph "╔════════════════════════════════════════════════════════╗"
ph "║   ✓ Instalação Concluída com Sucesso!                ║"
ph "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Próximos passos:"
echo ""
pi "1. Reinicie: sudo reboot"
pi "2. Diagnóstico: /opt/terminal/diagnose.sh"
pi "3. Atualizar: /opt/terminal/update.sh"
pi "4. Desinstalar: sudo /opt/terminal/uninstall.sh"
pi "5. XRDP: $(hostname).local"
echo ""
