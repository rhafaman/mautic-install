#!/bin/bash

# Script para Remoção Completa do Mautic
# Remove diretório e todas as tabelas do banco de dados
# Autor: Script de Remoção Mautic
# Versão: 1.0

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir header
show_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "        SCRIPT DE REMOÇÃO DO MAUTIC"
    echo "=================================================="
    echo -e "${NC}"
}

# Função para log
log_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Função para log de erro
log_error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

# Função para log de warning
log_warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

# Função para confirmar ação
confirm_action() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Digite 'CONFIRMAR' para continuar ou qualquer outra coisa para cancelar: " confirmation
    if [ "$confirmation" != "CONFIRMAR" ]; then
        log_error "Operação cancelada pelo usuário."
        exit 1
    fi
}

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para testar conexão com banco de dados
test_database_connection() {
    local db_host="$1"
    local db_user="$2"
    local db_password="$3"
    local db_name="$4"
    local db_port="${5:-3306}"

    log_message "Testando conexão com o banco de dados..."

    # Testar conexão
    if command_exists mysql; then
        mysql -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" -e "USE $db_name;" 2>/dev/null
        local result=$?
    elif command_exists mariadb; then
        mariadb -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" -e "USE $db_name;" 2>/dev/null
        local result=$?
    else
        log_error "Cliente MySQL/MariaDB não encontrado."
        return 1
    fi

    if [ $result -eq 0 ]; then
        log_message "✅ Conexão com banco de dados estabelecida com sucesso!"
        return 0
    else
        log_error "❌ Falha ao conectar com o banco de dados. Verifique as credenciais."
        return 1
    fi
}

