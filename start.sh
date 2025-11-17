#!/bin/bash

# FixItNow Backend - Script de inicio simple
# Este script inicia el backend en modo desarrollo LOCAL (sin Docker)

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  FixItNow Backend - Inicio${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: No se encuentra package.json${NC}"
    echo -e "${RED}Ejecuta este script desde el directorio backend${NC}"
    exit 1
fi

# Verificar si PostgreSQL está corriendo
echo -e "${YELLOW}[1/4]${NC} Verificando PostgreSQL..."
if ! docker ps | grep -q "fixitnow-postgres"; then
    echo -e "${YELLOW}PostgreSQL no está corriendo. Iniciando contenedor...${NC}"
    docker-compose up -d postgres
    echo -e "${GREEN}✓${NC} PostgreSQL iniciado"
    echo -e "${YELLOW}Esperando 5 segundos para que PostgreSQL esté listo...${NC}"
    sleep 5
else
    echo -e "${GREEN}✓${NC} PostgreSQL ya está corriendo"
fi

# Verificar si node_modules existe
if [ ! -d "node_modules" ]; then
    echo ""
    echo -e "${YELLOW}[2/4]${NC} Instalando dependencias..."
    npm install
    echo -e "${GREEN}✓${NC} Dependencias instaladas"
else
    echo ""
    echo -e "${YELLOW}[2/4]${NC} Dependencias ya instaladas"
fi

# Verificar migraciones de Prisma
echo ""
echo -e "${YELLOW}[3/4]${NC} Verificando migraciones de base de datos..."
if ! npx prisma migrate status 2>/dev/null | grep -q "Database schema is up to date"; then
    echo -e "${YELLOW}Aplicando migraciones...${NC}"
    npx prisma migrate deploy
    echo -e "${GREEN}✓${NC} Migraciones aplicadas"
else
    echo -e "${GREEN}✓${NC} Base de datos actualizada"
fi

# Generar Prisma Client
echo ""
echo -e "${YELLOW}[4/4]${NC} Generando Prisma Client..."
npx prisma generate
echo -e "${GREEN}✓${NC} Prisma Client generado"

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Iniciando servidor de desarrollo${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${YELLOW}Backend:${NC} http://localhost:3000"
echo -e "${YELLOW}Base de datos:${NC} PostgreSQL en localhost:5432"
echo ""
echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
echo ""

# Iniciar servidor
npm run start:dev
