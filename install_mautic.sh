#!/bin/bash

# ===================================================================
# Script de Instalação Automatizada do Mautic
# Versão: 2.5 - Com lista completa de permissões oficiais
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

# Função para verificar se estamos no diretório correto do Mautic
verify_mautic_directory() {
    if [ ! -f "composer.json" ]; then
        print_error "ERRO: Não estamos no diretório do Mautic!"
        print_error "Diretório atual: $(pwd)"
        print_error "Arquivos esperados: composer.json e bin/console"
        exit 1
    fi
    print_message "✓ Confirmado: estamos no diretório do Mautic ($(pwd))"
}

# Função para validar se o comando existe
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "Comando '$1' não encontrado. Por favor, instale antes de continuar."
        exit 1
    fi
    print_message "✓ $1 encontrado"
}

# Função para criar diretório se não existir
create_directory_if_not_exists() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        print_message "Criando diretório: $dir_path"
        mkdir -p "$dir_path"
    else
        print_message "✓ Diretório já existe: $dir_path"
    fi
}

# Função para configurar permissões de diretório se existir
set_permissions_if_exists() {
    local dir_path="$1"
    local permissions="$2"
    
    if [ -d "$dir_path" ]; then
        print_message "Configurando permissões $permissions para: $dir_path"
        chmod -R "$permissions" "$dir_path"
    else
        print_warning "Diretório não encontrado (será criado quando necessário): $dir_path"
    fi
}

# Função para criar todos os diretórios necessários do Mautic
create_mautic_directories() {
    print_message "Criando estrutura completa de diretórios do Mautic..."
    
    # Diretórios principais de cache e logs
    create_directory_if_not_exists "var"
    create_directory_if_not_exists "var/cache"
    create_directory_if_not_exists "var/cache/prod"
    create_directory_if_not_exists "var/logs"
    create_directory_if_not_exists "var/spool"
    
    # Diretórios de configuração
    create_directory_if_not_exists "config"
    
    # Diretórios de mídia
    create_directory_if_not_exists "media"
    create_directory_if_not_exists "media/files"
    create_directory_if_not_exists "media/images"
    
    # Diretórios de tradução
    create_directory_if_not_exists "translations"
    
    # Diretórios obrigatórios para www-data
    create_directory_if_not_exists "uploads"
    create_directory_if_not_exists "docroot"
    
    # Nota: plugins/ e themes/ são criados automaticamente pelo Mautic quando necessário
    
    print_message "✓ Estrutura de diretórios criada"
}

# Função para configurar permissões completas do Mautic (baseada na documentação oficial)
configure_mautic_permissions() {
    print_message "Configurando permissões conforme documentação oficial do Mautic..."
    
    # Verificar se estamos no diretório correto
    verify_mautic_directory
    
    print_message "Aplicando permissões básicas (documentação oficial)..."
    
    # 1. Permissões básicas para arquivos e diretórios (comando oficial)
    print_message "Configurando permissões básicas: arquivos 644, diretórios 755"
    find . -type f -not -perm 644 -exec chmod 644 {} + 2>/dev/null || true
    find . -type d -not -perm 755 -exec chmod 755 {} + 2>/dev/null || true
    
    print_message "Aplicando permissões específicas de escrita (comando oficial)..."
    
    # 2. Permissões específicas de escrita - comando oficial da documentação
    # chmod -R g+w var/cache/ var/logs/ app/config/
    # chmod -R g+w media/files/ media/images/ translations/
    
    # Diretórios principais que DEVEM ter permissão 775 (escrita)
    set_permissions_if_exists "var" "775"
    set_permissions_if_exists "var/cache" "775"
    set_permissions_if_exists "var/cache/prod" "775"
    set_permissions_if_exists "var/logs" "775"
    set_permissions_if_exists "var/spool" "775"
    
    # Diretórios de configuração
    set_permissions_if_exists "config" "775"
    set_permissions_if_exists "app/config" "775"  # Mautic 4.x e anteriores
    
    # Diretórios de mídia
    set_permissions_if_exists "media" "775"
    set_permissions_if_exists "media/files" "775"
    set_permissions_if_exists "media/images" "775"
    
    # Diretórios de tradução
    set_permissions_if_exists "translations" "775"
    
    # Diretórios obrigatórios para www-data
    set_permissions_if_exists "uploads" "775"
    set_permissions_if_exists "docroot" "775"
    
    # Diretórios opcionais
    set_permissions_if_exists "plugins" "775"
    set_permissions_if_exists "themes" "775"
    
    # 3. Arquivos específicos que precisam de permissão 664
    if [ -f "config/local.php" ]; then
        print_message "Configurando permissões 664 para config/local.php"
        chmod 664 "config/local.php"
    fi
    
    if [ -f "app/config/parameters.yml" ]; then
        print_message "Configurando permissões 664 para app/config/parameters.yml"
        chmod 664 "app/config/parameters.yml"
    fi
    
    if [ -f "config/parameters.yml" ]; then
        print_message "Configurando permissões 664 para config/parameters.yml"
        chmod 664 "config/parameters.yml"
    fi
    
    print_message "✓ Permissões configuradas conforme documentação oficial do Mautic"
}

