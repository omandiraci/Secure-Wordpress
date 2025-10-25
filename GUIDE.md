# 🔒 Secure WordPress - Kapsamlı Kılavuz

Bu kılavuz, güvenlik odaklı Docker ile WordPress kurulumunun tüm detaylarını içerir. Production-ready güvenlik araçları ve monitoring çözümleri ile birlikte gelir.

## 📋 İçindekiler

1. [Gereksinimler](#gereksinimler)
2. [Kurulum](#kurulum)
3. [Konfigürasyon](#konfigürasyon)
4. [Kullanım](#kullanım)
5. [Güvenlik Araçları](#güvenlik-araçları)
6. [Monitoring & Logging](#monitoring--logging)
7. [Backup & Recovery](#backup--recovery)
8. [Otomatik Güncellemeler](#otomatik-güncellemeler)
9. [Bakım](#bakım)
10. [Sorun Giderme](#sorun-giderme)
11. [Gelişmiş Kullanım](#gelişmiş-kullanım)

## 🔧 Gereksinimler

### Sistem Gereksinimleri
- **RAM**: Minimum 4GB, Önerilen 8GB+ (Monitoring araçları için)
- **Disk**: Minimum 20GB boş alan (Logs ve backup için)
- **İşlemci**: 4 çekirdek önerilir (Güvenlik araçları için)
- **Network**: Domain adı (SSL sertifikası için)

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
git clone https://github.com/yourusername/Secure-Wordpress.git
cd Secure-Wordpress

# Veya ZIP olarak indirin ve açın
wget https://github.com/yourusername/Secure-Wordpress/archive/main.zip
unzip main.zip
cd Secure-Wordpress-main
```

### 2. Otomatik Kurulum (Önerilen)
```bash
# Domain adınızla otomatik kurulum
./setup.sh yourdomain.com

# Bu script şunları yapar:
# - Güvenli şifreler oluşturur
# - WordPress güvenlik anahtarları üretir
# - .env dosyasını oluşturur
# - Gerekli klasörleri hazırlar
# - Container'ları başlatır
```

### 3. Manuel Kurulum
```bash
# .env dosyasını oluşturun
cp .env.example .env

# .env dosyasını düzenleyin
nano .env

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

## 🛡️ Güvenlik Araçları

### Traefik Reverse Proxy
```bash
# Traefik dashboard'a erişim
https://traefik.yourdomain.com:8080

# SSL sertifikalarını kontrol et
docker-compose exec traefik cat /letsencrypt/acme.json

# Traefik loglarını görüntüle
docker-compose logs traefik
```

### Fail2Ban Brute Force Koruması
```bash
# Fail2Ban durumunu kontrol et
docker-compose exec fail2ban fail2ban-client status

# Aktif jail'leri listele
docker-compose exec fail2ban fail2ban-client status sshd
docker-compose exec fail2ban fail2ban-client status apache-auth

# Engellenen IP'leri görüntüle
docker-compose exec fail2ban fail2ban-client status apache-auth

# IP'yi manuel engelle
docker-compose exec fail2ban fail2ban-client set apache-auth banip 192.168.1.100

# IP'yi engelden çıkar
docker-compose exec fail2ban fail2ban-client set apache-auth unbanip 192.168.1.100
```

### WordPress Güvenlik Ayarları
```bash
# WordPress güvenlik durumunu kontrol et
docker-compose exec wordpress wp --allow-root core version
docker-compose exec wordpress wp --allow-root plugin list

# Güvenlik eklentilerini yükle
docker-compose exec wordpress wp --allow-root plugin install wordfence --activate
docker-compose exec wordpress wp --allow-root plugin install limit-login-attempts --activate

# WordPress güvenlik ayarlarını kontrol et
docker-compose exec wordpress wp --allow-root config get DISALLOW_FILE_EDIT
docker-compose exec wordpress wp --allow-root config get FORCE_SSL_ADMIN
```

### Container Güvenlik
```bash
# Container güvenlik durumunu kontrol et
docker inspect wordpress | grep -i security
docker inspect db | grep -i security

# Network izolasyonunu kontrol et
docker network ls
docker network inspect secure-wordpress_wpnet

# Port erişimini kontrol et
netstat -tlnp | grep 80
netstat -tlnp | grep 443
```

### SSL Sertifikası Yönetimi
```bash
# SSL sertifikalarını kontrol et
docker-compose exec traefik ls -la /letsencrypt/

# Sertifika yenileme
docker-compose restart traefik

# SSL test
curl -I https://yourdomain.com
```

## 📊 Monitoring & Logging

### Prometheus Metrics
```bash
# Prometheus'a erişim
https://monitor.yourdomain.com

# Metrics endpoint'lerini kontrol et
curl http://localhost:9090/api/v1/targets

# Custom metrics ekle
# prometheus/prometheus.yml dosyasını düzenleyin
```

### Grafana Dashboard
```bash
# Grafana'ya erişim
https://dashboard.yourdomain.com
# Kullanıcı: admin
# Şifre: .env dosyasındaki GRAFANA_ADMIN_PASSWORD

# Dashboard'ları import et
# Grafana web arayüzünden dashboard ID'leri ile import yapın
```

### Log Yönetimi
```bash
# WordPress loglarını görüntüle
tail -f logs/wordpress/access.log
tail -f logs/wordpress/error.log

# MySQL loglarını görüntüle
tail -f logs/database/error.log
tail -f logs/database/slow.log

# Traefik loglarını görüntüle
tail -f logs/traefik/traefik.log

# Log rotasyonu
docker-compose exec wordpress logrotate -f /etc/logrotate.conf
```

## 💾 Backup & Recovery

### Restic Backup
```bash
# Manuel backup çalıştır
docker-compose exec restic-backup /config/backup.sh

# Backup'ları listele
docker-compose exec restic-backup restic snapshots

# Backup'ı geri yükle
docker-compose exec restic-backup restic restore latest --target /

# Backup repository'sini kontrol et
docker-compose exec restic-backup restic stats
```

### Otomatik Backup
```bash
# Cron job ekle (host sistemde)
crontab -e

# Günlük backup (her gece 02:00)
0 2 * * * cd /path/to/Secure-Wordpress && docker-compose exec restic-backup /config/backup.sh
```

### Backup Stratejisi
```bash
# Günlük yedekleme scripti
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/$DATE"

mkdir -p $BACKUP_DIR

# MySQL yedekleme
docker-compose exec -T db mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > $BACKUP_DIR/mysql.sql

# WordPress dosyaları yedekleme
docker run --rm -v secure-wordpress_wpvolume:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/wordpress.tar.gz -C /data .

# Eski yedekleri temizle (30 günden eski)
find /backups -type d -mtime +30 -exec rm -rf {} \;
```

## 🔄 Otomatik Güncellemeler

### Watchtower
```bash
# Watchtower durumunu kontrol et
docker-compose logs watchtower

# Manuel güncelleme
docker-compose exec watchtower watchtower --run-once

# Güncelleme bildirimlerini kontrol et
# Email ayarlarını .env dosyasında yapın
```

### Container Güncellemeleri
```bash
# Tüm container'ları güncelle
docker-compose pull
docker-compose up -d

# Belirli bir container'ı güncelle
docker-compose pull wordpress
docker-compose up -d wordpress

# Güncelleme sonrası kontrol
docker-compose ps
docker-compose logs
```

### WordPress Güncellemeleri
```bash
# WordPress core güncelle
docker-compose exec wordpress wp --allow-root core update

# Plugin'leri güncelle
docker-compose exec wordpress wp --allow-root plugin update --all

# Theme'leri güncelle
docker-compose exec wordpress wp --allow-root theme update --all

# Güncelleme sonrası kontrol
docker-compose exec wordpress wp --allow-root core version
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
- [GitHub Issues](https://github.com/yourusername/Secure-Wordpress/issues)
- [Docker Community](https://forums.docker.com/)
- [WordPress Support](https://wordpress.org/support/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

---

**Not**: Bu kılavuz sürekli güncellenmektedir. En son versiyon için GitHub repository'sini kontrol edin.

## 🔒 Güvenlik Uyarıları

- **Production Kullanımı**: Bu kurulum production ortamı için tasarlanmıştır
- **SSL Sertifikası**: Domain adınızı DNS'te sunucunuza yönlendirin
- **Güvenlik Güncellemeleri**: Düzenli olarak güvenlik güncellemelerini uygulayın
- **Backup**: Düzenli backup almayı unutmayın
- **Monitoring**: Sistem durumunu sürekli izleyin
