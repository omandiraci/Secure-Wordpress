# 🛠️ Lite WordPress - Administrative Guide

Bu dokümantasyon, Lite WordPress projesinin yönetici perspektifinden detaylı açıklamasını içerir.

## 📋 İçindekiler

1. [Proje Yapısı](#proje-yapısı)
2. [Dosya Açıklamaları](#dosya-açıklamaları)
3. [Script Detayları](#script-detayları)
4. [Güvenlik Mimarisi](#güvenlik-mimarisi)
5. [Operasyonel Süreçler](#operasyonel-süreçler)
6. [Sorun Giderme](#sorun-giderme)
7. [Bakım ve Güncelleme](#bakım-ve-güncelleme)

## 🏗️ Proje Yapısı

```
Lite-Workpress/
├── 📄 README.md                    # Proje özeti ve hızlı başlangıç
├── 📖 GUIDE.md                     # Kullanıcı kılavuzu
├── 🛠️ ADMINISTRATIVE-GUIDE.md     # Bu dosya - Yönetici kılavuzu
├── 🐳 docker-compose.yml          # Ana Docker konfigürasyonu
├── ⚙️ docker-compose.override.yml # Varsayılan değerler ve override
├── 🚀 setup.sh                    # Otomatik kurulum scripti
├── 📝 .env.example                # Environment değişkenleri şablonu
├── 🚫 .gitignore                  # Git ignore kuralları
└── 🔒 .env                        # Hassas bilgiler (GitHub'a yüklenmez)
```

## 📁 Dosya Açıklamaları

### 🐳 **docker-compose.yml** - Ana Konfigürasyon

**Amaç**: Docker container'larının ana konfigürasyonu

**Özellikler**:
- **MySQL 8.0**: Veritabanı servisi
- **WordPress 6.4-apache**: Web servisi
- **Güvenlik Sertleştirmesi**: Read-only, no-new-privileges
- **Network İzolasyonu**: Özel bridge network
- **Volume Yönetimi**: Kalıcı veri saklama

**Güvenlik Özellikleri**:
```yaml
security_opt:
  - no-new-privileges:true    # Privilege escalation engelleme
read_only: true               # Salt okunur container
tmpfs:                        # Geçici dosyalar RAM'de
  - /tmp
  - /var/run/mysqld
user: "33:33"                 # www-data kullanıcısı
```

### ⚙️ **docker-compose.override.yml** - Varsayılan Değerler

**Amaç**: .env dosyası yoksa varsayılan değerlerle çalışma

**Özellikler**:
- **Environment Variable Fallback**: `${VAR:-default}`
- **Geliştirme Ortamı Desteği**: Hızlı test için
- **Güvenlik Uyarıları**: Üretim için uyarılar

**Kullanım Senaryoları**:
1. **Geliştirme**: Hızlı test için varsayılan değerler
2. **Demo**: Sunumlar için hızlı kurulum
3. **Fallback**: .env dosyası eksikse güvenli varsayılanlar

### 🚀 **setup.sh** - Otomatik Kurulum Scripti

**Amaç**: Güvenli ve otomatik WordPress kurulumu

#### **Script Fonksiyonları**:

##### 1. **Güvenlik Kontrolü**
```bash
# .env dosyası varlık kontrolü
if [ -f ".env" ]; then
    echo "⚠️ .env dosyası zaten mevcut!"
    read -p "Üzerine yazmak istiyor musunuz? (y/N): "
fi
```

##### 2. **Şifre Üretimi**
```bash
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}
```
- **25 karakter** uzunluğunda güçlü şifreler
- **Özel karakterler** filtrelenmiş
- **OpenSSL** tabanlı kriptografik güvenlik

##### 3. **Güvenlik Anahtarı Üretimi**
```bash
generate_key() {
    openssl rand -hex 32
}
```
- **64 karakter** hex anahtarlar
- **Docker Compose uyumlu** (özel karakter yok)
- **WordPress Security Keys** için optimize

##### 4. **Environment Dosyası Oluşturma**
```bash
cat > .env << EOF
MYSQL_DATABASE=wpdatabase
MYSQL_USER=wpuser
MYSQL_PASSWORD=${DB_PASSWORD}
# ... diğer değişkenler
EOF
```

##### 5. **Dosya İzinleri**
```bash
chmod 600 .env
```
- **Sadece owner** okuyabilir
- **Grup ve diğerleri** erişemez
- **Güvenlik standardı**

##### 6. **Docker Container Başlatma**
```bash
docker-compose up -d
```

##### 7. **Kurulum Doğrulama**
```bash
sleep 10
if docker-compose ps | grep -q "Up"; then
    echo "✅ Kurulum başarılı!"
else
    echo "❌ Kurulum başarısız!"
fi
```

#### **Script Çıktı Örneği**:
```
🚀 Lite WordPress Kurulum Scripti
==================================
🔐 Güvenli şifreler ve anahtarlar oluşturuluyor...
✅ Veritabanı şifresi oluşturuldu
✅ WordPress güvenlik anahtarları oluşturuldu
✅ .env dosyası güvenli şekilde oluşturuldu
✅ .env dosyası izinleri güvenli hale getirildi (600)
🐳 Docker container'ları başlatılıyor...
🔍 Kurulum kontrol ediliyor...
✅ Kurulum başarılı!
🌐 WordPress: http://localhost:8080
🗄️ MySQL: localhost:3306

📝 Önemli Bilgiler:
   • Veritabanı Şifresi: flgdhGZQzPO71d6nZ0hrYA6PF
   • .env dosyası güvenli şekilde oluşturuldu
   • Güvenlik anahtarları otomatik oluşturuldu

⚠️ GÜVENLİK UYARISI:
   • .env dosyasını kimseyle paylaşmayın
   • Şifreleri güvenli bir yerde saklayın
   • Üretim ortamında SSL sertifikası kullanın
```

### 📝 **.env.example** - Şablon Dosyası

**Amaç**: Manuel kurulum için şablon

**İçerik**:
- **MySQL Konfigürasyonu**: Veritabanı ayarları
- **WordPress Konfigürasyonu**: Web uygulaması ayarları
- **Güvenlik Anahtarları**: Placeholder değerler
- **Güvenlik Ayarları**: Production-ready ayarlar

### 🚫 **.gitignore** - Git Güvenlik Kuralları

**Amaç**: Hassas dosyaların GitHub'a yüklenmesini engelleme

**Korunan Dosyalar**:
```
.env                    # Ana environment dosyası
.env.local             # Yerel environment
.env.production        # Üretim environment
.env.backup            # Backup dosyaları
.env.*                 # Tüm .env varyantları
mysqlvolume/           # Docker volume verileri
wpvolume/              # WordPress dosyaları
```

## 🔐 Güvenlik Mimarisi

### **Çok Katmanlı Güvenlik**

#### **1. Katman: Container Güvenliği**
- **Read-Only Container**: Dosya sistemine yazma engeli
- **No New Privileges**: Yetki yükseltme engeli
- **Specific User**: Root yetkileri kullanılmaz
- **Tmpfs**: Geçici dosyalar RAM'de

#### **2. Katman: Network Güvenliği**
- **Isolated Network**: Özel bridge network
- **Internal Communication**: Container'lar arası güvenli iletişim
- **Port Mapping**: Sadece gerekli portlar açık

#### **3. Katman: Veri Güvenliği**
- **Encrypted Passwords**: Güçlü şifreler
- **Security Keys**: WordPress şifreleme anahtarları
- **File Permissions**: 600 izinleri
- **Volume Isolation**: Veri izolasyonu

#### **4. Katman: Kod Güvenliği**
- **Specific Versions**: Sabit sürüm numaraları
- **Security Headers**: WordPress güvenlik ayarları
- **Debug Disabled**: Üretim güvenliği
- **File Edit Disabled**: Kod düzenleme engeli

## ⚙️ Operasyonel Süreçler

### **Kurulum Süreci**

#### **Otomatik Kurulum (Önerilen)**
```bash
git clone https://github.com/omandiraci/Lite-wordpress.git
cd Lite-wordpress
./setup.sh
```

#### **Manuel Kurulum**
```bash
git clone https://github.com/omandiraci/Lite-wordpress.git
cd Lite-wordpress
cp .env.example .env
# .env dosyasını düzenle
docker-compose up -d
```

#### **Varsayılan Değerlerle Kurulum**
```bash
git clone https://github.com/omandiraci/Lite-wordpress.git
cd Lite-wordpress
docker-compose up -d
```

### **Bakım Süreçleri**

#### **Günlük Kontroller**
```bash
# Container durumu
docker-compose ps

# Log kontrolü
docker-compose logs --tail=100

# Disk kullanımı
docker system df
```

#### **Haftalık Bakım**
```bash
# Güncellemeleri kontrol et
docker-compose pull

# Container'ları yeniden başlat
docker-compose up -d

# Eski image'ları temizle
docker image prune -f
```

#### **Aylık Bakım**
```bash
# Sistem temizliği
docker system prune -a

# Volume temizliği
docker volume prune

# Log rotasyonu
docker-compose logs --tail=1000 > logs/$(date +%Y%m%d).log
```

### **Yedekleme Süreçleri**

#### **Veritabanı Yedekleme**
```bash
# MySQL dump
docker-compose exec -T db mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > backup_$(date +%Y%m%d).sql

# Volume yedekleme
docker run --rm -v lite-workpress_mysqlvolume:/data -v $(pwd):/backup alpine tar czf /backup/mysql_$(date +%Y%m%d).tar.gz -C /data .
```

#### **WordPress Dosya Yedekleme**
```bash
# WordPress volume yedekleme
docker run --rm -v lite-workpress_wpvolume:/data -v $(pwd):/backup alpine tar czf /backup/wordpress_$(date +%Y%m%d).tar.gz -C /data .
```

#### **Otomatik Yedekleme Scripti**
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/$DATE"

mkdir -p $BACKUP_DIR

# Veritabanı yedekleme
docker-compose exec -T db mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > $BACKUP_DIR/mysql.sql

# WordPress dosyaları yedekleme
docker run --rm -v lite-workpress_wpvolume:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/wordpress.tar.gz -C /data .

# Eski yedekleri temizle (7 günden eski)
find /backups -type d -mtime +7 -exec rm -rf {} \;
```

## 🐛 Sorun Giderme

### **Yaygın Sorunlar**

#### **Container Başlamıyor**
```bash
# Log'ları kontrol et
docker-compose logs

# Port çakışması kontrol et
netstat -tlnp | grep 8080

# Container'ı yeniden oluştur
docker-compose up -d --force-recreate
```

#### **Veritabanı Bağlantı Hatası**
```bash
# MySQL container durumu
docker-compose exec db mysql -u root -p -e "SELECT 1"

# Network bağlantısı
docker-compose exec wordpress ping db

# Environment değişkenleri
docker-compose exec wordpress env | grep WORDPRESS
```

#### **WordPress Erişim Sorunu**
```bash
# Container durumu
docker-compose ps

# Port mapping
docker port wpsunucu

# Firewall kontrolü
sudo ufw status
```

#### **Dosya İzin Sorunları**
```bash
# .env dosyası izinleri
ls -la .env

# İzinleri düzelt
chmod 600 .env

# Volume izinleri
docker-compose exec wordpress ls -la /var/www/html
```

### **Debug Komutları**

#### **Container İçine Erişim**
```bash
# WordPress container
docker-compose exec wordpress bash

# MySQL container
docker-compose exec db bash
```

#### **Log Takibi**
```bash
# Tüm servisler
docker-compose logs -f

# Belirli servis
docker-compose logs -f wordpress
docker-compose logs -f db
```

#### **Sistem Bilgileri**
```bash
# Container kaynak kullanımı
docker stats

# Disk kullanımı
docker system df

# Network bilgileri
docker network ls
docker network inspect lite-workpress_wpnet
```

## 🔄 Bakım ve Güncelleme

### **Güvenlik Güncellemeleri**

#### **Container Güncellemeleri**
```bash
# Yeni image'ları çek
docker-compose pull

# Container'ları güncelle
docker-compose up -d

# Eski image'ları temizle
docker image prune -f
```

#### **Güvenlik Taraması**
```bash
# Docker Scout ile güvenlik açıkları
docker scout cves wordpress:6.4-apache
docker scout cves mysql:8.0
```

### **Performans Optimizasyonu**

#### **Kaynak İzleme**
```bash
# CPU ve RAM kullanımı
docker stats --no-stream

# Disk I/O
docker exec wpsunucu iostat -x 1

# Network trafiği
docker exec wpsunucu netstat -i
```

#### **Optimizasyon Ayarları**
```yaml
# docker-compose.yml'de resource limits
services:
  wordpress:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

### **Monitoring ve Alerting**

#### **Health Check**
```yaml
# docker-compose.yml'de health check
services:
  wordpress:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

#### **Log Monitoring**
```bash
# Log seviyelerini ayarla
export WORDPRESS_DEBUG_LOG=true

# Log dosyalarını izle
tail -f /var/log/wordpress/error.log
```

## 📊 Performans Metrikleri

### **Önerilen Sistem Gereksinimleri**

#### **Minimum Gereksinimler**
- **RAM**: 2GB
- **CPU**: 2 çekirdek
- **Disk**: 10GB
- **Network**: 100 Mbps

#### **Önerilen Gereksinimler**
- **RAM**: 4GB+
- **CPU**: 4 çekirdek+
- **Disk**: 50GB+ SSD
- **Network**: 1 Gbps

### **Performans Benchmark'ları**

#### **WordPress Yükleme Süreleri**
- **İlk Kurulum**: ~2-3 dakika
- **Container Başlatma**: ~30-60 saniye
- **Sayfa Yükleme**: <2 saniye
- **Admin Panel**: <3 saniye

#### **Kaynak Kullanımı**
- **WordPress Container**: ~200-400MB RAM
- **MySQL Container**: ~300-600MB RAM
- **Disk Kullanımı**: ~1-2GB (boş kurulum)

## 🚨 Acil Durum Prosedürleri

### **Container Çökmesi**
```bash
# Acil durumda container'ları yeniden başlat
docker-compose restart

# Eğer çalışmazsa, force recreate
docker-compose up -d --force-recreate

# Veri kaybını önlemek için volume'ları kontrol et
docker volume ls
```

### **Veri Kaybı**
```bash
# Son yedekten geri yükleme
docker-compose down
docker volume rm lite-workpress_mysqlvolume lite-workpress_wpvolume
docker-compose up -d

# Yedekten geri yükleme
tar -xzf backup_20241024.tar.gz -C /var/lib/docker/volumes/lite-workpress_mysqlvolume/_data/
```

### **Güvenlik İhlali**
```bash
# Tüm container'ları durdur
docker-compose down

# Güvenlik anahtarlarını yenile
./setup.sh

# Container'ları yeniden başlat
docker-compose up -d

# Log'ları analiz et
docker-compose logs | grep -i "error\|warning\|failed"
```

## 📞 Destek ve İletişim

### **Dokümantasyon**
- **README.md**: Hızlı başlangıç
- **GUIDE.md**: Kullanıcı kılavuzu
- **ADMINISTRATIVE-GUIDE.md**: Bu dosya

### **Topluluk Desteği**
- **GitHub Issues**: [https://github.com/omandiraci/Lite-wordpress/issues](https://github.com/omandiraci/Lite-wordpress/issues)
- **Docker Community**: [https://forums.docker.com/](https://forums.docker.com/)
- **WordPress Support**: [https://wordpress.org/support/](https://wordpress.org/support/)

### **Güvenlik Raporlama**
Güvenlik açıkları için: security@example.com

---

**Son Güncelleme**: 2024-10-24  
**Versiyon**: 1.0  
**Yazar**: Lite WordPress Team