# Função para configurar proprietário dos arquivos
configure_file_ownership() {
    if [ "$EUID" -eq 0 ]; then
        print_message "Configurando proprietário dos arquivos para www-data..."
        
        # Diretórios principais que DEVEM pertencer ao www-data
        [ -d "translations" ] && chown -R www-data:www-data translations/ 2>/dev/null || true
        [ -d "uploads" ] && chown -R www-data:www-data uploads/ 2>/dev/null || true
        [ -d "var" ] && chown -R www-data:www-data var/ 2>/dev/null || true
        [ -d "media" ] && chown -R www-data:www-data media/ 2>/dev/null || true
        [ -d "config" ] && chown -R www-data:www-data config/ 2>/dev/null || true
        [ -d "docroot" ] && chown -R www-data:www-data docroot/ 2>/dev/null || true
        
        # Diretórios opcionais (versões anteriores do Mautic)
        [ -d "app/config" ] && chown -R www-data:www-data app/config/ 2>/dev/null || true
        [ -d "plugins" ] && chown -R www-data:www-data plugins/ 2>/dev/null || true
        [ -d "themes" ] && chown -R www-data:www-data themes/ 2>/dev/null || true
        
        print_message "✓ Proprietário configurado para www-data"
    else
        print_warning "Não é possível configurar proprietário www-data (não executando como root)"
    fi
}

