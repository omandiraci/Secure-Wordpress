#!/bin/bash
# =============================================
# 🐳 Secure WordPress Setup Script
# =============================================

set -e  # Hata olursa scripti durdur
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}🔒 Secure WordPress Kurulum Başlatılıyor...${NC}"

# Domain adı kontrolü
DOMAIN_NAME=${1:-"localhost"}
echo -e "${GREEN}🌍 Domain: $DOMAIN_NAME${NC}"

# .env oluştur
cat > .env << EOF
$(envsubst < .env.template)
EOF

# İzinleri sıkılaştır
chmod 600 .env
echo -e "${GREEN}✅ .env izinleri 600 olarak ayarlandı${NC}"

# Gerekli klasörleri oluştur
mkdir -p logs/wordpress logs/database logs/traefik backups
chmod -R 700 logs backups
echo -e "${GREEN}📁 Log ve backup klasörleri oluşturuldu${NC}"

# Docker servislerini başlat
echo -e "${BLUE}🐳 Docker container'ları başlatılıyor...${NC}"
docker-compose up -d --build

echo -e "${GREEN}✅ WordPress kurulumu tamamlandı!${NC}"
echo -e "${YELLOW}👉 https://$DOMAIN_NAME adresinden erişebilirsiniz.${NC}"