# Função para listar tabelas do banco
list_database_tables() {
    local db_host="$1"
    local db_user="$2"
    local db_password="$3"
    local db_name="$4"
    local db_port="${5:-3306}"

    log_message "Listando tabelas restantes no banco de dados '$db_name'..."

    # SQL para listar todas as tabelas
    local list_sql="SHOW TABLES;"
    local tables_output=""

    # Executar o comando para listar tabelas
    if command_exists mysql; then
        tables_output=$(echo "$list_sql" | mysql -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" "$db_name" 2>/dev/null | grep -v "Tables_in_")
    elif command_exists mariadb; then
        tables_output=$(echo "$list_sql" | mariadb -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" "$db_name" 2>/dev/null | grep -v "Tables_in_")
    else
        log_error "Cliente MySQL/MariaDB não encontrado."
        return 1
    fi

    # Verificar se há tabelas restantes
    if [ -z "$tables_output" ]; then
        log_message "✅ Nenhuma tabela encontrada no banco '$db_name'. Remoção completa!"
    else
        local table_count=$(echo "$tables_output" | wc -l)
        log_warning "⚠️  Ainda existem $table_count tabela(s) no banco '$db_name':"
        echo ""
        echo -e "${YELLOW}Tabelas restantes:${NC}"
        echo "$tables_output" | while read -r table; do
            echo "  - $table"
        done
        echo ""
        log_warning "Estas tabelas podem não ser do Mautic ou podem ter sido criadas após a instalação."
    fi
}

# Função para remover tabelas do banco
remove_database_tables() {
    local db_host="$1"
    local db_user="$2"
    local db_password="$3"
    local db_name="$4"
    local db_port="${5:-3306}"

    log_message "Iniciando remoção das tabelas do banco de dados..."

    # SQL para remover todas as tabelas do Mautic
    local sql_script="
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS \`user_tokens\`;
DROP TABLE IF EXISTS \`video_hits\`;
DROP TABLE IF EXISTS \`email_copies\`;
DROP TABLE IF EXISTS \`campaign_summary\`;
DROP TABLE IF EXISTS \`point_groups\`;
DROP TABLE IF EXISTS \`lead_stages_change_log\`;
DROP TABLE IF EXISTS \`companies\`;
DROP TABLE IF EXISTS \`campaign_form_xref\`;
DROP TABLE IF EXISTS \`assets\`;
DROP TABLE IF EXISTS \`point_lead_event_log\`;
DROP TABLE IF EXISTS \`dynamic_content_stats\`;
DROP TABLE IF EXISTS \`sms_message_stats\`;
DROP TABLE IF EXISTS \`sms_projects_xref\`;
DROP TABLE IF EXISTS \`asset_projects_xref\`;
DROP TABLE IF EXISTS \`email_list_excluded\`;
DROP TABLE IF EXISTS \`email_stats_devices\`;
DROP TABLE IF EXISTS \`reports\`;
DROP TABLE IF EXISTS \`email_stats\`;
DROP TABLE IF EXISTS \`page_redirects\`;
DROP TABLE IF EXISTS \`ip_addresses\`;
DROP TABLE IF EXISTS \`saml_id_entry\`;
DROP TABLE IF EXISTS \`point_group_contact_score\`;
DROP TABLE IF EXISTS \`dynamic_content_lead_data\`;
DROP TABLE IF EXISTS \`monitoring_leads\`;
DROP TABLE IF EXISTS \`reports_schedulers\`;
DROP TABLE IF EXISTS \`email_list_xref\`;
DROP TABLE IF EXISTS \`campaign_lead_event_failed_log\`;
DROP TABLE IF EXISTS \`form_projects_xref\`;
DROP TABLE IF EXISTS \`lead_lists_leads\`;
DROP TABLE IF EXISTS \`push_ids\`;
DROP TABLE IF EXISTS \`lead_list_projects_xref\`;
DROP TABLE IF EXISTS \`sms_message_list_xref\`;
DROP TABLE IF EXISTS \`lead_fields\`;
DROP TABLE IF EXISTS \`email_stat_replies\`;
DROP TABLE IF EXISTS \`bundle_grapesjsbuilder\`;
DROP TABLE IF EXISTS \`webhooks\`;
DROP TABLE IF EXISTS \`lead_tags_xref\`;
DROP TABLE IF EXISTS \`monitoring\`;
DROP TABLE IF EXISTS \`webhook_logs\`;
DROP TABLE IF EXISTS \`asset_downloads\`;
DROP TABLE IF EXISTS \`webhook_queue\`;
DROP TABLE IF EXISTS \`plugin_integration_settings\`;
DROP TABLE IF EXISTS \`sync_object_field_change_report\`;
DROP TABLE IF EXISTS \`oauth2_authcodes\`;
DROP TABLE IF EXISTS \`lead_devices\`;
DROP TABLE IF EXISTS \`forms\`;
DROP TABLE IF EXISTS \`point_triggers\`;
DROP TABLE IF EXISTS \`companies_leads\`;
DROP TABLE IF EXISTS \`lead_tags\`;
DROP TABLE IF EXISTS \`page_hits\`;
DROP TABLE IF EXISTS \`oauth2_refreshtokens\`;
DROP TABLE IF EXISTS \`campaign_leads\`;
DROP TABLE IF EXISTS \`push_notification_stats\`;
DROP TABLE IF EXISTS \`dynamic_content\`;
DROP TABLE IF EXISTS \`tweet_stats\`;
DROP TABLE IF EXISTS \`focus_stats\`;
DROP TABLE IF EXISTS \`point_trigger_events\`;
DROP TABLE IF EXISTS \`sms_messages\`;
DROP TABLE IF EXISTS \`campaign_leadlist_xref\`;
DROP TABLE IF EXISTS \`projects\`;
DROP TABLE IF EXISTS \`integration_entity\`;
DROP TABLE IF EXISTS \`emails_draft\`;
DROP TABLE IF EXISTS \`pages\`;
DROP TABLE IF EXISTS \`email_projects_xref\`;
DROP TABLE IF EXISTS \`lead_utmtags\`;
DROP TABLE IF EXISTS \`lead_donotcontact\`;
DROP TABLE IF EXISTS \`lead_points_change_log\`;
DROP TABLE IF EXISTS \`push_notifications\`;
DROP TABLE IF EXISTS \`lead_categories\`;
DROP TABLE IF EXISTS \`form_fields\`;
DROP TABLE IF EXISTS \`lead_event_log\`;
DROP TABLE IF EXISTS \`contact_merge_records\`;
DROP TABLE IF EXISTS \`cache_items\`;
DROP TABLE IF EXISTS \`messages\`;
DROP TABLE IF EXISTS \`audit_log\`;
DROP TABLE IF EXISTS \`webhook_events\`;
DROP TABLE IF EXISTS \`channel_url_trackables\`;
DROP TABLE IF EXISTS \`lead_companies_change_log\`;
DROP TABLE IF EXISTS \`permissions\`;
DROP TABLE IF EXISTS \`stages\`;
DROP TABLE IF EXISTS \`categories\`;
DROP TABLE IF EXISTS \`email_assets_xref\`;
DROP TABLE IF EXISTS \`monitor_post_count\`;
DROP TABLE IF EXISTS \`imports\`;
DROP TABLE IF EXISTS \`notifications\`;
DROP TABLE IF EXISTS \`page_projects_xref\`;
DROP TABLE IF EXISTS \`point_lead_action_log\`;
DROP TABLE IF EXISTS \`oauth2_accesstokens\`;
DROP TABLE IF EXISTS \`message_projects_xref\`;
DROP TABLE IF EXISTS \`roles\`;
DROP TABLE IF EXISTS \`message_channels\`;
DROP TABLE IF EXISTS \`emails\`;
DROP TABLE IF EXISTS \`stage_lead_action_log\`;
DROP TABLE IF EXISTS \`focus_projects_xref\`;
DROP TABLE IF EXISTS \`focus\`;
DROP TABLE IF EXISTS \`campaigns\`;
DROP TABLE IF EXISTS \`campaign_projects_xref\`;
DROP TABLE IF EXISTS \`oauth2_user_client_xref\`;
DROP TABLE IF EXISTS \`sync_object_mapping\`;
DROP TABLE IF EXISTS \`lead_lists\`;
DROP TABLE IF EXISTS \`points\`;
DROP TABLE IF EXISTS \`lead_frequencyrules\`;
DROP TABLE IF EXISTS \`widgets\`;
DROP TABLE IF EXISTS \`push_notification_list_xref\`;
DROP TABLE IF EXISTS \`lead_ips_xref\`;
DROP TABLE IF EXISTS \`pages_draft\`;
DROP TABLE IF EXISTS \`company_projects_xref\`;
DROP TABLE IF EXISTS \`oauth2_clients\`;
DROP TABLE IF EXISTS \`lead_notes\`;
DROP TABLE IF EXISTS \`campaign_events\`;
DROP TABLE IF EXISTS \`form_actions\`;
DROP TABLE IF EXISTS \`form_submissions\`;
DROP TABLE IF EXISTS \`plugins\`;
DROP TABLE IF EXISTS \`tweets\`;
DROP TABLE IF EXISTS \`users\`;
DROP TABLE IF EXISTS \`message_queue\`;
DROP TABLE IF EXISTS \`contact_export_scheduler\`;
DROP TABLE IF EXISTS \`leads\`;
DROP TABLE IF EXISTS \`campaign_lead_event_log\`;

SET FOREIGN_KEY_CHECKS = 1;
"

    # Executar o script SQL
    if command_exists mysql; then
        echo "$sql_script" | mysql -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" "$db_name" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "Tabelas do banco de dados removidas com sucesso!"
        else
            log_error "Erro ao remover tabelas do banco de dados."
            return 1
        fi
    elif command_exists mariadb; then
        echo "$sql_script" | mariadb -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" "$db_name" 2>/dev/null
        if [ $? -eq 0 ]; then
            log_message "Tabelas do banco de dados removidas com sucesso!"
        else
            log_error "Erro ao remover tabelas do banco de dados."
            return 1
        fi
    else
        log_error "Cliente MySQL/MariaDB não encontrado."
        return 1
    fi
}

# Função para remover diretório do Mautic
remove_mautic_directory() {
    local mautic_path="$1"
    
    if [ ! -d "$mautic_path" ]; then
        log_warning "Diretório $mautic_path não encontrado."
        return 0
    fi

    log_message "Removendo diretório do Mautic: $mautic_path"
    
    # Remover permissões especiais antes de deletar
    if command_exists find; then
        find "$mautic_path" -type d -exec chmod 755 {} \; 2>/dev/null
        find "$mautic_path" -type f -exec chmod 644 {} \; 2>/dev/null
    fi
    
    # Remover o diretório
    rm -rf "$mautic_path"
    
    if [ $? -eq 0 ]; then
        log_message "Diretório do Mautic removido com sucesso!"
    else
        log_error "Erro ao remover diretório do Mautic."
        return 1
    fi
}

# Função para fazer backup opcional
create_backup() {
    local mautic_path="$1"
    local db_host="$2"
    local db_user="$3"
    local db_password="$4"
    local db_name="$5"
    local db_port="${6:-3306}"
    
    local backup_dir="/tmp/mautic_backup_$(date +%Y%m%d_%H%M%S)"
    
    log_message "Criando backup em: $backup_dir"
    mkdir -p "$backup_dir"
    
    # Backup do diretório
    if [ -d "$mautic_path" ]; then
        log_message "Fazendo backup do diretório..."
        tar -czf "$backup_dir/mautic_files.tar.gz" -C "$(dirname "$mautic_path")" "$(basename "$mautic_path")" 2>/dev/null
    fi
    
    # Backup do banco
    log_message "Fazendo backup do banco de dados..."
    if command_exists mysqldump; then
        mysqldump -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" "$db_name" > "$backup_dir/mautic_database.sql" 2>/dev/null
    elif command_exists mariadb-dump; then
        mariadb-dump -h"$db_host" -P"$db_port" -u"$db_user" -p"$db_password" "$db_name" > "$backup_dir/mautic_database.sql" 2>/dev/null
    fi
    
    log_message "Backup criado em: $backup_dir"
}

# Função principal
main() {
    show_header
    
    # Verificar se está rodando como root ou sudo
    if [ "$EUID" -ne 0 ]; then
        log_warning "Este script pode precisar de privilégios de root para algumas operações."
        log_warning "Se houver erros de permissão, execute com sudo."
    fi
    
    # Solicitar informações do banco de dados
    echo -e "${BLUE}=== CONFIGURAÇÃO DO BANCO DE DADOS ===${NC}"
    echo "Por favor, forneça as informações de conexão com o banco de dados:"
    echo ""
    
    # Loop para obter configurações válidas do banco
    local db_connected=false
    while [ "$db_connected" = false ]; do
        read -p "Host do banco de dados [localhost]: " db_host
        db_host=${db_host:-localhost}
        
        read -p "Porta do banco de dados [3306]: " db_port
        db_port=${db_port:-3306}
        
        read -p "Nome do banco de dados [mautic]: " db_name
        db_name=${db_name:-mautic}
        
        read -p "Usuário do banco de dados [root]: " db_user
        db_user=${db_user:-root}
        
        echo -n "Senha do banco de dados: "
        read -s db_password
        echo ""
        echo ""
        
        # Testar conexão
        if test_database_connection "$db_host" "$db_user" "$db_password" "$db_name" "$db_port"; then
            db_connected=true
        else
            log_error "Não foi possível conectar ao banco de dados."
            echo ""
            read -p "Deseja tentar novamente com outras credenciais? (S/n): " retry
            if [[ "${retry,,}" == "n" ]]; then
                log_error "Operação cancelada pelo usuário."
                exit 1
            fi
            echo ""
        fi
    done
    
    # Solicitar caminho do Mautic
    echo -e "${BLUE}=== CONFIGURAÇÃO DO DIRETÓRIO ===${NC}"
    read -p "Caminho completo do diretório do Mautic [/var/www/html]: " mautic_path
    mautic_path=${mautic_path:-/var/www/html}
    
    # Perguntar sobre backup
    echo -e "${BLUE}=== BACKUP ===${NC}"
    read -p "Deseja criar um backup antes de remover? (s/N): " create_backup_option
    
    # Mostrar resumo das configurações
    echo -e "${BLUE}=== RESUMO DAS CONFIGURAÇÕES ===${NC}"
    echo "Host do banco: $db_host"
    echo "Porta do banco: $db_port"
    echo "Usuário do banco: $db_user"
    echo "Nome do banco: $db_name"
    echo "Diretório do Mautic: $mautic_path"
    echo "Criar backup: ${create_backup_option:-N}"
    echo ""
    
    # Confirmação final
    confirm_action "⚠️  ATENÇÃO: Esta operação irá REMOVER PERMANENTEMENTE:
    - Todas as tabelas do banco de dados '$db_name'
    - Todo o diretório '$mautic_path' e seus conteúdos
    - Todos os dados, configurações e uploads do Mautic
    
Esta ação NÃO PODE SER DESFEITA!"
    
    # Criar backup se solicitado
    if [[ "${create_backup_option,,}" == "s" ]]; then
        create_backup "$mautic_path" "$db_host" "$db_user" "$db_password" "$db_name" "$db_port"
    fi
    
    # Remover tabelas do banco
    echo -e "${BLUE}=== REMOVENDO BANCO DE DADOS ===${NC}"
    log_message "Conexão com banco já estabelecida. Procedendo com remoção das tabelas..."
    if ! remove_database_tables "$db_host" "$db_user" "$db_password" "$db_name" "$db_port"; then
        log_error "Falha ao remover tabelas do banco de dados."
        exit 1
    fi
    
    # Verificar tabelas restantes
    echo -e "${BLUE}=== VERIFICANDO TABELAS RESTANTES ===${NC}"
    list_database_tables "$db_host" "$db_user" "$db_password" "$db_name" "$db_port"
    
    # Remover diretório
    echo -e "${BLUE}=== REMOVENDO DIRETÓRIO ===${NC}"
    if ! remove_mautic_directory "$mautic_path"; then
        log_error "Falha ao remover diretório do Mautic."
        exit 1
    fi
    
    # Sucesso
    echo -e "${GREEN}"
    echo "=================================================="
    echo "       REMOÇÃO DO MAUTIC CONCLUÍDA!"
    echo "=================================================="
    echo -e "${NC}"
    
    log_message "Mautic removido completamente do sistema!"
    
    if [[ "${create_backup_option,,}" == "s" ]]; then
        log_message "Backup disponível em: /tmp/mautic_backup_*"
    fi
    
    echo ""
    log_warning "Lembre-se de:"
    echo "  - Verificar configurações do servidor web (Apache/Nginx)"
    echo "  - Remover virtual hosts relacionados ao Mautic"
    echo "  - Verificar cron jobs relacionados ao Mautic"
    echo "  - Limpar certificados SSL se não forem mais necessários"
}

# Executar função principal
main "$@"