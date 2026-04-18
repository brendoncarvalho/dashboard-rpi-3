#!/bin/bash

# Script para mostrar splash screen com logo personalizada
# Parte do projeto Pemill - Terminais Raspberry Pi 3

SPLASH_IMAGE="/opt/splash/splash.png"

if [ -f "$SPLASH_IMAGE" ]; then
    fbi -T 1 -noverbose -a "$SPLASH_IMAGE" 2>/dev/null &
    FBI_PID=$!
    sleep 5
    kill $FBI_PID 2>/dev/null
fi
