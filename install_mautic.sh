#!/bin/bash

# ===================================================================
# Script de Instalação Automatizada do Mautic
# Versão: 1.0
# Autor: Rhafaman
# ===================================================================

set -e  # Parar execução em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}====================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}====================================================================${NC}"
}

# Função para validar se o comando existe
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "Comando '$1' não encontrado. Por favor, instale antes de continuar."
        exit 1
    fi
}

# Validar dependências
print_header "Verificando Dependências"
check_command "composer"
check_command "php"
check_command "mysql"

# Configurações padrão
DEFAULT_VERSION="6.0.3"
DEFAULT_DB_HOST="localhost"
DEFAULT_DB_PORT="3306"
DEFAULT_ADMIN_FIRSTNAME="Dev"
DEFAULT_ADMIN_LASTNAME="Master"
DEFAULT_ADMIN_USERNAME="dev"
DEFAULT_ADMIN_EMAIL="dev@exemplo.com.br"

# Banner ASCII do Mautic
print_mautic_banner() {
    echo -e "${BLUE}"
    echo "============================================================================="
    echo " ███╗   ███╗ █████╗ ██╗   ██╗████████╗██╗ ██████╗"
    echo " ████╗ ████║██╔══██╗██║   ██║╚══██╔══╝██║██╔════╝"
    echo " ██╔████╔██║███████║██║   ██║   ██║   ██║██║     "
    echo " ██║╚██╔╝██║██╔══██║██║   ██║   ██║   ██║██║     "
    echo " ██║ ╚═╝ ██║██║  ██║╚██████╔╝   ██║   ██║╚██████╗"
    echo " ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝ ╚═════╝"
    echo ""
    echo "           🚀 INSTALADOR AUTOMATIZADO v6.0+ 🚀"
    echo "               Marketing Automation Platform"
    echo "============================================================================="
    echo -e "${NC}"
}

print_mautic_banner
print_header "Instalador do Mautic - Stafebank"

# Coleta de informações
echo ""
print_message "=== CONFIGURAÇÃO DA VERSÃO ==="
read -p "Versão do Mautic (padrão: $DEFAULT_VERSION): " MAUTIC_VERSION
MAUTIC_VERSION=${MAUTIC_VERSION:-$DEFAULT_VERSION}

echo ""
print_message "=== CONFIGURAÇÃO DO PROJETO ==="
read -p "Nome do diretório do projeto (padrão: mautic): " PROJECT_DIR
PROJECT_DIR=${PROJECT_DIR:-mautic}

read -p "URL do site (ex: https://mkt.seu-domínio.com.br): " SITE_URL
if [ -z "$SITE_URL" ]; then
    print_error "URL do site é obrigatória!"
    exit 1
fi

echo ""
print_message "=== CONFIGURAÇÃO DO BANCO DE DADOS ==="
read -p "Host do banco (padrão: $DEFAULT_DB_HOST): " DB_HOST
DB_HOST=${DB_HOST:-$DEFAULT_DB_HOST}

read -p "Porta do banco (padrão: $DEFAULT_DB_PORT): " DB_PORT
DB_PORT=${DB_PORT:-$DEFAULT_DB_PORT}

read -p "Nome do banco de dados: " DB_NAME
if [ -z "$DB_NAME" ]; then
    print_error "Nome do banco de dados é obrigatório!"
    exit 1
fi

read -p "Usuário do banco: " DB_USER
if [ -z "$DB_USER" ]; then
    print_error "Usuário do banco é obrigatório!"
    exit 1
fi

read -s -p "Senha do banco: " DB_PASSWORD
echo ""
if [ -z "$DB_PASSWORD" ]; then
    print_error "Senha do banco é obrigatória!"
    exit 1
fi

echo ""
print_message "=== CONFIGURAÇÃO DO ADMINISTRADOR ==="
read -p "Primeiro nome do admin (padrão: $DEFAULT_ADMIN_FIRSTNAME): " ADMIN_FIRSTNAME
ADMIN_FIRSTNAME=${ADMIN_FIRSTNAME:-$DEFAULT_ADMIN_FIRSTNAME}

read -p "Sobrenome do admin (padrão: $DEFAULT_ADMIN_LASTNAME): " ADMIN_LASTNAME
ADMIN_LASTNAME=${ADMIN_LASTNAME:-$DEFAULT_ADMIN_LASTNAME}

read -p "Username do admin (padrão: $DEFAULT_ADMIN_USERNAME): " ADMIN_USERNAME
ADMIN_USERNAME=${ADMIN_USERNAME:-$DEFAULT_ADMIN_USERNAME}

read -p "Email do admin (padrão: $DEFAULT_ADMIN_EMAIL): " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-$DEFAULT_ADMIN_EMAIL}

