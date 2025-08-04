# 🚀 Scripts Automatizados do Mautic

Conjunto de scripts bash para instalação e remoção automatizada do Mautic Marketing Automation Platform.

## 📋 Descrição

Este conjunto de scripts automatiza completamente o gerenciamento do Mautic, oferecendo:

### 🔧 Scripts Disponíveis

1. **`install_mautic.sh`** - Instalação automatizada completa
2. **`remove_mautic.sh`** - Remoção completa e segura

### ✨ Funcionalidades do Instalador (`install_mautic.sh`)

- Download e configuração da versão especificada
- Verificação automática de dependências PHP
- Instalação automática de extensões PHP faltantes
- Configuração completa do banco de dados
- Criação do usuário administrador
- Configuração de permissões oficiais do Mautic
- Cache warming e otimizações
- Verificação de limites de memória PHP

### 🗑️ Funcionalidades do Removedor (`remove_mautic.sh`)

- Remoção completa de todas as tabelas do banco
- Remoção segura do diretório e arquivos
- Backup opcional antes da remoção
- Verificação de conexão com banco de dados
- Listagem de tabelas restantes após remoção

## 👨‍💻 Autor

**Rhafaman**

## 📦 Pré-requisitos

Antes de executar o script, certifique-se de ter instalado:

- **PHP** (versão 8.0 ou superior)
- **Composer**
- **MySQL/MariaDB**
- **Servidor Web** (Apache/Nginx)

### Verificação de Dependências

O script verifica automaticamente se as dependências estão instaladas:
```bash
# O script verifica automaticamente:
- composer
- php
- mysql
```

## 🚀 Instalação e Configuração

### 📥 Download dos Scripts

**Ambos os scripts devem estar presentes no servidor para funcionamento completo.**

1. **Clone ou baixe ambos os scripts:**

```bash
# Fazer download de ambos os scripts
wget https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/install_mautic.sh
wget https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/remove_mautic.sh

# OU usando curl
curl -O https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/install_mautic.sh
curl -O https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/remove_mautic.sh
```

2. **⚠️ IMPORTANTE: Configurar permissões de execução para ambos os scripts:**

```bash
# Tornar ambos os scripts executáveis
chmod +x install_mautic.sh
chmod +x remove_mautic.sh

# Verificar as permissões (devem mostrar -rwxr-xr-x)
ls -la *.sh
```

### 🎯 Execução dos Scripts

#### 📦 Para Instalar o Mautic
```bash
./install_mautic.sh
```

#### 🗑️ Para Remover o Mautic
```bash
./remove_mautic.sh
```

### 🔐 Exemplo Completo de Configuração no Servidor

```bash
# 1. Navegar para o diretório desejado
cd /var/www

# 2. Fazer download dos scripts
wget https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/install_mautic.sh
wget https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/remove_mautic.sh

# 3. Dar permissões de execução
chmod +x install_mautic.sh
chmod +x remove_mautic.sh

# 4. Verificar se as permissões foram aplicadas
ls -la *.sh
# Saída esperada:
# -rwxr-xr-x 1 user user 25123 Dec 12 10:30 install_mautic.sh
# -rwxr-xr-x 1 user user 15234 Dec 12 10:30 remove_mautic.sh

# 5. Executar a instalação
./install_mautic.sh
```

## 📝 Configuração

### 🔧 Configuração do Instalador (`install_mautic.sh`)

Durante a execução do script de instalação, as seguintes informações serão solicitadas:

### 🔧 Configuração da Versão

- **Versão do Mautic** (padrão: 6.0.3)

### 📁 Configuração do Projeto

- **Nome do diretório** (padrão: mautic)
- **URL do site** (ex: `https://mkt.seu-domínio.com.br`)

### 🗄️ Configuração do Banco de Dados
- **Host** (padrão: localhost)
- **Porta** (padrão: 3306)
- **Nome do banco**
- **Usuário**
- **Senha**

### 👤 Configuração do Administrador

- **Primeiro nome** (padrão: Dev)
- **Sobrenome** (padrão: Master)
- **Username** (padrão: dev)
- **Email** (padrão: dev@exemplo.com.br)
- **Senha**

### 🗑️ Configuração do Removedor (`remove_mautic.sh`)

