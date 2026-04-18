# Terminal Inteligente - Raspberry Pi 3

Solução automatizada para implantação de terminais Raspberry Pi 3 com acesso remoto via XRDP, splash screen personalizado e dashboard em modo Kiosk.

## 📋 Sumário

- [Instalação Rápida](#-instalação-rápida)
- [Funcionalidades](#-funcionalidades)
- [Pré-requisitos](#-pré-requisitos)
- [Guia de Instalação Detalhado](#-guia-de-instalação-detalhado)
- [Configuração Pós-Instalação](#-configuração-pós-instalação)
- [Acesso Remoto (XRDP)](#-acesso-remoto-xrdp)
- [Clonagem para Múltiplos Terminais](#-clonagem-para-múltiplos-terminais)
- [Troubleshooting](#-troubleshooting)
- [Comandos Úteis](#-comandos-úteis)

---

## 🚀 Instalação Rápida

Execute um único comando no Raspberry Pi 3 com Raspberry Pi OS instalado:

```bash
sudo bash <(curl -sSL https://raw.githubusercontent.com/brendoncarvalho/dashboard-rpi-3/master/install.sh)
```

O script solicitará as URLs de configuração durante a instalação:
- **URL do Dashboard** - Aplicação que será exibida em modo Kiosk
- **URL do Papel de Parede** - Imagem que será aplicada como fundo
- **Logo** - Imagem fixa que será exibida no splash screen (configurada no repositório)

Pronto! Tudo será instalado e configurado automaticamente.

---

## ✨ Funcionalidades

- ✅ **Acesso Remoto (XRDP)** - Gerenciar remotamente via Remote Desktop Connection do Windows, Mac ou Linux
- ✅ **Splash Screen Personalizado** - Logo customizada exibida durante 5 segundos no boot
- ✅ **Papel de Parede Automático** - Atualizado a cada inicialização via URL (PNG, JPG, etc)
- ✅ **Dashboard em Kiosk Mode** - Abre automaticamente em tela cheia, sem barras de ferramentas
- ✅ **Fácil Clonagem** - Mesma imagem para múltiplos terminais
- ✅ **Scripts de Diagnóstico** - Verificar status do terminal e resolver problemas
- ✅ **Configuração Personalizável** - URLs configuráveis durante instalação
- ✅ **Otimização de Boot** - Inicialização limpa e rápida

---

## 📋 Pré-requisitos

### Hardware
- **Raspberry Pi 3** (modelo B, B+ ou compatível)
- **Cartão SD** - 16GB ou 32GB (Classe 10 recomendado)
- **Fonte de alimentação** - 5V/2.5A mínimo
- **Monitor HDMI** - Para exibição do dashboard
- **Teclado e Mouse** (opcional, apenas para configuração inicial)

### Software
- **Raspberry Pi OS 32-bit com Desktop** - Versão atual recomendada
- **Conexão com Internet** - Ethernet ou Wi-Fi
- **Acesso SSH** - Para instalação remota (opcional)

### URLs Necessárias
- **URL do Dashboard** - Aplicação web que será exibida (ex: https://app.brendon.com.br/)
- **URL do Papel de Parede** - Imagem em PNG ou JPG (ex: https://app.brendon.com.br/assets/wallpaper.png)

---

## 🔧 Guia de Instalação Detalhado

### Passo 1: Preparar o Cartão SD

1. **Baixe o Raspberry Pi Imager**
   - Acesse: https://www.raspberrypi.com/software/
   - Selecione seu sistema operacional (Windows, Mac ou Linux)
   - Instale o aplicativo

2. **Insira o Cartão SD no Computador**
   - Use um leitor de cartão SD
   - O cartão será formatado, então faça backup se necessário

3. **Abra o Raspberry Pi Imager**
   - Clique em **Choose OS**
   - Selecione **Raspberry Pi OS (32-bit)** com Desktop
   - Clique em **Choose Storage** e selecione seu cartão SD

4. **Configure as Opções Avançadas** (Importante!)
   - Clique no ícone de engrenagem ⚙️ antes de gravar
   - Marque as seguintes opções:
     - **Set hostname**: `terminal-01` (você mudará depois em cada terminal)
     - **Enable SSH**: Ativado (com autenticação por senha)
     - **Set username and password**: 
       - Username: `pi`
       - Password: escolha uma senha segura
     - **Configure wireless LAN** (se usar Wi-Fi):
       - SSID: nome da sua rede
       - Password: senha da rede
     - **Set locale settings**:
       - Timezone: seu fuso horário
       - Keyboard layout: seu layout

5. **Grave a Imagem**
   - Clique em **Write**
   - Aguarde a conclusão (pode levar 5-10 minutos)

### Passo 2: Instalar no Raspberry Pi

1. **Insira o Cartão SD no Raspberry Pi**
   - Desligue o Raspberry Pi
   - Insira o cartão SD no slot
   - Ligue novamente

2. **Aguarde a Primeira Inicialização**
   - A primeira inicialização pode levar 2-3 minutos
   - Você verá a tela de desktop do Raspberry Pi OS

3. **Conecte à Internet**
   - Se configurou Wi-Fi: conecte automaticamente
   - Se usar Ethernet: conecte o cabo de rede

### Passo 3: Executar o Script de Instalação

#### Opção A: Via SSH (Recomendado para Instalação Remota)

1. **Descubra o IP do Raspberry Pi**
   - Conecte um monitor e abra um terminal (Ctrl+Alt+T)
   - Digite: `hostname -I`
   - Anote o IP (ex: 192.168.1.100)

2. **Conecte via SSH do seu Computador**
   ```bash
   ssh pi@192.168.1.100
   # ou
   ssh pi@terminal-01.local
   ```
   - Digite a senha que configurou

3. **Execute o Script de Instalação**
   ```bash
   sudo bash <(curl -sSL https://raw.githubusercontent.com/brendoncarvalho/dashboard-rpi-3/master/install.sh)
   ```

#### Opção B: Diretamente no Raspberry Pi

1. **Abra um Terminal no Raspberry Pi**
   - Clique no ícone de terminal na barra de tarefas
   - Ou pressione Ctrl+Alt+T

2. **Execute o Script**
   ```bash
   sudo bash <(curl -sSL https://raw.githubusercontent.com/brendoncarvalho/dashboard-rpi-3/master/install.sh)
   ```

### Passo 4: Fornecer as URLs

O script perguntará pelas URLs. Digite com cuidado:

```
Digite a URL do Dashboard (ex: https://app.example.com/dashboard):
> https://seu-dashboard.com

Digite a URL do papel de parede (ex: https://example.com/wallpaper.png):
> https://seu-servidor.com/wallpaper.png
```

### Passo 5: Aguardar a Instalação

- O script instalará todos os pacotes necessários
- Isso pode levar 5-15 minutos dependendo da conexão
- Você verá mensagens de progresso na tela

### Passo 6: Reiniciar o Raspberry Pi

Após a instalação, reinicie:

```bash
sudo reboot
```

---

## 🎯 Configuração Pós-Instalação

### O Que Acontece na Primeira Inicialização

1. **Splash Screen** (5 segundos)
   - Sua logo será exibida no centro da tela
   - Isso indica que o terminal está inicializando

2. **Papel de Parede**
   - A imagem do papel de parede será baixada e aplicada
   - Você verá o desktop com o papel de parede personalizado

3. **Dashboard em Kiosk Mode**
   - O Chromium abrirá automaticamente em tela cheia
   - Seu dashboard será exibido sem barras de ferramentas
   - O cursor do mouse desaparecerá após 5 segundos de inatividade

### Verificar se Tudo Funciona

```bash
/opt/terminal/diagnose.sh
```

Este comando mostrará:
- ✓ XRDP está rodando
- ✓ Chromium instalado
- ✓ Logo encontrada
- ✓ Papel de parede encontrado
- ✓ Internet conectada
- ✓ URLs configuradas

---

## 📱 Acesso Remoto (XRDP)

### Windows

1. **Abra Remote Desktop Connection**
   - Pressione `Windows + R`
   - Digite: `mstsc.exe`
   - Pressione Enter

2. **Conecte ao Raspberry Pi**
   - **Computer**: `terminal-01.local` ou `192.168.1.100`
   - Clique em **Connect**

3. **Faça Login**
   - **Username**: `pi`
   - **Password**: sua senha
   - Clique em **OK**

4. **Acesso Concedido**
   - Você terá acesso à área de trabalho completa
   - Pode fazer manutenção sem interromper o dashboard no monitor

### Mac

1. **Instale um Cliente RDP**
   - Microsoft Remote Desktop (gratuito na App Store)
   - Ou use: `rdesktop` via Homebrew

2. **Conecte**
   ```bash
   rdesktop -u pi terminal-01.local
   ```

3. **Digite a Senha**
   - Sua senha do Raspberry Pi

### Linux

1. **Instale o Cliente RDP**
   ```bash
   sudo apt-get install rdesktop
   ```

2. **Conecte**
   ```bash
   rdesktop -u pi terminal-01.local
   ```

---

## 🔄 Clonagem para Múltiplos Terminais

Se você precisa de vários terminais com a mesma configuração, siga este processo:

### Passo 1: Preparar a Imagem Mestre

1. Configure o primeiro terminal conforme acima
2. Teste todas as funcionalidades
3. Desligue o Raspberry Pi:
   ```bash
   sudo shutdown -h now
   ```

### Passo 2: Criar Imagem de Clonagem

**Windows:**
1. Baixe **Win32 Disk Imager**: https://sourceforge.net/projects/win32diskimager/
2. Insira o cartão SD no computador
3. Abra Win32 Disk Imager
4. Selecione o cartão SD
5. Clique em **Read**
6. Salve como `terminal_master.img`

**Mac/Linux:**
```bash
# Descubra o dispositivo
diskutil list

# Crie a imagem (substitua sdX pelo seu dispositivo)
sudo dd if=/dev/sdX of=terminal_master.img bs=4M
```

### Passo 3: Clonar para Novos Cartões

1. Insira um novo cartão SD no computador
2. Abra **Raspberry Pi Imager**
3. Clique em **Choose OS**
4. Role até o final e selecione **Use custom**
5. Selecione o arquivo `terminal_master.img`
6. Clique em **Choose Storage** e selecione o novo cartão
7. Clique em **Write**
8. Repita para cada novo cartão

### Passo 4: Individualizar Cada Terminal

Cada clone terá o mesmo hostname. Para evitar conflitos:

1. Insira o cartão clonado no Raspberry Pi
2. Ligue o terminal
3. Acesse via SSH:
   ```bash
   ssh pi@terminal-01.local
   ```

4. Execute a ferramenta de configuração:
   ```bash
   sudo raspi-config
   ```

5. Vá em **System Options** > **Hostname**
6. Mude para `terminal-02`, `terminal-03`, etc.
7. Pressione Tab > Select > Enter
8. Reinicie:
   ```bash
   sudo reboot
   ```

---

## 🛠️ Troubleshooting

### Problema: O Dashboard Não Abre

**Sintomas:** Tela preta ou branca, sem dashboard

**Soluções:**
1. Verifique a conexão de internet:
   ```bash
   ping 8.8.8.8
   ```

2. Verifique se a URL está correta:
   ```bash
   curl https://seu-dashboard.com
   ```

3. Reinicie o Chromium:
   ```bash
   sudo systemctl restart chromium
   ```

4. Verifique o diagnóstico:
   ```bash
   /opt/terminal/diagnose.sh
   ```

### Problema: Não Consigo Acessar via SSH

**Sintomas:** "Connection refused" ou "Host unreachable"

**Soluções:**
1. Verifique se o Raspberry Pi está ligado
2. Descubra o IP:
   - Conecte um monitor
   - Abra um terminal (Ctrl+Alt+T)
   - Digite: `hostname -I`

3. Tente com o IP:
   ```bash
   ssh pi@192.168.1.100
   ```

4. Verifique o firewall do seu computador

### Problema: Papel de Parede Não Aparece

**Sintomas:** Desktop com fundo padrão

**Soluções:**
1. Teste o download manual:
   ```bash
   wget https://seu-servidor.com/wallpaper.png
   ```

2. Execute o script manualmente:
   ```bash
   /opt/terminal/scripts/update_wallpaper.sh
   ```

3. Verifique se a imagem existe:
   ```bash
   ls -la ~/Pictures/wallpaper.png
   ```

### Problema: Logo Não Aparece no Splash Screen

**Sintomas:** Tela preta durante boot, sem logo

**Soluções:**
1. Verifique se a logo foi baixada:
   ```bash
   ls -la /opt/splash/
   ```

2. Regenere o splash screen:
   ```bash
   sudo convert /opt/splash/logo.png -resize 320x240 -background white -gravity center -extent 320x240 /opt/splash/splash.png
   ```

3. Reinicie:
   ```bash
   sudo reboot
   ```

### Problema: XRDP Não Conecta

**Sintomas:** Erro de conexão ao tentar acessar remotamente

**Soluções:**
1. Verifique se XRDP está rodando:
   ```bash
   sudo systemctl status xrdp
   ```

2. Reinicie o XRDP:
   ```bash
   sudo systemctl restart xrdp
   ```

3. Verifique a porta:
   ```bash
   sudo netstat -tlnp | grep 3389
   ```

4. Tente com o IP em vez do hostname

---

## 📋 Comandos Úteis

### Diagnóstico

```bash
# Verificar status completo do terminal
/opt/terminal/diagnose.sh

# Verificar se XRDP está rodando
sudo systemctl status xrdp

# Verificar se Chromium está rodando
ps aux | grep chromium

# Verificar conectividade
ping 8.8.8.8

# Ver logs do sistema
sudo journalctl -xe
```

### Manutenção

```bash
# Atualizar papel de parede e logo
/opt/terminal/update.sh

# Reiniciar o terminal
sudo reboot

# Desligar o terminal
sudo shutdown -h now

# Ver configuração atual
cat /opt/terminal/config.sh
```

### Desinstalação

```bash
# Remover completamente a instalação
sudo /opt/terminal/uninstall.sh
```

---

## 📁 Estrutura de Arquivos

```
/opt/terminal/
├── install.sh           # Script de instalação
├── config.sh            # Configurações (gerado automaticamente)
├── update.sh            # Script de atualização
├── diagnose.sh          # Script de diagnóstico
├── uninstall.sh         # Script de desinstalação
└── scripts/
    ├── update_wallpaper.sh    # Atualiza papel de parede
    └── show_splash.sh         # Mostra splash screen

/opt/splash/
├── logo.png             # Logo original
└── splash.png           # Logo redimensionada (320x240)

~/.config/lxsession/LXDE-pi/
└── autostart            # Configuração de autostart
```

---

## 🔐 Segurança

- **URLs Personalizadas**: Você define durante a instalação
- **Sem URLs Públicas**: Nenhuma URL é exposta na documentação
- **Configuração Local**: URLs são salvas apenas em `/opt/terminal/config.sh`
- **Acesso SSH**: Protegido por senha
- **XRDP**: Autenticação por usuário e senha

---

## 📞 Suporte e Problemas

Se encontrar problemas:

1. **Execute o diagnóstico**:
   ```bash
   /opt/terminal/diagnose.sh
   ```

2. **Verifique o Troubleshooting** acima

3. **Abra uma issue** no repositório GitHub com:
   - Descrição do problema
   - Saída do diagnóstico
   - Versão do Raspberry Pi OS
   - Modelo do Raspberry Pi

---

## 📝 Notas Importantes

- **Primeira Inicialização**: Pode levar 2-3 minutos
- **Atualizações**: O script baixa a versão mais recente dos pacotes
- **Clonagem**: Todos os clones terão o mesmo hostname - altere conforme instruído
- **Papel de Parede**: Atualizado a cada boot - certifique-se de que a URL está sempre acessível
- **Logo**: Fixa em todas as instalações

---

## 📄 Licença

Este projeto é fornecido como está para uso com terminais inteligentes.

---

**Compatível com:** Raspberry Pi 3 com Raspberry Pi OS 32-bit
**Última atualização:** 2026
**Versão:** 1.0.0
