#!/bin/bash
# =============================================
# 🔧 MySQL Şifre Eşitleme ve Düzeltme Scripti
# =============================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}🔧 MySQL Veritabanı Düzeltme Başlatılıyor...${NC}"

# .env dosyası kontrolü
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env dosyası bulunamadı!${NC}"
    echo "Lütfen proje klasöründe (Secure-Wordpress/) çalıştırın."
    exit 1
fi

# .env değişkenlerini yükle
echo -e "${BLUE}📝 .env dosyası yükleniyor...${NC}"
set -a
source .env
set +a

# Değişkenlerin yüklendiğini kontrol et
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo -e "${RED}❌ .env dosyasında MYSQL_ROOT_PASSWORD veya MYSQL_PASSWORD bulunamadı!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ .env dosyası yüklendi${NC}"
echo -e "  MYSQL_DATABASE: $MYSQL_DATABASE"
echo -e "  MYSQL_USER: $MYSQL_USER"

# MySQL container çalışıyor mu kontrol et
if ! docker ps | grep -q mysqlsunucu; then
    echo -e "${YELLOW}⚠️  MySQL container çalışmıyor. Başlatılıyor...${NC}"
    docker-compose up -d db
    echo -e "${BLUE}⏳ MySQL'in hazır olması bekleniyor (15 saniye)...${NC}"
    sleep 15
fi

# Eski root şifresini loglardan bul (varsa)
echo -e "${BLUE}🔍 MySQL loglarından generated root password aranıyor...${NC}"
GENERATED_ROOT=$(docker logs mysqlsunucu 2>&1 | grep -i 'GENERATED ROOT PASSWORD' | tail -1 | awk '{print $NF}' | tr -d '\r\n')

# Root şifresi ile giriş testi
echo -e "${BLUE}🔐 Root şifresi test ediliyor...${NC}"
if docker exec -i mysqlsunucu mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ .env'deki root şifresi çalışıyor${NC}"
    ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
elif [ -n "$GENERATED_ROOT" ] && docker exec -i mysqlsunucu mysql -uroot -p"$GENERATED_ROOT" -e "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Loglardan bulunan generated root şifresi çalışıyor${NC}"
    echo -e "${BLUE}🔄 Root şifresi .env'dekiyle eşitleniyor...${NC}"
    ROOT_PASSWORD="$GENERATED_ROOT"
    docker exec -i mysqlsunucu mysql -uroot -p"$ROOT_PASSWORD" -e \
        "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; 
         ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; 
         FLUSH PRIVILEGES;" 2>/dev/null || true
    ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD"
    echo -e "${GREEN}✅ Root şifresi güncellendi${NC}"
else
    echo -e "${RED}❌ Root şifresi çalışmıyor!${NC}"
    echo -e "${YELLOW}💡 Çözüm: Veritabanını sıfırlayın (VERİLER SİLİNİR):${NC}"
    echo -e "   docker-compose down"
    echo -e "   docker volume rm secure-wordpress_mysqlvolume"
    echo -e "   docker-compose up -d"
    exit 1
fi

# wpuser şifresini kontrol et ve düzelt
echo -e "${BLUE}🔄 wpuser şifresi kontrol ediliyor...${NC}"
if docker exec -i mysqlsunucu mysql -uwpuser -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ wpuser şifresi zaten doğru${NC}"
else
    echo -e "${YELLOW}⚠️  wpuser şifresi yanlış, düzeltiliyor...${NC}"
    docker exec -i mysqlsunucu mysql -uroot -p"$ROOT_PASSWORD" -e \
        "ALTER USER 'wpuser'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; 
         FLUSH PRIVILEGES;"
    echo -e "${GREEN}✅ wpuser şifresi güncellendi${NC}"
fi

# Veritabanı erişim testi
echo -e "${BLUE}🧪 Veritabanı erişim testi...${NC}"
if docker exec -i mysqlsunucu mysql -uwpuser -p"$MYSQL_PASSWORD" -e "USE $MYSQL_DATABASE; SELECT 1;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Veritabanına erişim başarılı!${NC}"
else
    echo -e "${YELLOW}⚠️  Veritabanı bulunamadı, oluşturuluyor...${NC}"
    docker exec -i mysqlsunucu mysql -uroot -p"$ROOT_PASSWORD" -e \
        "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
         GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO 'wpuser'@'%';
         FLUSH PRIVILEGES;"
    echo -e "${GREEN}✅ Veritabanı oluşturuldu${NC}"
fi

# WordPress environment değişkenlerini kontrol et
echo -e "${BLUE}🔍 WordPress konfigürasyonu kontrol ediliyor...${NC}"
WP_DB_PASS=$(docker exec wpsunucu env | grep WORDPRESS_DB_PASSWORD | cut -d'=' -f2)
if [ "$WP_DB_PASS" = "$MYSQL_PASSWORD" ]; then
    echo -e "${GREEN}✅ WordPress DB şifresi doğru${NC}"
else
    echo -e "${YELLOW}⚠️  WordPress farklı şifre kullanıyor, yeniden başlatılıyor...${NC}"
    docker-compose restart wordpress
    sleep 5
fi

# Son test
echo -e "${BLUE}🧪 Son erişim testi...${NC}"
sleep 3
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8181 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo -e "${GREEN}✅ WordPress erişilebilir! (HTTP $HTTP_CODE)${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 Tüm düzeltmeler tamamlandı!${NC}"
    echo -e "${BLUE}📊 Veritabanı Bilgileri:${NC}"
    echo -e "  Veritabanı: $MYSQL_DATABASE"
    echo -e "  Kullanıcı: $MYSQL_USER"
    echo -e "  Host: db"
    echo -e ""
    echo -e "${BLUE}🌐 Erişim:${NC}"
    echo -e "  WordPress: http://$(curl -s ifconfig.me 2>/dev/null || echo 'SUNUCU-IP'):8181"
    echo -e "  WordPress: http://$DOMAIN_NAME:8181"
else
    echo -e "${YELLOW}⚠️  WordPress henüz hazır değil (HTTP $HTTP_CODE)${NC}"
    echo -e "${BLUE}💡 Log'ları kontrol edin:${NC}"
    echo -e "   docker-compose logs wordpress"
fi