Durante a execução do script de remoção, as seguintes informações serão solicitadas:

#### 🗄️ Configuração do Banco de Dados

- **Host** (padrão: localhost)
- **Porta** (padrão: 3306)
- **Nome do banco** (padrão: mautic)
- **Usuário** (padrão: root)
- **Senha**

#### 📁 Configuração do Diretório

- **Caminho completo do Mautic** (padrão: /var/www/html)

#### 💾 Opções de Backup

- **Criar backup antes da remoção** (s/N)

**⚠️ AVISO:** O script de remoção irá:

- Remover **TODAS** as tabelas do banco de dados
- Remover **TODO** o diretório e arquivos do Mautic
- Esta operação **NÃO PODE SER DESFEITA**

## 🛡️ Segurança

O script configura automaticamente:

- Permissões adequadas para arquivos e diretórios
- Proprietário www-data (quando executado como root)
- Permissões de escrita nos diretórios necessários

### Permissões Configuradas

```bash
# Arquivos: 644
# Diretórios: 755
# Diretórios especiais: 775 (var/, config/, media/)
```

## 📋 Recursos

### 🔧 Recursos do Instalador (`install_mautic.sh`)

- ✅ Verificação automática de dependências PHP
- ✅ Instalação automática de extensões PHP faltantes
- ✅ Verificação de limites de memória PHP
- ✅ Instalação via Composer com otimizações
- ✅ Configuração completa do banco de dados
- ✅ Criação automática do usuário administrador
- ✅ Configuração de permissões oficiais do Mautic
- ✅ Criação automática da estrutura de diretórios
- ✅ Cache warming inteligente
- ✅ Recarregamento de plugins
- ✅ Interface colorida e amigável
- ✅ Validação de inputs obrigatórios
- ✅ Confirmação antes da instalação
- ✅ Configuração de proprietário www-data (se executado como root)

### 🗑️ Recursos do Removedor (`remove_mautic.sh`)

- ✅ Verificação de conexão com banco de dados
- ✅ Teste de credenciais antes da remoção
- ✅ Backup opcional antes da remoção
- ✅ Remoção completa de todas as tabelas do Mautic
- ✅ Remoção segura do diretório e arquivos
- ✅ Verificação de tabelas restantes após remoção
- ✅ Confirmação obrigatória para evitar remoções acidentais
- ✅ Suporte a MySQL e MariaDB
- ✅ Interface colorida com logs detalhados
- ✅ Limpeza de permissões antes da remoção

## 🎯 Exemplos de Uso

### 📦 Exemplo de Instalação

```bash
# 1. Dar permissões e executar instalador
chmod +x install_mautic.sh
./install_mautic.sh

# 2. Seguir os prompts:
# Versão do Mautic: 6.0.3
# Nome do diretório: meu-mautic
# URL: https://mkt.meusite.com.br
# Configurações do banco...
# Configurações do admin...

# 3. Aguardar instalação completa
# ✅ Dependências verificadas
# ✅ Extensões PHP instaladas
# ✅ Mautic baixado e configurado
# ✅ Banco de dados configurado
# ✅ Permissões aplicadas
# ✅ Cache aquecido
```

### 🗑️ Exemplo de Remoção

```bash
# 1. Dar permissões e executar removedor
chmod +x remove_mautic.sh
./remove_mautic.sh

# 2. Informar configurações do banco:
# Host do banco: localhost
# Porta: 3306
# Nome do banco: mautic
# Usuário: root
# Senha: ********

# 3. Informar caminho do Mautic:
# Caminho: /var/www/html/mautic

# 4. Escolher backup:
# Criar backup? (s/N): s

# 5. Confirmar remoção:
# Digite 'CONFIRMAR' para continuar: CONFIRMAR

# 6. Aguardar remoção completa
# ✅ Backup criado
# ✅ Tabelas removidas
# ✅ Diretório removido
```

## 📂 Estrutura do Projeto

Após a instalação, a estrutura será:

```text
mautic/
├── bin/
├── config/
├── media/
├── var/
├── vendor/
├── composer.json
└── ...
```

## 🔧 Pós-Instalação

### Configuração do Servidor Web

