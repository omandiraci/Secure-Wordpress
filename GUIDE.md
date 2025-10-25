# 🚀 Lite WordPress - Kapsamlı Kılavuz

Bu kılavuz, Docker ile WordPress kurulumunun tüm detaylarını içerir.

## 📋 İçindekiler

1. [Gereksinimler](#gereksinimler)
2. [Kurulum](#kurulum)
3. [Konfigürasyon](#konfigürasyon)
4. [Kullanım](#kullanım)
5. [Güvenlik](#güvenlik)
6. [Bakım](#bakım)
7. [Sorun Giderme](#sorun-giderme)
8. [Gelişmiş Kullanım](#gelişmiş-kullanım)

## 🔧 Gereksinimler

### Sistem Gereksinimleri
- **RAM**: Minimum 2GB, Önerilen 4GB+
- **Disk**: Minimum 10GB boş alan
- **İşlemci**: 2 çekirdek önerilir

### Yazılım Gereksinimleri
- **Docker**: 20.10.0+
- **Docker Compose**: 2.0.0+
- **Git**: 2.30.0+

### Kurulum Kontrolü
```bash
# Docker versiyonunu kontrol edin
docker --version

# Docker Compose versiyonunu kontrol edin
docker-compose --version

# Git versiyonunu kontrol edin
git --version
```

## 🛠️ Kurulum

### 1. Projeyi İndirin
```bash
# GitHub'dan klonlayın
git clone https://github.com/omandiraci/Lite-wordpress.git
cd Lite-wordpress

# Veya ZIP olarak indirin ve açın
wget https://github.com/omandiraci/Lite-wordpress/archive/main.zip
unzip main.zip
cd Lite-wordpress-main
```

### 2. Environment Dosyasını Kontrol Edin
```bash
# .env dosyasının varlığını kontrol edin
ls -la .env

# .env dosyasının içeriğini görüntüleyin (güvenlik için dikkatli olun)
cat .env
```

### 3. Docker Container'larını Başlatın
```bash
# Container'ları arka planda başlatın
docker-compose up -d

# Log'ları takip edin
docker-compose logs -f

# Container durumlarını kontrol edin
docker-compose ps
```

### 4. Kurulumu Doğrulayın
```bash
# WordPress container'ının çalıştığını kontrol edin
docker-compose exec wordpress ps aux

# MySQL container'ının çalıştığını kontrol edin
docker-compose exec db mysql -u root -p -e "SHOW DATABASES;"

# Network bağlantısını test edin
curl -I http://localhost:8080
```

## ⚙️ Konfigürasyon

### WordPress İlk Kurulum
1. **Tarayıcıda açın**: http://localhost:8080
2. **Dil seçin**: Türkçe
3. **Veritabanı bilgileri**:
   - Veritabanı Adı: `wpdatabase`
   - Kullanıcı Adı: `wpuser`
   - Şifre: `P@ssw0rd1245`
   - Veritabanı Sunucusu: `db`
   - Tablo Öneki: `wp_`

### .env Dosyası Özelleştirme
```bash
# .env dosyasını düzenleyin
nano .env

# Önemli değişkenler:
MYSQL_DATABASE=wpdatabase          # Veritabanı adı
MYSQL_USER=wpuser                  # MySQL kullanıcısı
MYSQL_PASSWORD=P@ssw0rd1245        # MySQL şifresi
WORDPRESS_DB_HOST=db               # Veritabanı host'u
```

### Güvenlik Anahtarları
```bash
# Yeni güvenlik anahtarları oluşturun
openssl rand -base64 64

# .env dosyasındaki anahtarları güncelleyin
nano .env
```

## 🎯 Kullanım

### Temel Komutlar
```bash
# Container'ları başlat
docker-compose up -d

# Container'ları durdur
docker-compose down

# Container'ları yeniden başlat
docker-compose restart

# Log'ları görüntüle
docker-compose logs

# Belirli bir servisin log'larını görüntüle
docker-compose logs wordpress
docker-compose logs db
```

### Container Yönetimi
```bash
# Container'lara erişim
docker-compose exec wordpress bash
docker-compose exec db mysql -u root -p

# Container'ları güncelle
docker-compose pull
docker-compose up -d

# Container'ları temizle
docker-compose down -v
docker system prune -a
```

### Veri Yönetimi
```bash
# Volume'ları listele
docker volume ls

# Volume'ları incele
docker volume inspect lite-workpress_mysqlvolume
docker volume inspect lite-workpress_wpvolume

# Yedekleme oluştur
docker run --rm -v lite-workpress_mysqlvolume:/data -v $(pwd):/backup alpine tar czf /backup/mysql-backup.tar.gz -C /data .
docker run --rm -v lite-workpress_wpvolume:/data -v $(pwd):/backup alpine tar czf /backup/wordpress-backup.tar.gz -C /data .
```

## 🔐 Güvenlik

### Güvenlik Kontrolleri
```bash
# Container güvenlik durumunu kontrol et
docker inspect wordpress | grep -i security
docker inspect db | grep -i security

# Network izolasyonunu kontrol et
docker network ls
docker network inspect lite-workpress_wpnet

# Port erişimini kontrol et
netstat -tlnp | grep 8080
```

### Güvenlik Güncellemeleri
```bash
# Güvenlik açıklarını kontrol et
docker scout cves wordpress:6.4-apache
docker scout cves mysql:8.0

# Güvenlik güncellemelerini uygula
docker-compose pull
docker-compose up -d
```

### SSL Sertifikası (Üretim)
```bash
# Let's Encrypt ile SSL
docker run --rm -v $(pwd)/certs:/etc/letsencrypt certbot/certbot certonly --standalone -d yourdomain.com

# SSL ile nginx proxy ekle
# docker-compose.override.yml dosyası oluşturun
```

## 🔧 Bakım

### Düzenli Bakım Görevleri
```bash
# Haftalık güncelleme
docker-compose pull
docker-compose up -d

# Aylık temizlik
docker system prune -a
docker volume prune

# Log rotasyonu
docker-compose logs --tail=1000 > logs/wordpress-$(date +%Y%m%d).log
```

### Yedekleme Stratejisi
```bash
# Günlük yedekleme scripti
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/$DATE"

mkdir -p $BACKUP_DIR

# MySQL yedekleme
docker-compose exec -T db mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > $BACKUP_DIR/mysql.sql

# WordPress dosyaları yedekleme
docker run --rm -v lite-workpress_wpvolume:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/wordpress.tar.gz -C /data .

# Eski yedekleri temizle (7 günden eski)
find /backups -type d -mtime +7 -exec rm -rf {} \;
```

### Performans İzleme
```bash
# Container kaynak kullanımı
docker stats

# Disk kullanımı
docker system df

# Log boyutları
docker-compose logs --tail=0 | wc -l
```

## 🐛 Sorun Giderme

### Yaygın Sorunlar

#### Container Başlamıyor
```bash
# Log'ları kontrol et
docker-compose logs

# Port çakışması kontrol et
netstat -tlnp | grep 8080

# Port'u değiştir
# docker-compose.yml'de "8080:80" -> "8081:80"
```

#### Veritabanı Bağlantı Hatası
```bash
# MySQL container'ının durumunu kontrol et
docker-compose exec db mysql -u root -p -e "SELECT 1"

# Network bağlantısını test et
docker-compose exec wordpress ping db

# Veritabanı kullanıcısını kontrol et
docker-compose exec db mysql -u root -p -e "SELECT User, Host FROM mysql.user;"
```

#### WordPress Erişim Sorunu
```bash
# Container'ın çalıştığını kontrol et
docker-compose ps

# Port mapping'i kontrol et
docker port wpsunucu

# Firewall kontrol et
sudo ufw status
```

### Debug Komutları
```bash
# Container içine erişim
docker-compose exec wordpress bash
docker-compose exec db bash

# Container log'larını takip et
docker-compose logs -f --tail=100

# Container'ı yeniden oluştur
docker-compose up -d --force-recreate

# Volume'ları temizle ve yeniden başlat
docker-compose down -v
docker-compose up -d
```

## 🚀 Gelişmiş Kullanım

### Production Deployment
```bash
# Production environment dosyası
cp .env .env.production

# Production ayarları
# .env.production dosyasını düzenleyin
nano .env.production

# Production'da çalıştır
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Scaling
```bash
# WordPress instance'larını artır
docker-compose up -d --scale wordpress=3

# Load balancer ekle
# nginx.conf ile load balancing
```

### Monitoring
```bash
# Prometheus ile monitoring
docker-compose -f docker-compose.monitoring.yml up -d

# Grafana dashboard
open http://localhost:3000
```

### CI/CD Pipeline
```bash
# GitHub Actions ile otomatik deployment
# .github/workflows/deploy.yml dosyası oluşturun
```

## 📞 Destek

### Yararlı Kaynaklar
- [Docker Documentation](https://docs.docker.com/)
- [WordPress Documentation](https://wordpress.org/support/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

### Topluluk
- [GitHub Issues](https://github.com/omandiraci/Lite-wordpress/issues)
- [Docker Community](https://forums.docker.com/)
- [WordPress Support](https://wordpress.org/support/)

---

**Not**: Bu kılavuz sürekli güncellenmektedir. En son versiyon için GitHub repository'sini kontrol edin.
