# 🔧 การแก้ไขปัญหา Portainer

## ❌ **Error ที่พบบ่อย:**

### 1. **Mount Error: "cannot create subdirectories"**

**ปัญหา:** Portainer ไม่สามารถ mount configuration files ได้

**สาเหตุ:** 
- Portainer ทำงานใน container environment
- ไม่สามารถเข้าถึง local files ได้โดยตรง
- Configuration files ถูก mount เป็น file แทนที่จะเป็น directory

**วิธีแก้ไข:**

#### **วิธีที่ 1: ใช้ไฟล์ `docker-compose-simple.yml` (แนะนำ)**

ไฟล์นี้ใช้ inline configuration แทนการ mount files:

```bash
# ใช้ไฟล์นี้แทน docker-compose.yml
docker-compose -f docker-compose-simple.yml up -d
```

#### **วิธีที่ 2: ใช้ Environment Variables**

แก้ไข docker-compose.yml ให้ใช้ environment variables:

```yaml
grafana:
  environment:
    - GF_DATASOURCES_DEFAULT_URL=http://loki:3100
    - GF_DATASOURCES_DEFAULT_TYPE=loki
    - GF_DATASOURCES_DEFAULT_ACCESS=proxy
    - GF_DATASOURCES_DEFAULT_ISDEFAULT=true
```

#### **วิธีที่ 3: ใช้ Named Volumes**

แทนที่ bind mounts ด้วย named volumes:

```yaml
volumes:
  - grafana-config:/etc/grafana/provisioning
  - loki-config:/etc/loki
  - promtail-config:/etc/promtail
```

### 2. **Permission Denied Errors**

**ปัญหา:** ไม่สามารถเขียนไฟล์หรือสร้าง directories ได้

**วิธีแก้ไข:**
```bash
# สร้าง directories และตั้ง permissions
mkdir -p data/grafana data/loki
sudo chown -R 472:472 data/grafana  # Grafana user
sudo chown -R 10001:10001 data/loki  # Loki user
```

### 3. **Network Connectivity Issues**

**ปัญหา:** Services ไม่สามารถเชื่อมต่อกันได้

**วิธีแก้ไข:**
- ตรวจสอบว่า services อยู่ใน network เดียวกัน
- ใช้ service names แทน localhost
- ตรวจสอบ firewall settings

## 🚀 **วิธี Deploy ที่แนะนำ:**

### **ขั้นตอนที่ 1: ใช้ไฟล์ Simple**

1. **Copy เนื้อหาจาก `docker-compose-simple.yml`**
2. **เปิด Portainer → Stacks → Add Stack**
3. **ใส่ชื่อ: `grafana-stack`**
4. **Paste เนื้อหาใน Web Editor**
5. **กด Deploy**

### **ขั้นตอนที่ 2: ตรวจสอบ Deployment**

```bash
# ดูสถานะ containers
docker ps

# ดู logs
docker logs grafana-stack_grafana_1
docker logs grafana-stack_loki_1
docker logs grafana-stack_promtail_1
```

### **ขั้นตอนที่ 3: ทดสอบการเชื่อมต่อ**

- **Grafana**: http://localhost:3999 (admin/admin123)
- **Loki**: http://localhost:3998

## 📋 **Configuration ที่ใช้:**

### **Loki Configuration:**
- ใช้ command line flags แทน config file
- Storage: filesystem
- Port: 3100 (internal), 3998 (external)

### **Promtail Configuration:**
- ใช้ command line flags แทน config file
- Collect logs จาก system, Docker, Nginx, Apache
- ส่ง logs ไปยัง Loki

### **Grafana Configuration:**
- Auto-configure Loki data source
- Port: 3000 (internal), 3999 (external)
- Admin: admin/admin123

## 🔍 **การ Debug:**

### **1. ตรวจสอบ Logs:**
```bash
# Grafana logs
docker logs grafana-stack_grafana_1

# Loki logs  
docker logs grafana-stack_loki_1

# Promtail logs
docker logs grafana-stack_promtail_1
```

### **2. ตรวจสอบ Network:**
```bash
# ดู networks
docker network ls

# ตรวจสอบ network details
docker network inspect grafana-stack
```

### **3. ตรวจสอบ Volumes:**
```bash
# ดู volumes
docker volume ls

# ตรวจสอบ volume details
docker volume inspect grafana-stack_loki-data
docker volume inspect grafana-stack_grafana-data
```

## ✅ **การตรวจสอบว่า Deploy สำเร็จ:**

1. **Containers ทำงานปกติ:**
   ```bash
   docker ps | grep grafana-stack
   ```

2. **Services ตอบสนอง:**
   - Grafana: http://localhost:3999
   - Loki: http://localhost:3998

3. **Logs ไม่มี error:**
   ```bash
   docker logs grafana-stack_grafana_1 | grep -i error
   docker logs grafana-stack_loki_1 | grep -i error
   ```

## 🆘 **หากยังมีปัญหา:**

1. **ใช้ไฟล์ `docker-compose-simple.yml`**
2. **ตรวจสอบ Docker และ Portainer versions**
3. **ตรวจสอบ system resources (CPU, Memory, Disk)**
4. **Restart Portainer service**
5. **ตรวจสอบ Docker daemon logs**

---

**หมายเหตุ:** ไฟล์ `docker-compose-simple.yml` ออกแบบมาเพื่อแก้ไขปัญหาการ mount files ใน Portainer โดยเฉพาะ