# Função para verificar limite de memória do PHP
check_php_memory_limit() {
    print_message "Verificando configuração de memória do PHP..."
    
    local memory_limit=$(php -r "echo ini_get('memory_limit');")
    local memory_limit_bytes=$(php -r "
        \$limit = ini_get('memory_limit');
        if (\$limit == -1) {
            echo 'unlimited';
        } else {
            \$value = (int) \$limit;
            \$unit = strtoupper(substr(\$limit, -1));
            switch(\$unit) {
                case 'G': echo \$value * 1024 * 1024 * 1024; break;
                case 'M': echo \$value * 1024 * 1024; break;
                case 'K': echo \$value * 1024; break;
                default: echo \$value;
            }
        }
    ")
    
    print_message "Limite de memória atual: $memory_limit"
    
    # Verificar se é menor que 512MB (recomendado para Mautic)
    if [ "$memory_limit_bytes" != "unlimited" ] && [ "$memory_limit_bytes" -lt 536870912 ]; then
        print_error "⚠️  LIMITE DE MEMÓRIA INSUFICIENTE!"
        print_error "Atual: $memory_limit (recomendado: 512M ou mais)"
        echo ""
        print_warning "O Mautic requer pelo menos 512MB de memória PHP."
        print_warning "Para corrigir, edite o arquivo php.ini e aumente o memory_limit."
        echo ""
        
        # Detectar arquivo php.ini
        local php_ini_file=$(php --ini | grep "Loaded Configuration File" | cut -d: -f2 | xargs)
        if [ -n "$php_ini_file" ] && [ -f "$php_ini_file" ]; then
            print_message "Arquivo php.ini detectado: $php_ini_file"
            echo ""
            print_warning "Comandos para corrigir:"
            echo "1. Abrir o arquivo php.ini:"
            echo "   sudo nano $php_ini_file"
            echo ""
            echo "2. Procurar e alterar a linha:"
            echo "   memory_limit = 128M"
            echo "   Para:"
            echo "   memory_limit = 512M"
            echo ""
            echo "3. Reiniciar o PHP/Apache/Nginx:"
            echo "   sudo systemctl restart php8.3-fpm"
            echo "   sudo systemctl restart apache2"
            echo "   sudo systemctl restart nginx"
        else
            print_warning "Não foi possível detectar o arquivo php.ini."
            print_warning "Execute: php --ini para encontrar o arquivo de configuração."
        fi
        
        echo ""
        read -p "Deseja tentar continuar sem o cache warming? (s/N): " SKIP_CACHE
        if [[ $SKIP_CACHE =~ ^[Ss]$ ]]; then
            export SKIP_CACHE_OPERATIONS=1
            print_warning "Cache warming será pulado. Configure manualmente depois."
        else
            print_error "Instalação cancelada. Configure a memória PHP e tente novamente."
            exit 1
        fi
    else
        print_message "✓ Limite de memória adequado para o Mautic"
    fi
}

# Função para verificar extensões PHP necessárias
check_php_extensions() {
    print_message "Verificando extensões PHP necessárias..."
    
    local missing_extensions=()
    local required_extensions=(
        "fileinfo"
        "curl"
        "gd"
        "json"
        "mbstring"
        "xml"
        "zip"
        "intl"
        "pdo"
        "pdo_mysql"
        "openssl"
        "bcmath"
    )
    
    for ext in "${required_extensions[@]}"; do
        if php -m | grep -q "^$ext$"; then
            print_message "✓ Extensão $ext encontrada"
        else
            missing_extensions+=("$ext")
            print_error "✗ Extensão $ext não encontrada"
        fi
    done
    
    if [ ${#missing_extensions[@]} -gt 0 ]; then
        print_error "Extensões PHP obrigatórias não encontradas:"
        for ext in "${missing_extensions[@]}"; do
            echo "  - $ext"
        done
        echo ""
        print_warning "Para instalar as extensões em Ubuntu/Debian:"
        for ext in "${missing_extensions[@]}"; do
            case $ext in
                "fileinfo")
                    echo "  sudo apt-get install php8.3-fileinfo"
                    ;;
                "curl")
                    echo "  sudo apt-get install php8.3-curl"
                    ;;
                "gd")
                    echo "  sudo apt-get install php8.3-gd"
                    ;;
                "mbstring")
                    echo "  sudo apt-get install php8.3-mbstring"
                    ;;
                "xml")
                    echo "  sudo apt-get install php8.3-xml"
                    ;;
                "zip")
                    echo "  sudo apt-get install php8.3-zip"
                    ;;
                "intl")
                    echo "  sudo apt-get install php8.3-intl"
                    ;;
                "pdo_mysql")
                    echo "  sudo apt-get install php8.3-mysql"
                    ;;
                "bcmath")
                    echo "  sudo apt-get install php8.3-bcmath"
                    ;;
                *)
                    echo "  sudo apt-get install php8.3-$ext"
                    ;;
            esac
        done
        echo ""
        print_warning "Após instalar, reinicie o PHP/Apache/Nginx:"
        echo "  sudo systemctl restart php8.3-fpm  # Se usando PHP-FPM"
        echo "  sudo systemctl restart apache2     # Se usando Apache"
        echo "  sudo systemctl restart nginx       # Se usando Nginx"
        echo ""
        
        read -p "Deseja tentar instalar as extensões automaticamente? (s/N): " INSTALL_EXTENSIONS
        if [[ $INSTALL_EXTENSIONS =~ ^[Ss]$ ]]; then
            install_php_extensions "${missing_extensions[@]}"
        else
            read -p "Deseja continuar ignorando os requisitos? (NÃO RECOMENDADO) (s/N): " IGNORE_REQUIREMENTS
            if [[ $IGNORE_REQUIREMENTS =~ ^[Ss]$ ]]; then
                print_warning "Continuando com extensões faltando. A instalação pode falhar."
                export COMPOSER_IGNORE_PLATFORM_REQS=1
            else
                print_error "Instalação cancelada. Instale as extensões necessárias e tente novamente."
                exit 1
            fi
        fi
    else
        print_message "✓ Todas as extensões PHP necessárias estão instaladas"
    fi
}

# Função para instalar extensões PHP automaticamente
install_php_extensions() {
    local extensions=("$@")
    
    print_message "Tentando instalar extensões PHP automaticamente..."
    
    # Detectar versão do PHP
    PHP_VERSION_SHORT=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
    print_message "Versão do PHP detectada: $PHP_VERSION_SHORT"
    
    # Atualizar lista de pacotes
    print_message "Atualizando lista de pacotes..."
    sudo apt-get update -qq
    
    # Instalar extensões
    for ext in "${extensions[@]}"; do
        print_message "Instalando extensão: $ext"
        case $ext in
            "fileinfo")
                # fileinfo geralmente vem built-in, mas pode estar desabilitado
                print_warning "fileinfo deve estar built-in. Verificando configuração..."
                ;;
            "curl")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-curl
                ;;
            "gd")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-gd
                ;;
            "mbstring")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-mbstring
                ;;
            "xml")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-xml
                ;;
            "zip")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-zip
                ;;
            "intl")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-intl
                ;;
            "pdo_mysql")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-mysql
                ;;
            "bcmath")
                sudo apt-get install -y php${PHP_VERSION_SHORT}-bcmath
                ;;
            *)
                sudo apt-get install -y php${PHP_VERSION_SHORT}-${ext} || true
                ;;
        esac
    done
    
    # Reiniciar serviços PHP
    print_message "Reiniciando serviços PHP..."
    sudo systemctl restart php${PHP_VERSION_SHORT}-fpm 2>/dev/null || true
    sudo systemctl restart apache2 2>/dev/null || true
    sudo systemctl restart nginx 2>/dev/null || true
    
    print_message "✓ Instalação de extensões concluída"
    
    # Verificar novamente
    print_message "Verificando extensões novamente..."
    sleep 2
    check_php_extensions
}

