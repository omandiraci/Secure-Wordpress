#!/bin/bash
# =============================================
# 🐳 Secure WordPress Setup Script
# =============================================

set -e  # Hata olursa scripti durdur
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}🔒 Secure WordPress Kurulum Başlatılıyor...${NC}"

# Domain veya IP adresini al
DOMAIN_NAME=${1:-"localhost"}
echo -e "${GREEN}🌍 Domain/IP: $DOMAIN_NAME${NC}"

# .env dosyasını oluştur
echo -e "${BLUE}📝 .env dosyası oluşturuluyor...${NC}"

# Güvenli şifreler oluştur
MYSQL_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
BACKUP_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
GRAFANA_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)

# WordPress güvenlik anahtarları oluştur
AUTH_KEY=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
SECURE_AUTH_KEY=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
LOGGED_IN_KEY=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
NONCE_KEY=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
AUTH_SALT=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
SECURE_AUTH_SALT=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
LOGGED_IN_SALT=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
NONCE_SALT=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)

# .env dosyasını doğrudan oluştur (sed kullanmıyoruz - daha güvenli)
cat > .env << EOF
# MySQL Database Configuration
MYSQL_DATABASE=wpdatabase
MYSQL_USER=wpuser
MYSQL_PASSWORD=${MYSQL_PASSWORD}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# WordPress Database Configuration
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}
WORDPRESS_DB_NAME=wpdatabase

# WordPress Security Keys
AUTH_KEY=${AUTH_KEY}
SECURE_AUTH_KEY=${SECURE_AUTH_KEY}
LOGGED_IN_KEY=${LOGGED_IN_KEY}
NONCE_KEY=${NONCE_KEY}
AUTH_SALT=${AUTH_SALT}
SECURE_AUTH_SALT=${SECURE_AUTH_SALT}
LOGGED_IN_SALT=${LOGGED_IN_SALT}
NONCE_SALT=${NONCE_SALT}

# WordPress Security Settings
WORDPRESS_DEBUG=false
WORDPRESS_DEBUG_LOG=false
WORDPRESS_DEBUG_DISPLAY=false

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=admin@${DOMAIN_NAME}
SMTP_PASS=changeme123
SMTP_FROM=admin@${DOMAIN_NAME}

# Domain Configuration
DOMAIN_NAME=${DOMAIN_NAME}
ADMIN_EMAIL=admin@${DOMAIN_NAME}

# Backup Configuration
BACKUP_PASSWORD=${BACKUP_PASSWORD}
BACKUP_RETENTION_DAYS=30

# Monitoring Configuration
GRAFANA_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
PROMETHEUS_RETENTION=200h
EOF

# İzinleri sıkılaştır
chmod 600 .env
echo -e "${GREEN}✅ .env dosyası oluşturuldu ve izinler ayarlandı${NC}"

# Gerekli klasörleri oluştur
mkdir -p logs/wordpress logs/database logs/traefik backups
chmod -R 755 logs backups
echo -e "${GREEN}📁 Log ve backup klasörleri oluşturuldu${NC}"

# Docker servislerini başlat
echo -e "${BLUE}🐳 Docker container'ları başlatılıyor...${NC}"
docker-compose up -d

echo -e "${GREEN}✅ WordPress kurulumu tamamlandı!${NC}"
echo -e "${YELLOW}👉 HTTP: http://$DOMAIN_NAME${NC}"
echo -e "${YELLOW}👉 HTTPS: https://$DOMAIN_NAME (SSL sertifikası alındıktan sonra)${NC}"
echo -e "${BLUE}📊 Traefik Dashboard: http://$DOMAIN_NAME:8080${NC}"
echo -e "${BLUE}📈 Grafana: http://dashboard.$DOMAIN_NAME (Şifre: ${GRAFANA_PASSWORD})${NC}"