**Apache (.htaccess):**
```apache
<VirtualHost *:80>
    DocumentRoot /caminho/para/mautic
    ServerName mkt.seu-domínio.com.br
    
    <Directory /caminho/para/mautic>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

**Nginx:**
```nginx
server {
    listen 80;
    server_name mkt.seu-domínio.com.br;
    root /caminho/para/mautic;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Erro de permissões:**

```bash
sudo chown -R www-data:www-data /caminho/para/mautic
sudo chmod -R 775 /caminho/para/mautic/var /caminho/para/mautic/config
```

2. **Erro de conexão com banco:**

- Verifique se o MySQL está rodando
- Confirme as credenciais do banco
- Teste a conexão manualmente

3. **Composer não encontrado:**

```bash
# Instalar Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### Problemas com o Script de Remoção

1. **Erro de conexão com banco:**

```bash
# Verificar se o MySQL está rodando
sudo systemctl status mysql
sudo systemctl status mariadb

# Testar conexão manualmente
mysql -h localhost -u root -p
```

2. **Permissões negadas para remoção:**

```bash
# Executar com sudo se necessário
sudo ./remove_mautic.sh

# Ou corrigir permissões manualmente
sudo chmod -R 755 /caminho/para/mautic
sudo rm -rf /caminho/para/mautic
```

3. **Backup falhou:**

```bash
# Verificar espaço em disco
df -h /tmp

# Criar backup manual
mysqldump -u usuario -p nome_banco > backup_manual.sql
tar -czf backup_arquivos.tar.gz /caminho/para/mautic
```

4. **Script não executa (erro de permissão):**

```bash
# Verificar permissões
ls -la remove_mautic.sh

# Aplicar permissões corretas
chmod +x remove_mautic.sh

# Se necessário, executar com bash
bash remove_mautic.sh
```

## 📦 Arquivos Necessários

**⚠️ IMPORTANTE:** Ambos os scripts devem estar presentes no servidor para funcionalidade completa.

### 📁 Lista de Arquivos

```text
Scripts do Mautic/
├── install_mautic.sh      # Script de instalação
├── remove_mautic.sh       # Script de remoção
└── README.md              # Documentação
```

### 🔐 Permissões Necessárias

```bash
# Verificar estrutura e permissões
ls -la *.sh

# Resultado esperado:
# -rwxr-xr-x 1 user user 25123 Dec 12 10:30 install_mautic.sh
# -rwxr-xr-x 1 user user 15234 Dec 12 10:30 remove_mautic.sh

# Se as permissões estiverem incorretas:
chmod +x *.sh
```

### 📋 Checklist de Preparação

- [ ] Ambos os scripts baixados no servidor
- [ ] Permissões de execução aplicadas (`chmod +x *.sh`)
- [ ] PHP 8.0+ instalado
- [ ] MySQL/MariaDB configurado
- [ ] Composer instalado
- [ ] Acesso root/sudo disponível (recomendado)

## 📈 Versões Suportadas

- **Mautic:** 6.0+
- **PHP:** 8.0+
- **MySQL:** 5.7+ / MariaDB 10.2+
- **Composer:** 2.0+

## 🤝 Contribuição

Sinta-se à vontade para contribuir com melhorias:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 📞 Suporte

Para suporte e dúvidas sobre os scripts:

- Abra uma issue no GitHub
- Entre em contato com o autor: Rhafaman

### 🆘 Antes de Solicitar Suporte

1. **Verifique as permissões dos scripts:**

   ```bash
   ls -la *.sh
   chmod +x *.sh  # Se necessário
   ```

2. **Verifique os logs de erro:**

   - Para o instalador: verificar outputs durante execução
   - Para o removedor: verificar conexão com banco primeiro

3. **Teste os pré-requisitos:**

   ```bash
   php --version
   composer --version
   mysql --version
   ```

4. **Para problemas de instalação:** Inclua informações sobre:

   - Versão do PHP
   - Sistema operacional
   - Versão do Mautic tentando instalar
   - Mensagem de erro completa

5. **Para problemas de remoção:** Inclua informações sobre:

   - Configurações do banco de dados
   - Caminho do Mautic
   - Mensagens de erro do script

---

*Desenvolvido com ❤️ por Rhafaman*  
*Scripts para instalação e remoção automatizada do Mautic v6.0+*
