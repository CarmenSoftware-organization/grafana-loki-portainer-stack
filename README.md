# Grafana Stack with Loki and Promtail

🚀 **Docker Compose setup สำหรับ Grafana, Loki และ Promtail พร้อมใช้งานบน Portainer**

## 📋 คำอธิบาย

Project นี้ประกอบด้วย:
- **Grafana** - สำหรับสร้าง Dashboard และ Visualization
- **Loki** - Log Aggregation System สำหรับเก็บและ Query logs
- **Promtail** - Log Collector สำหรับรวบรวม logs จากแหล่งต่างๆ

## 🏗️ โครงสร้างไฟล์

```
grafana-stack/
├── docker-compose.yml          # ไฟล์ Docker Compose หลัก
├── configs/                    # Directory สำหรับ Configuration files
│   ├── loki-config.yml        # Loki configuration
│   ├── promtail-config.yml    # Promtail configuration
│   ├── grafana-datasources.yml # Grafana data sources
│   └── grafana-dashboards.yml  # Grafana dashboard provisioning
├── dashboards/                 # Directory สำหรับ Dashboard JSON files
│   └── logs-dashboard.json    # Sample logs dashboard
├── data/                      # Directory สำหรับ Persistent data
│   ├── grafana/              # Grafana data
│   └── loki/                 # Loki data
└── README.md                 # คู่มือนี้
```

## 🚀 การติดตั้งและใช้งาน

### วิธีที่ 1: ใช้งานผ่าน Docker Compose

1. **Clone หรือ Download project**
   ```bash
   git clone <repository-url>
   cd grafana-stack
   ```

2. **สร้าง Directory สำหรับ Data (หากยังไม่มี)**
   ```bash
   mkdir -p data/grafana data/loki
   ```

3. **เปิดใช้งาน Stack**
   ```bash
   docker-compose up -d
   ```

4. **ตรวจสอบสถานะ**
   ```bash
   docker-compose ps
   ```

### วิธีที่ 2: Deploy บน Portainer

1. **เข้าสู่ Portainer Dashboard**
2. **ไปที่ Stacks → Add Stack**
3. **เลือก "Upload" และอัปโหลดไฟล์ `docker-compose.yml`**
4. **หรือใช้ "Web editor" และ Copy-Paste เนื้อหาไฟล์**
5. **ตั้งชื่อ Stack เช่น "grafana-stack"**
6. **กด "Deploy the stack"**

> **หมายเหตุ**: เมื่อใช้ Portainer ต้องแน่ใจว่าไฟล์ configuration ถูกต้องและ volumes ถูก mount อย่างถูกต้อง

## 🌐 การเข้าถึง Services

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| Grafana | http://localhost:3999 | admin | admin123 |
| Loki | http://localhost:3998 | - | - |

## 📊 Dashboard และ Data Sources

### Data Sources
- **Loki** จะถูก configure อัตโนมัติใน Grafana
- Internal URL: `http://loki:3100` (สำหรับ internal communication)

### Sample Dashboard
- **Logs Dashboard** - แสดง System logs และ Docker container logs
- สามารถเพิ่ม Dashboard เพิ่มเติมได้ในโฟลเดอร์ `dashboards/`

## 🔧 การ Configuration

### การแก้ไข Loki Config
แก้ไขไฟล์ `configs/loki-config.yml` สำหรับ:
- Storage retention policy
- Authentication settings  
- Performance tuning

### การแก้ไข Promtail Config
แก้ไขไฟล์ `configs/promtail-config.yml` สำหรับ:
- เพิ่ม log sources
- กำหนด labels และ parsing rules
- ตั้งค่า service discovery

### การเพิ่ม Dashboard
1. สร้างไฟล์ `.json` ในโฟลเดอร์ `dashboards/`
2. Restart Grafana service
   ```bash
   docker-compose restart grafana
   ```

## 📝 Log Sources ที่ Support

Promtail configuration รองรับ:
- ✅ System logs (`/var/log/*`)
- ✅ Docker container logs
- ✅ Nginx logs
- ✅ Apache logs  
- ✅ Systemd journal logs

## 🔒 Security

### Default Passwords
**⚠️ เปลี่ยน password default ก่อนใช้ production!**

แก้ไขใน `docker-compose.yml`:
```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=your_secure_password
```

### Network Security
- Services ทำงานใน isolated network `grafana-stack`
- เฉพาะ Grafana (port 3999) และ Loki (port 3998) ที่ expose ออกมา

## 🛠️ การ Troubleshooting

### ตรวจสอบ Logs
```bash
# ดู logs ทั้งหมด
docker-compose logs

# ดู logs service ใดๆ
docker-compose logs grafana
docker-compose logs loki
docker-compose logs promtail
```

### ปัญหาที่พบบ่อย

1. **Grafana ไม่เชื่อมต่อ Loki ได้**
   - ตรวจสอบว่า Loki service ทำงานปกติ
   - ตรวจสอบ network connectivity

2. **Promtail ไม่ส่ง logs มา**
   - ตรวจสอบ file permissions สำหรับ log files
   - ตรวจสอบ volume mounts

3. **Data หายหลัง restart**
   - ตรวจสอบ volume mappings
   - แน่ใจว่า directories มี permissions ถูกต้อง

## 📊 Performance Optimization

### สำหรับ Production
1. **เพิ่ม memory limits**:
   ```yaml
   deploy:
     resources:
       limits:
         memory: 1G
   ```

2. **ตั้งค่า log retention**:
   - แก้ไข `limits_config` ใน loki-config.yml

3. **Configure log rotation**:
   - ใช้ logrotate สำหรับ system logs

## 🔄 การ Backup และ Restore

### Backup
```bash
# Backup Grafana data
tar -czf grafana-backup-$(date +%Y%m%d).tar.gz data/grafana/

# Backup Loki data  
tar -czf loki-backup-$(date +%Y%m%d).tar.gz data/loki/
```

### Restore
```bash
# Stop services
docker-compose down

# Restore data
tar -xzf grafana-backup-YYYYMMDD.tar.gz
tar -xzf loki-backup-YYYYMMDD.tar.gz

# Start services
docker-compose up -d
```

## 📚 ข้อมูลเพิ่มเติม

- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Promtail Documentation](https://grafana.com/docs/loki/latest/clients/promtail/)
- [Portainer Documentation](https://documentation.portainer.io/)

## 🆘 การขอความช่วยเหลือ

หากพบปัญหาหรือต้องการความช่วยเหลือ:
1. ตรวจสอบ logs ด้วยคำสั่ง `docker-compose logs`
2. ตรวจสอบ network และ firewall settings
3. อ่าน documentation เพิ่มเติม

---

**จัดทำโดย**: Senior DevOps Engineer  
**เวอร์ชัน**: 1.0  
**อัปเดตล่าสุด**: $(date +%Y-%m-%d)
