# 🚀 Instalador Automatizado do Mautic

Um script bash para instalação automatizada do Mautic Marketing Automation Platform.

## 📋 Descrição

Este script automatiza completamente a instalação do Mautic, incluindo:
- Download e configuração da versão especificada
- Configuração do banco de dados
- Criação do usuário administrador
- Configuração de permissões adequadas
- Cache warming e otimizações

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

## 🚀 Instalação

1. **Clone ou baixe o script:**
```bash
wget https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/install_mautic.sh
# ou
curl -O https://raw.githubusercontent.com/seu-usuario/mautic-installer/main/install_mautic.sh
```

2. **Torne o script executável:**
```bash
chmod +x install_mautic.sh
```

3. **Execute o script:**
```bash
./install_mautic.sh
```

## 📝 Configuração

Durante a execução, o script solicitará as seguintes informações:

### 🔧 Configuração da Versão
- **Versão do Mautic** (padrão: 6.0.3)

### 📁 Configuração do Projeto
- **Nome do diretório** (padrão: mautic)
- **URL do site** (ex: https://mkt.seu-domínio.com.br)

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

- ✅ Verificação automática de dependências
- ✅ Instalação via Composer
- ✅ Configuração completa do banco de dados
- ✅ Criação automática do usuário administrador
- ✅ Configuração de permissões otimizadas
- ✅ Cache warming
- ✅ Recarregamento de plugins
- ✅ Interface colorida e amigável
- ✅ Validação de inputs obrigatórios
- ✅ Confirmação antes da instalação

## 🎯 Exemplo de Uso

```bash
./install_mautic.sh

# Seguir os prompts:
# Versão do Mautic: 6.0.3
# Nome do diretório: meu-mautic
# URL: https://mkt.meusite.com.br
# Configurações do banco...
# Configurações do admin...
```

## 📂 Estrutura do Projeto

Após a instalação, a estrutura será:
```
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

## 📈 Versões Suportadas

- **Mautic:** 6.0+
- **PHP:** 8.0+
- **MySQL:** 5.7+ / MariaDB 10.2+

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

Para suporte e dúvidas:
- Abra uma issue no GitHub
- Entre em contato com o autor: Rhafaman

---

*Desenvolvido com ❤️ por Rhafaman* 