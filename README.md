# 🔒 Secure WordPress

Güvenlik odaklı, production-ready WordPress kurulumu. Bu proje, WordPress'i güvenli bir şekilde çalıştırmak için gerekli tüm araçları ve konfigürasyonları içerir.

## 🚀 Özellikler

### 🛡️ Güvenlik Araçları
- **Traefik**: Reverse proxy ve otomatik SSL sertifikası
- **Fail2Ban**: Brute force saldırı koruması
- **WordPress Security**: Güçlendirilmiş güvenlik ayarları
- **Container Security**: Docker güvenlik optimizasyonları

### 📊 Monitoring & Logging
- **Prometheus**: Metrics toplama
- **Grafana**: Monitoring dashboard
- **Structured Logging**: Ayrılmış log klasörleri
- **Real-time Monitoring**: Canlı sistem izleme

### 🔄 Otomatik Güncellemeler
- **Watchtower**: Container otomatik güncellemeleri
- **Email Notifications**: Güncelleme bildirimleri
- **Rollback Support**: Geri alma desteği

### 💾 Backup & Recovery
- **Restic**: Güvenli backup çözümü
- **Automated Backups**: Otomatik yedekleme
- **Encrypted Storage**: Şifreli depolama
- **Retention Policies**: Saklama politikaları

### 🐳 Container Management
- **Portainer**: Docker yönetim arayüzü
- **Multi-container**: Mikroservis mimarisi
- **Network Isolation**: Ağ izolasyonu
- **Resource Limits**: Kaynak sınırları

## 📋 Gereksinimler

- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ RAM
- 10GB+ Disk alanı
- Domain adı (SSL için)

## 🚀 Hızlı Başlangıç

### 1. Projeyi İndirin
```bash
git clone https://github.com/yourusername/Secure-Wordpress.git
cd Secure-Wordpress
```

### 2. Otomatik Kurulum
```bash
./setup.sh yourdomain.com
```

### 3. Manuel Kurulum
```bash
# .env dosyasını oluşturun
cp .env.example .env
# .env dosyasını düzenleyin
nano .env

# Container'ları başlatın
docker-compose up -d
```

## 🌐 Erişim Noktaları

Kurulum tamamlandıktan sonra aşağıdaki adreslerden erişebilirsiniz:

- **WordPress**: `https://yourdomain.com`
- **Traefik Dashboard**: `https://traefik.yourdomain.com:8080`
- **Grafana**: `https://dashboard.yourdomain.com`
- **Prometheus**: `https://monitor.yourdomain.com`
- **Portainer**: `https://docker.yourdomain.com`

## 🔧 Konfigürasyon

### Environment Variables
`.env` dosyasında aşağıdaki ayarları yapabilirsiniz:

```bash
# Domain ayarları
DOMAIN_NAME=yourdomain.com
ADMIN_EMAIL=admin@yourdomain.com

# Güvenlik ayarları
WORDPRESS_DEBUG=false
FORCE_SSL_ADMIN=true

# Backup ayarları
BACKUP_RETENTION_DAYS=30
```

### SSL Sertifikası
Traefik otomatik olarak Let's Encrypt SSL sertifikası oluşturur. Domain adınızı DNS'te sunucunuza yönlendirmeniz yeterlidir.

## 🛡️ Güvenlik Özellikleri

### WordPress Güvenlik
- Dosya düzenleme devre dışı
- SSL zorunlu admin erişimi
- Güçlü güvenlik anahtarları
- Otomatik güncellemeler

### Container Güvenlik
- Read-only dosya sistemi
- No-new-privileges
- Network izolasyonu
- Resource sınırları

### Network Güvenlik
- Reverse proxy
- SSL/TLS şifreleme
- Fail2Ban koruması
- Firewall kuralları

## 📊 Monitoring

### Grafana Dashboard
- Sistem metrikleri
- Container durumları
- Network trafiği
- Disk kullanımı

### Prometheus Metrics
- Container metrikleri
- WordPress performansı
- MySQL durumu
- Traefik istatistikleri

## 💾 Backup

### Otomatik Backup
```bash
# Backup'ı manuel çalıştır
docker-compose exec restic-backup /config/backup.sh

# Backup'ları listele
docker-compose exec restic-backup restic snapshots
```

### Backup Geri Yükleme
```bash
# Son backup'ı geri yükle
docker-compose exec restic-backup restic restore latest --target /
```

## 🔄 Güncellemeler

### Otomatik Güncellemeler
Watchtower her 24 saatte bir container'ları kontrol eder ve günceller.

### Manuel Güncelleme
```bash
# Tüm servisleri güncelle
docker-compose pull
docker-compose up -d

# Belirli bir servisi güncelle
docker-compose pull wordpress
docker-compose up -d wordpress
```

## 🚨 Sorun Giderme

### Logları Kontrol Et
```bash
# Tüm servislerin logları
docker-compose logs

# Belirli bir servisin logları
docker-compose logs wordpress
docker-compose logs db
```

### Container Durumları
```bash
# Container durumlarını kontrol et
docker-compose ps

# Container'ları yeniden başlat
docker-compose restart
```

### Disk Temizliği
```bash
# Kullanılmayan image'ları temizle
docker system prune -a

# Volume'ları temizle
docker volume prune
```

## 📚 Detaylı Dokümantasyon

- [GUIDE.md](GUIDE.md) - Detaylı kullanım kılavuzu
- [ADMINISTRATIVE-GUIDE.md](ADMINISTRATIVE-GUIDE.md) - Sistem yöneticisi kılavuzu

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 🆘 Destek

- GitHub Issues: [Issues](https://github.com/yourusername/Secure-Wordpress/issues)
- Email: admin@yourdomain.com

## 🙏 Teşekkürler

- [Traefik](https://traefik.io/) - Reverse proxy
- [Prometheus](https://prometheus.io/) - Monitoring
- [Grafana](https://grafana.com/) - Dashboard
- [Restic](https://restic.net/) - Backup
- [Fail2Ban](https://www.fail2ban.org/) - Security

---

**⚠️ Güvenlik Uyarısı**: Bu kurulum production ortamı için tasarlanmıştır. Geliştirme ortamında kullanmadan önce tüm güvenlik ayarlarını gözden geçirin.