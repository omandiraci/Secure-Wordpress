# 🌐 Uzak Sunucu Kurulum Rehberi

Bu kılavuz, Secure-WordPress'i uzak bir sunucuda çalıştırmak için adım adım talimatlar içerir.

## 📋 Gereksinimler

### Sunucu Gereksinimleri
- **Ubuntu 20.04+** veya **Debian 11+** (önerilir)
- **Minimum 4GB RAM**
- **20GB+ boş disk alanı**
- **Public IP adresi** veya **Domain adı**
- **Root veya sudo yetkisi**

### Yazılım Gereksinimleri
```bash
# Docker kurulumu
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker Compose kurulumu
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Git kurulumu
sudo apt update
sudo apt install -y git
```

## �� Kurulum Adımları

### 1. Projeyi Klonlayın

```bash
# SSH ile sunucuya bağlanın
ssh user@your-server-ip

# Projeyi indirin
cd /opt
sudo git clone https://github.com/your-username/Secure-Wordpress.git
cd Secure-Wordpress

# İzinleri ayarlayın
sudo chown -R $USER:$USER .
```

### 2. Firewall Ayarları

```bash
# UFW firewall kullanıyorsanız
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 8080/tcp # Traefik Dashboard (opsiyonel)
sudo ufw reload
sudo ufw status
```

### 3. Kurulum Scriptini Çalıştırın

#### A) Domain Adı ile Kurulum (Önerilir)
```bash
# Domain DNS ayarlarını yapın (A kaydı sunucu IP'nize)
# Örnek: example.com -> 123.45.67.89

# Setup scriptini domain ile çalıştırın
chmod +x setup.sh
./setup.sh example.com

# Kurulum tamamlandıktan sonra erişim:
# http://example.com
# https://example.com (SSL otomatik alınır)
```

#### B) IP Adresi ile Kurulum (Test için)
```bash
# Sunucu IP'nizi kullanın
./setup.sh 123.45.67.89

# Kurulum tamamlandıktan sonra erişim:
# http://123.45.67.89
```

## 🔧 Manuel Kurulum (İsteğe Bağlı)

```bash
# .env dosyasını oluşturun
cp .env.example .env

# .env dosyasını düzenleyin
nano .env

# Önemli: Aşağıdaki değerleri değiştirin
DOMAIN_NAME=your-server-ip-or-domain
ADMIN_EMAIL=admin@yourdomain.com
MYSQL_PASSWORD=secure-random-password
MYSQL_ROOT_PASSWORD=another-secure-password

# Container'ları başlatın
docker-compose up -d

# Logları kontrol edin
docker-compose logs -f
```

## 🌐 Erişim Noktaları

### Domain ile Kurulum
- **WordPress**: http://example.com veya https://example.com
- **Traefik Dashboard**: http://traefik.example.com:8080
- **Grafana**: http://dashboard.example.com
- **Prometheus**: http://monitor.example.com
- **Portainer**: http://docker.example.com

### IP ile Kurulum
- **WordPress**: http://123.45.67.89
- **Traefik Dashboard**: http://123.45.67.89:8080

⚠️ **Not**: Subdomain'ler için wildcard DNS gerekir. IP ile kurulumda sadana ana WordPress sitesi erişilebilir olacaktır.

## 🔐 SSL Sertifikası (Let's Encrypt)

### Otomatik SSL Kurulumu

SSL sertifikası **sadece domain adı** ile çalışır. IP adresi için SSL sertifikası alınamaz.

```bash
# 1. Domain DNS kayıtlarını ayarlayın
# A kaydı: example.com -> Sunucu IP
# A kaydı: *.example.com -> Sunucu IP (wildcard için)

# 2. Domain ile kurulum yapın
./setup.sh example.com

# 3. SSL otomatik alınacak ve yenilenecek
# Traefik Let's Encrypt ile otomatik yapılandırılmıştır
```

### SSL Kontrolü