# Função para remover diretório de forma simples mas eficaz
remove_directory_safely() {
    local dir_path="$1"
    
    if [ ! -d "$dir_path" ]; then
        return 0  # Diretório não existe
    fi
    
    print_message "Removendo diretório existente: $dir_path"
    
    # Método 1: rm simples
    if rm -rf "$dir_path" 2>/dev/null; then
        print_message "✓ Diretório removido"
        return 0
    fi
    
    # Método 2: com sudo se necessário
    if [ "$EUID" -ne 0 ]; then
        print_warning "Tentando com sudo..."
        if sudo rm -rf "$dir_path" 2>/dev/null; then
            print_message "✓ Diretório removido com sudo"
            return 0
        fi
    fi
    
    print_error "Não foi possível remover o diretório $dir_path"
    print_error "Execute manualmente: sudo rm -rf $dir_path"
    return 1
}

# Função para limpeza de cache (comando oficial)
clean_mautic_cache() {
    print_message "Limpando cache do Mautic (comando oficial)..."
    
    # Comando oficial da documentação: rm -rf var/cache/*
    if [ -d "var/cache" ]; then
        rm -rf var/cache/* 2>/dev/null || true
        print_message "✓ Cache limpo"
    fi
}

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

# Validar dependências
print_header "Verificando Dependências"
check_command "composer"
check_command "php"
check_command "mysql"

# Verificar versão do PHP
PHP_VERSION=$(php -r "echo PHP_VERSION;" 2>/dev/null || echo "desconhecida")
print_message "✓ PHP versão: $PHP_VERSION"

# Verificar limite de memória do PHP
check_php_memory_limit

# Verificar extensões PHP necessárias
check_php_extensions

# Configurar variáveis básicas do Composer
export COMPOSER_ALLOW_SUPERUSER=1

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
        if ! remove_directory_safely "$PROJECT_DIR"; then
            print_error "Não foi possível remover o diretório existente."
            exit 1
        fi
    else
        print_error "Instalação cancelada."
        exit 1
    fi
fi

# Verificar se o diretório foi realmente removido
if [ -d "$PROJECT_DIR" ]; then
    print_error "Diretório $PROJECT_DIR ainda existe."
    exit 1
fi

# Passo 1: Criar projeto Mautic (sem instalar dependências ainda)
print_message "Passo 1: Criando estrutura do projeto Mautic versão $MAUTIC_VERSION..."
print_message "Executando em: $(pwd)"
composer create-project mautic/recommended-project:^$MAUTIC_VERSION $PROJECT_DIR --no-install --prefer-dist

# Verificar se o projeto foi criado
if [ ! -d "$PROJECT_DIR" ]; then
    print_error "Diretório do projeto não foi criado: $PROJECT_DIR"
    exit 1
fi

print_message "✓ Estrutura do projeto criada"

# Passo 2: Entrar no diretório do projeto
print_message "Passo 2: Navegando para o diretório do projeto..."
print_message "Antes: $(pwd)"
cd $PROJECT_DIR
print_message "Depois: $(pwd)"
print_message "✓ Agora estamos no diretório do Mautic"

# Verificar se estamos no diretório correto
verify_mautic_directory

# Passo 3: Instalar dependências com composer
print_message "Passo 3: Instalando dependências do Mautic..."
print_message "Executando composer install em: $(pwd)"
if [ -n "$COMPOSER_IGNORE_PLATFORM_REQS" ]; then
    print_warning "Instalando com requisitos de plataforma ignorados..."
    composer install --no-dev --optimize-autoloader --ignore-platform-reqs
else
    composer install --no-dev --optimize-autoloader
fi

print_message "✓ Dependências instaladas"

# Passo 4: Criar estrutura de diretórios e configurar permissões
print_message "Passo 4: Criando estrutura de diretórios e configurando permissões..."
print_message "Trabalhando no diretório: $(pwd)"

# Verificar novamente se estamos no lugar certo
verify_mautic_directory

# Criar toda a estrutura de diretórios necessária
create_mautic_directories

# Configurar permissões completas conforme documentação oficial
configure_mautic_permissions

# Configurar proprietário dos arquivos
configure_file_ownership

# Passo 5: Executar instalação do Mautic
print_message "Passo 5: Executando instalação do Mautic..."
print_message "Executando mautic:install em: $(pwd)"

# Verificar se bin/console existe
if [ ! -f "bin/console" ]; then
    print_error "Arquivo bin/console não encontrado em: $(pwd)"
    exit 1
fi

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

print_message "✓ Mautic instalado"

# Passo 6: Limpar e aquecer cache (com verificação de memória)
if [ -z "$SKIP_CACHE_OPERATIONS" ]; then
    print_message "Passo 6: Limpando e aquecendo cache..."
    print_message "Executando comandos de cache em: $(pwd)"
    
    # Tentar limpar cache
    if php bin/console cache:clear --env=prod --no-warmup; then
        print_message "✓ Cache limpo"
        
        # Tentar aquecer cache separadamente
        if php bin/console cache:warmup --env=prod; then
            print_message "✓ Cache aquecido"
        else
            print_warning "Falha ao aquecer cache. Isso pode ser feito manualmente depois."
        fi
    else
        print_warning "Falha ao limpar cache. Verifique o limite de memória PHP."
        print_warning "Configure memory_limit = 512M no php.ini e tente novamente."
    fi
    
    # Limpar cache com comando oficial
    clean_mautic_cache
else
    print_warning "Passo 6: Cache warming pulado devido ao limite de memória"
    print_warning "Configure memory_limit = 512M no php.ini e execute manualmente:"
    print_warning "  cd $(pwd)"
    print_warning "  php bin/console cache:clear --env=prod"
    print_warning "  php bin/console cache:warmup --env=prod"
fi

# Passo 7: Recarregar plugins
print_message "Passo 7: Recarregando plugins..."
print_message "Executando reload de plugins em: $(pwd)"
php bin/console mautic:plugins:reload

print_message "✓ Plugins recarregados"

# Passo 8: Configurar permissões finais (APÓS todas as operações)
print_message "Passo 8: Configurando permissões finais..."
print_message "Configurando permissões finais em: $(pwd)"

# Verificar novamente se estamos no diretório correto
verify_mautic_directory

# Aplicar permissões finais conforme documentação oficial
configure_mautic_permissions

# Configurar proprietário final
configure_file_ownership

print_message "✓ Permissões configuradas"

print_header "Instalação Concluída com Sucesso!"

echo ""
print_message "=== INFORMAÇÕES DA INSTALAÇÃO ==="
echo "Diretório: $(pwd)"
echo "URL do site: $SITE_URL"
echo "Usuário admin: $ADMIN_USERNAME"
echo "Email admin: $ADMIN_EMAIL"
echo ""
print_message "=== ESTRUTURA DE DIRETÓRIOS CRIADA ==="
echo "var/                    # Cache, logs, sessões"
echo "├── cache/              # Cache do sistema"
echo "├── logs/               # Logs do sistema"
echo "└── spool/              # Fila de emails"
echo "config/                 # Configurações"
echo "media/                  # Arquivos de mídia"
echo "├── files/              # Arquivos enviados"
echo "└── images/             # Imagens"
echo "translations/           # Arquivos de tradução"
echo "uploads/                # Uploads"
echo ""

if [ -n "$SKIP_CACHE_OPERATIONS" ]; then
    print_warning "=== AÇÃO NECESSÁRIA ==="
    echo "1. Configure memory_limit = 512M no arquivo php.ini"
    echo "2. Reinicie o PHP/Apache/Nginx"
    echo "3. Execute manualmente:"
    echo "   cd $(pwd)"
    echo "   php bin/console cache:clear --env=prod"
    echo "   php bin/console cache:warmup --env=prod"
    echo ""
fi

print_message "=== PRÓXIMOS PASSOS ==="
echo "1. Configure seu servidor web para apontar para este diretório"
echo "2. Certifique-se de que o domínio $SITE_URL está configurado"
echo "3. Acesse $SITE_URL para começar a usar o Mautic"
echo ""
print_warning "=== IMPORTANTE ==="
echo "- Guarde as credenciais de acesso em local seguro"
echo "- Configure backups regulares do banco de dados"
echo "- Mantenha o Mautic sempre atualizado"
echo "- Todas as permissões foram configuradas conforme documentação oficial"
echo ""

print_message "Instalação finalizada! 🎉"