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

# .env dosyası kontrolü
if [ ! -f .env.example ]; then
    echo -e "${RED}❌ .env.example dosyası bulunamadı!${NC}"
    exit 1
fi

# .env dosyasını oluştur
echo -e "${BLUE}📝 .env dosyası oluşturuluyor...${NC}"
cp .env.example .env

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

# .env dosyasını güncelle (# ayırıcı kullanıyoruz çünkü değerlerde | olabilir)
sed -i.bak "s#your_secure_password_here#${MYSQL_PASSWORD}#g" .env
sed -i.bak "s#your_secure_root_password_here#${MYSQL_ROOT_PASSWORD}#g" .env
sed -i.bak "s#your_backup_password_here#${BACKUP_PASSWORD}#g" .env
sed -i.bak "s#your_grafana_password_here#${GRAFANA_PASSWORD}#g" .env
sed -i.bak "s#yourdomain.com#${DOMAIN_NAME}#g" .env
sed -i.bak "s#admin@yourdomain.com#admin@${DOMAIN_NAME}#g" .env

# WordPress güvenlik anahtarlarını güncelle
sed -i.bak "s#your_auth_key_here#${AUTH_KEY}#g" .env
sed -i.bak "s#your_secure_auth_key_here#${SECURE_AUTH_KEY}#g" .env
sed -i.bak "s#your_logged_in_key_here#${LOGGED_IN_KEY}#g" .env
sed -i.bak "s#your_nonce_key_here#${NONCE_KEY}#g" .env
sed -i.bak "s#your_auth_salt_here#${AUTH_SALT}#g" .env
sed -i.bak "s#your_secure_auth_salt_here#${SECURE_AUTH_SALT}#g" .env
sed -i.bak "s#your_logged_in_salt_here#${LOGGED_IN_SALT}#g" .env
sed -i.bak "s#your_nonce_salt_here#${NONCE_SALT}#g" .env

# Backup dosyasını sil
rm -f .env.bak

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
