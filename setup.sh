#!/bin/bash

# Secure WordPress Kurulum Scripti
# Bu script güvenlik odaklı WordPress kurulumu yapar

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Secure WordPress Kurulum Scripti${NC}"
echo -e "${BLUE}====================================${NC}"

# Güvenli şifre oluşturma fonksiyonu
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Güvenli anahtar oluşturma fonksiyonu
generate_key() {
    openssl rand -hex 32
}

# Domain adı kontrolü
check_domain() {
    if [ -z "$1" ]; then
        echo -e "${YELLOW}⚠️  Domain adı gerekli!${NC}"
        echo -e "${YELLOW}   Kullanım: ./setup.sh yourdomain.com${NC}"
        exit 1
    fi
}

# Ana domain adını al
DOMAIN_NAME=${1:-"localhost"}

echo -e "${GREEN}🌐 Domain: $DOMAIN_NAME${NC}"
echo -e "${GREEN}🔐 Güvenli şifreler ve anahtarlar oluşturuluyor...${NC}"

# Güvenli şifreler oluştur
DB_PASSWORD=$(generate_password)
ROOT_PASSWORD=$(generate_password)
BACKUP_PASSWORD=$(generate_password)
GRAFANA_PASSWORD=$(generate_password)

# WordPress güvenlik anahtarları oluştur
AUTH_KEY=$(generate_key)
SECURE_AUTH_KEY=$(generate_key)
LOGGED_IN_KEY=$(generate_key)
NONCE_KEY=$(generate_key)
AUTH_SALT=$(generate_key)
SECURE_AUTH_SALT=$(generate_key)
LOGGED_IN_SALT=$(generate_key)
NONCE_SALT=$(generate_key)

echo -e "${GREEN}✅ Veritabanı şifresi oluşturuldu${NC}"
echo -e "${GREEN}✅ WordPress güvenlik anahtarları oluşturuldu${NC}"

# .env dosyası oluştur
cat > .env << EOF
# MySQL Database Configuration
MYSQL_DATABASE=wpdatabase
MYSQL_USER=wpuser
MYSQL_PASSWORD=$DB_PASSWORD
MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD

# WordPress Database Configuration
WORDPRESS_DB_HOST=db
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=$DB_PASSWORD
WORDPRESS_DB_NAME=wpdatabase

# WordPress Security Keys
AUTH_KEY=$AUTH_KEY
SECURE_AUTH_KEY=$SECURE_AUTH_KEY
LOGGED_IN_KEY=$LOGGED_IN_KEY
NONCE_KEY=$NONCE_KEY
AUTH_SALT=$AUTH_SALT
SECURE_AUTH_SALT=$SECURE_AUTH_SALT
LOGGED_IN_SALT=$LOGGED_IN_SALT
NONCE_SALT=$NONCE_SALT

# WordPress Security Settings
WORDPRESS_DEBUG=false
WORDPRESS_DEBUG_LOG=false
WORDPRESS_DEBUG_DISPLAY=false
WORDPRESS_SCRIPT_DEBUG=false

# Additional Security Settings
WORDPRESS_CONFIG_EXTRA=|
  define('DISALLOW_FILE_EDIT', true);
  define('DISALLOW_FILE_MODS', true);
  define('FORCE_SSL_ADMIN', true);
  define('WP_POST_REVISIONS', 3);
  define('AUTOSAVE_INTERVAL', 300);
  define('WP_CRON_LOCK_TIMEOUT', 60);
  define('EMPTY_TRASH_DAYS', 7);
  define('WP_ALLOW_REPAIR', false);
  define('DISABLE_WP_CRON', false);
  define('WP_MEMORY_LIMIT', '256M');
  define('WP_MAX_MEMORY_LIMIT', '512M');

# Email Configuration (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=admin@$DOMAIN_NAME

# Domain Configuration
DOMAIN_NAME=$DOMAIN_NAME
ADMIN_EMAIL=admin@$DOMAIN_NAME