```bash
# SSL sertifikalarını kontrol edin
docker exec traefik cat /letsencrypt/acme.json | grep -i "example.com"

# HTTPS erişimi test edin
curl -I https://example.com
```

## 📊 Durum Kontrolü

```bash
# Container durumlarını kontrol edin
docker-compose ps

# Tüm container'lar UP durumunda olmalı
# NAME          STATUS
# traefik       Up
# wpsunucu      Up
# mysqlsunucu   Up
# grafana       Up
# prometheus    Up
# portainer     Up
# fail2ban      Up
# watchtower    Up

# Logları izleyin
docker-compose logs -f wordpress
docker-compose logs -f db
docker-compose logs -f traefik

# Sistem kaynaklarını kontrol edin
docker stats
```

## 🐛 Sorun Giderme

### WordPress Erişim Sorunu

```bash
# Container'ların durumunu kontrol edin
docker-compose ps

# WordPress loglarını kontrol edin
docker-compose logs wordpress

# MySQL bağlantısını test edin
docker-compose exec wordpress ping db

# Traefik routing'i kontrol edin
docker logs traefik | grep wordpress
```

### Veritabanı Bağlantı Hatası

```bash
# MySQL container'ının çalıştığını kontrol edin
docker-compose exec db mysql -uroot -p -e "SELECT 1"

# MySQL kullanıcılarını listeleyin
docker-compose exec db mysql -uroot -p -e "SELECT user, host FROM mysql.user;"

# .env dosyasındaki şifreleri kontrol edin
cat .env | grep MYSQL
```

### Port Çakışması

```bash
# Kullanılan portları kontrol edin
sudo netstat -tlnp | grep -E '80|443|8080'

# Başka bir servis port kullanıyorsa durdurun
sudo systemctl stop apache2  # Apache varsa
sudo systemctl stop nginx    # Nginx varsa
```

### Firewall Sorunu

```bash
# Firewall durumunu kontrol edin
sudo ufw status

# Gerekli portları açın
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

## 🔄 Güncelleme

```bash
# Projeyi güncelleyin
cd /opt/Secure-Wordpress
git pull origin main

# Container'ları yeniden başlatın
docker-compose down
docker-compose pull
docker-compose up -d
```

## 💾 Yedekleme

```bash
# Manuel yedekleme
docker-compose exec restic-backup /config/backup.sh

# Yedekleri listeleyin
docker-compose exec restic-backup restic snapshots

# Volume'ları yedekleyin
docker run --rm \
  -v secure-wordpress_mysqlvolume:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/mysql-$(date +%Y%m%d).tar.gz -C /data .

docker run --rm \
  -v secure-wordpress_wpvolume:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/wordpress-$(date +%Y%m%d).tar.gz -C /data .
```

## 🛑 Kaldırma

```bash
# Container'ları durdurun ve kaldırın
docker-compose down

# Volume'ları da sil (DİKKAT: Tüm veriler silinir!)
docker-compose down -v

# Projeyi kaldırın
cd ..
rm -rf Secure-Wordpress
```

## 📞 Destek

Sorun yaşarsanız:
1. Logları kontrol edin: `docker-compose logs`
2. GitHub Issues'a bakın
3. Dokümantasyonu inceleyin: README.md, GUIDE.md

## ✅ Kontrol Listesi

- [ ] Sunucuda Docker ve Docker Compose kurulu
- [ ] Firewall ayarları yapıldı (80, 443 portları açık)
- [ ] DNS kayıtları ayarlandı (domain kullanıyorsanız)
- [ ] .env dosyası güvenli şifrelerle oluşturuldu
- [ ] Container'lar başarıyla başlatıldı
- [ ] WordPress'e HTTP üzerinden erişilebiliyor
- [ ] SSL sertifikası alındı (domain kullanıyorsanız)
- [ ] Yedekleme stratejisi belirlendi

---

**🎉 Tebrikler!** WordPress siteniz uzak sunucuda çalışıyor!