read -s -p "Senha do admin: " ADMIN_PASSWORD
echo ""
if [ -z "$ADMIN_PASSWORD" ]; then
    print_error "Senha do administrador é obrigatória!"
    exit 1
fi

echo ""
print_warning "=== RESUMO DA CONFIGURAÇÃO ==="
echo "Versão: $MAUTIC_VERSION"
echo "Diretório: $PROJECT_DIR"
echo "URL: $SITE_URL"
echo "Banco: $DB_USER@$DB_HOST:$DB_PORT/$DB_NAME"
echo "Admin: $ADMIN_FIRSTNAME $ADMIN_LASTNAME ($ADMIN_USERNAME - $ADMIN_EMAIL)"
echo ""

read -p "Deseja continuar com a instalação? (s/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Ss]$ ]]; then
    print_warning "Instalação cancelada pelo usuário."
    exit 0
fi

print_header "Iniciando Instalação do Mautic"

# Verificar se o diretório já existe
if [ -d "$PROJECT_DIR" ]; then
    print_warning "Diretório '$PROJECT_DIR' já existe!"
    read -p "Deseja remover e continuar? (s/N): " REMOVE_DIR
    if [[ $REMOVE_DIR =~ ^[Ss]$ ]]; then
        print_message "Removendo diretório existente..."
        rm -rf "$PROJECT_DIR"
    else
        print_error "Instalação cancelada."
        exit 1
    fi
fi

# Criar projeto Mautic
print_message "Criando projeto Mautic versão $MAUTIC_VERSION..."
composer create-project mautic/recommended-project:^$MAUTIC_VERSION $PROJECT_DIR

# Entrar no diretório do projeto
cd $PROJECT_DIR

print_message "Instalando dependências..."
composer install --no-dev --optimize-autoloader

print_message "Configurando permissões básicas..."
chmod -R 755 .
chmod -R 775 var/ config/

# Verificar se estamos rodando como root para configurar www-data
if [ "$EUID" -eq 0 ]; then
    print_message "Configurando proprietário dos arquivos para www-data..."
    chown -R www-data:www-data .
else
    print_warning "Não é possível configurar proprietário www-data (não executando como root)"
fi

print_message "Executando instalação do Mautic..."
php bin/console mautic:install \
  "$SITE_URL" \
  --db_driver=pdo_mysql \
  --db_host="$DB_HOST" \
  --db_port="$DB_PORT" \
  --db_name="$DB_NAME" \
  --db_user="$DB_USER" \
  --db_password="$DB_PASSWORD" \
  --admin_firstname="$ADMIN_FIRSTNAME" \
  --admin_lastname="$ADMIN_LASTNAME" \
  --admin_username="$ADMIN_USERNAME" \
  --admin_email="$ADMIN_EMAIL" \
  --admin_password="$ADMIN_PASSWORD" \
  --force \
  --no-interaction

print_message "Limpando e aquecendo cache..."
php bin/console cache:clear --env=prod
php bin/console cache:warmup --env=prod

print_message "Configurando permissões finais..."
# Permissões básicas para arquivos e diretórios
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

# Permissões especiais para diretórios específicos
chmod -R 775 var/ config/ media/ var/cache/

# Verificar se os diretórios existem antes de alterar permissões
if [ -d "var/cache/prod" ]; then
    chmod -R 775 var/cache/prod
fi

# Permissões específicas para escrita
print_message "Configurando permissões de escrita..."
chmod -R 775 media/files media/images translations var/cache var/logs

# Verificar se config/local.php existe
if [ -f "config/local.php" ]; then
    chmod 664 config/local.php
fi

# Configurar proprietário se executando como root
if [ "$EUID" -eq 0 ]; then
    chown -R www-data:www-data var/ config/ media/
fi

print_message "Recarregando plugins..."
php bin/console mautic:plugins:reload

print_header "Instalação Concluída com Sucesso!"

echo ""
print_message "=== INFORMAÇÕES DA INSTALAÇÃO ==="
echo "Diretório: $(pwd)"
echo "URL do site: $SITE_URL"
echo "Usuário admin: $ADMIN_USERNAME"
echo "Email admin: $ADMIN_EMAIL"
echo ""
print_message "=== PRÓXIMOS PASSOS ==="
echo "1. Configure seu servidor web para apontar para este diretório"
echo "2. Certifique-se de que o domínio $SITE_URL está configurado"
echo "3. Acesse $SITE_URL para começar a usar o Mautic"
echo ""
print_warning "=== IMPORTANTE ==="
echo "- Guarde as credenciais de acesso em local seguro"
echo "- Configure backups regulares do banco de dados"
echo "- Mantenha o Mautic sempre atualizado"
echo ""

print_message "Instalação finalizada! 🎉" 