# Backup Configuration
BACKUP_PASSWORD=$BACKUP_PASSWORD
BACKUP_RETENTION_DAYS=30

# Monitoring Configuration
GRAFANA_ADMIN_PASSWORD=$GRAFANA_PASSWORD
PROMETHEUS_RETENTION=200h
EOF

echo -e "${GREEN}✅ .env dosyası güvenli şekilde oluşturuldu${NC}"

# .env dosyası izinlerini güvenli hale getir
chmod 600 .env
echo -e "${GREEN}✅ .env dosyası izinleri güvenli hale getirildi (600)${NC}"

# Gerekli klasörleri oluştur
mkdir -p logs/wordpress logs/database logs/traefik backups
echo -e "${GREEN}📁 Logs ve backup klasörleri oluşturuldu${NC}"
echo -e "${GREEN}   • logs/wordpress/ - WordPress logları${NC}"
echo -e "${GREEN}   • logs/database/ - MySQL logları${NC}"
echo -e "${GREEN}   • logs/traefik/ - Traefik logları${NC}"
echo -e "${GREEN}   • backups/ - Backup dosyaları${NC}"

# .gitkeep dosyaları oluştur
touch logs/wordpress/.gitkeep logs/database/.gitkeep logs/traefik/.gitkeep backups/.gitkeep
echo -e "${GREEN}✅ .gitkeep dosyaları oluşturuldu${NC}"

# Docker Compose dosyasındaki domain adını güncelle
if [ "$DOMAIN_NAME" != "localhost" ]; then
    sed -i.bak "s/yourdomain.com/$DOMAIN_NAME/g" docker-compose.yml
    echo -e "${GREEN}✅ Docker Compose dosyası domain adı ile güncellendi${NC}"
fi

# Güvenlik uyarıları
echo -e "${YELLOW}⚠️  GÜVENLİK UYARILARI:${NC}"
echo -e "${YELLOW}   1. .env dosyasını asla paylaşmayın!${NC}"
echo -e "${YELLOW}   2. Domain adınızı DNS'te bu sunucuya yönlendirin${NC}"
echo -e "${YELLOW}   3. SSL sertifikası otomatik oluşturulacak${NC}"
echo -e "${YELLOW}   4. Fail2Ban brute force saldırıları engelleyecek${NC}"
echo -e "${YELLOW}   5. Monitoring araçları aktif olacak${NC}"

# Docker container'ları başlat
echo -e "${GREEN}🐳 Docker container'ları başlatılıyor...${NC}"
docker-compose up -d

# Container durumlarını kontrol et
echo -e "${GREEN}📊 Container durumları kontrol ediliyor...${NC}"
sleep 10
docker-compose ps

echo -e "${GREEN}🎉 Secure WordPress kurulumu tamamlandı!${NC}"
echo -e "${BLUE}📋 Erişim Bilgileri:${NC}"
echo -e "${BLUE}   • WordPress: https://$DOMAIN_NAME${NC}"
echo -e "${BLUE}   • Traefik Dashboard: https://traefik.$DOMAIN_NAME:8080${NC}"
echo -e "${BLUE}   • Grafana: https://dashboard.$DOMAIN_NAME (admin/$GRAFANA_PASSWORD)${NC}"
echo -e "${BLUE}   • Prometheus: https://monitor.$DOMAIN_NAME${NC}"
echo -e "${BLUE}   • Portainer: https://docker.$DOMAIN_NAME${NC}"

echo -e "${YELLOW}📝 Sonraki Adımlar:${NC}"
echo -e "${YELLOW}   1. DNS ayarlarınızı yapın${NC}"
echo -e "${YELLOW}   2. WordPress kurulumunu tamamlayın${NC}"
echo -e "${YELLOW}   3. Güvenlik eklentilerini yükleyin${NC}"
echo -e "${YELLOW}   4. Backup zamanlamasını ayarlayın${NC}"

echo -e "${GREEN}✅ Kurulum başarıyla tamamlandı!${NC}"