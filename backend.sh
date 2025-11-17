#!/bin/bash

# Script helper para Backend FixItNow
# Uso: ./backend.sh [comando]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de ayuda
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Mostrar uso
show_usage() {
    cat << EOF
FixItNow Backend - Helper Script

Uso: ./backend.sh [comando]

Comandos disponibles:

  Docker:
    up              Levantar solo backend (requiere PostgreSQL)
    down            Detener backend
    build           Reconstruir imagen del backend
    rebuild         Detener, reconstruir y levantar
    logs            Ver logs del backend
    restart         Reiniciar backend
    shell           Abrir shell en contenedor backend

  Base de Datos:
    migrate         Crear y aplicar migraciones
    migrate-deploy  Aplicar migraciones en producción
    migrate-reset   Resetear BD y aplicar migraciones (⚠️  BORRA DATOS)
    seed            Ejecutar seeds
    studio          Abrir Prisma Studio
    db-shell        Conectar a PostgreSQL

  Desarrollo Local (sin Docker):
    dev             Iniciar en modo desarrollo
    build-local     Compilar TypeScript
    start           Iniciar aplicación compilada
    format          Formatear código
    lint            Ejecutar linter
    test            Ejecutar tests

  Información:
    help            Mostrar esta ayuda
    status          Ver estado del backend
    ps              Ver contenedores relacionados

EOF
}

# Detectar ubicación del docker-compose.yml
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_COMPOSE_FILE="${SCRIPT_DIR}/../docker-compose.yml"
DOCKER_COMPOSE_CMD="docker-compose -f ${DOCKER_COMPOSE_FILE}"

# Comandos Docker
cmd_up() {
    print_info "Levantando backend..."
    ${DOCKER_COMPOSE_CMD} up -d app
    print_success "Backend iniciado"
    print_info "Backend API: http://localhost:3000"
}

cmd_down() {
    print_info "Deteniendo backend..."
    ${DOCKER_COMPOSE_CMD} stop app
    print_success "Backend detenido"
}

cmd_build() {
    print_info "Reconstruyendo imagen del backend..."
    ${DOCKER_COMPOSE_CMD} build --no-cache app
    print_success "Imagen reconstruida"
}

cmd_rebuild() {
    print_info "Rebuild completo: stop -> build -> up..."
    ${DOCKER_COMPOSE_CMD} stop app
    ${DOCKER_COMPOSE_CMD} build --no-cache app
    ${DOCKER_COMPOSE_CMD} up -d app
    print_success "Backend reconstruido y levantado"
}

cmd_logs() {
    ${DOCKER_COMPOSE_CMD} logs -f app
}

cmd_restart() {
    print_info "Reiniciando backend..."
    ${DOCKER_COMPOSE_CMD} restart app
    print_success "Backend reiniciado"
}

cmd_shell() {
    print_info "Abriendo shell en backend..."
    ${DOCKER_COMPOSE_CMD} exec app sh
}

# Comandos de Base de Datos
cmd_migrate() {
    print_info "Creando y aplicando migraciones..."
    ${DOCKER_COMPOSE_CMD} exec app npx prisma migrate dev
    print_success "Migraciones aplicadas"
}

cmd_migrate_deploy() {
    print_info "Aplicando migraciones en producción..."
    ${DOCKER_COMPOSE_CMD} exec app npx prisma migrate deploy
    print_success "Migraciones aplicadas"
}

cmd_migrate_reset() {
    print_error "⚠️  ADVERTENCIA: Esto eliminará todos los datos de la base de datos"
    read -p "¿Estás seguro? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${DOCKER_COMPOSE_CMD} exec app npx prisma migrate reset
        print_success "Base de datos reseteada"
    else
        print_info "Operación cancelada"
    fi
}

cmd_seed() {
    print_info "Ejecutando seeds..."
    ${DOCKER_COMPOSE_CMD} exec app node prisma/seed.js
    print_success "Seeds completados"
}

cmd_studio() {
    print_info "Abriendo Prisma Studio..."
    ${DOCKER_COMPOSE_CMD} exec app npx prisma studio
}

cmd_db_shell() {
    print_info "Conectando a PostgreSQL..."
    ${DOCKER_COMPOSE_CMD} exec postgres psql -U fixitnow -d fixitnow
}

# Desarrollo Local (sin Docker)
cmd_dev() {
    print_info "Iniciando backend en modo desarrollo..."
    npm run start:dev
}

cmd_build_local() {
    print_info "Compilando TypeScript..."
    npm run build
    print_success "Compilación completada"
}

cmd_start() {
    print_info "Iniciando aplicación..."
    npm run start:prod
}

cmd_format() {
    print_info "Formateando código..."
    npm run format
    print_success "Código formateado"
}

cmd_lint() {
    print_info "Ejecutando linter..."
    npm run lint
}

cmd_test() {
    print_info "Ejecutando tests..."
    npm test
}

# Información
cmd_status() {
    print_header "Estado del Backend"
    echo ""
    echo "Contenedores:"
    ${DOCKER_COMPOSE_CMD} ps app postgres
    echo ""
    echo "Última migración:"
    ${DOCKER_COMPOSE_CMD} exec app npx prisma migrate status 2>/dev/null || echo "No disponible"
}

cmd_ps() {
    ${DOCKER_COMPOSE_CMD} ps
}

# Main
case "$1" in
    # Docker
    up) cmd_up ;;
    down) cmd_down ;;
    build) cmd_build ;;
    rebuild) cmd_rebuild ;;
    logs) cmd_logs ;;
    restart) cmd_restart ;;
    shell) cmd_shell ;;

    # Database
    migrate) cmd_migrate ;;
    migrate-deploy) cmd_migrate_deploy ;;
    migrate-reset) cmd_migrate_reset ;;
    seed) cmd_seed ;;
    studio) cmd_studio ;;
    db-shell) cmd_db_shell ;;

    # Local Dev
    dev) cmd_dev ;;
    build-local) cmd_build_local ;;
    start) cmd_start ;;
    format) cmd_format ;;
    lint) cmd_lint ;;
    test) cmd_test ;;

    # Info
    status) cmd_status ;;
    ps) cmd_ps ;;
    help|--help|-h) show_usage ;;

    *)
        print_error "Comando desconocido: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
