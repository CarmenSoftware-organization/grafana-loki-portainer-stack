# 🔧 การแก้ไขปัญหา Portainer

## ❌ **Error ที่พบบ่อย:**

### 1. **Mount Error: "cannot create subdirectories"**

**ปัญหา:** Portainer ไม่สามารถ mount configuration files ได้

**สาเหตุ:** 
- Portainer ทำงานใน container environment
- ไม่สามารถเข้าถึง local files ได้โดยตรง
- Configuration files ถูก mount เป็น file แทนที่จะเป็น directory

**วิธีแก้ไข:**

#### **วิธีที่ 1: ใช้ไฟล์ `docker-compose-minimal.yml` (แนะนำที่สุด)**

ไฟล์นี้ใช้ basic configuration ที่เรียบง่ายที่สุด:

```bash
# ใช้ไฟล์นี้แทน docker-compose.yml
docker-compose -f docker-compose-minimal.yml up -d
```

#### **วิธีที่ 2: ใช้ไฟล์ `docker-compose-simple.yml`**

ไฟล์นี้ใช้ inline configuration แทนการ mount files:

```bash
# ใช้ไฟล์นี้แทน docker-compose.yml
docker-compose -f docker-compose-simple.yml up -d
```

#### **วิธีที่ 3: ใช้ Environment Variables**

แก้ไข docker-compose.yml ให้ใช้ environment variables:

```yaml
grafana:
  environment:
    - GF_DATASOURCES_DEFAULT_URL=http://loki:3100
    - GF_DATASOURCES_DEFAULT_TYPE=loki
    - GF_DATASOURCES_DEFAULT_ACCESS=proxy
    - GF_DATASOURCES_DEFAULT_ISDEFAULT=true
```

#### **วิธีที่ 4: ใช้ Named Volumes**

แทนที่ bind mounts ด้วย named volumes:

```yaml
volumes:
  - grafana-config:/etc/grafana/provisioning
  - loki-config:/etc/loki
  - promtail-config:/etc/promtail
```

### 2. **Command Line Error: "invalid command line string"**

**ปัญหา:** Promtail command line flags มี syntax ที่ซับซ้อนเกินไป

**วิธีแก้ไข:**
- ใช้ไฟล์ `docker-compose-minimal.yml` ที่มี basic configuration
- ลดความซับซ้อนของ command line flags
- ใช้ default configuration ของ images

### 3. **Permission Denied Errors**

**ปัญหา:** ไม่สามารถเขียนไฟล์หรือสร้าง directories ได้

**วิธีแก้ไข:**
```bash
# สร้าง directories และตั้ง permissions
mkdir -p data/grafana data/loki
sudo chown -R 472:472 data/grafana  # Grafana user
sudo chown -R 10001:10001 data/loki  # Loki user
```

### 4. **Network Connectivity Issues**

**ปัญหา:** Services ไม่สามารถเชื่อมต่อกันได้

**วิธีแก้ไข:**
- ตรวจสอบว่า services อยู่ใน network เดียวกัน
- ใช้ service names แทน localhost
- ตรวจสอบ firewall settings

## 🚀 **วิธี Deploy ที่แนะนำ:**

### **ขั้นตอนที่ 1: ใช้ไฟล์ Minimal (แนะนำที่สุด)**

1. **Copy เนื้อหาจาก `docker-compose-minimal.yml`**
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

### **ไฟล์ `docker-compose-minimal.yml`:**
- **Loki**: basic configuration, auth disabled
- **Promtail**: minimal log collection, system logs + Docker logs
- **Grafana**: basic setup, manual data source configuration

### **ไฟล์ `docker-compose-simple.yml`:**
- **Loki**: full configuration via command line flags
- **Promtail**: advanced log collection with multiple sources
- **Grafana**: auto-configure Loki data source

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

## 🔧 **การ Configure Grafana Data Source:**

หลังจาก deploy สำเร็จ:

1. **เข้าสู่ Grafana**: http://localhost:3999 (admin/admin123)
2. **ไปที่ Configuration → Data Sources**
3. **Add Data Source**
4. **เลือก Loki**
5. **URL**: `http://loki:3100`
6. **Save & Test**

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

1. **ใช้ไฟล์ `docker-compose-minimal.yml`** (แนะนำที่สุด)
2. **ตรวจสอบ Docker และ Portainer versions**
3. **ตรวจสอบ system resources (CPU, Memory, Disk)**
4. **Restart Portainer service**
5. **ตรวจสอบ Docker daemon logs**

## 📁 **ไฟล์ที่แนะนำ:**

| ไฟล์ | ความซับซ้อน | แนะนำสำหรับ |
|------|------------|------------|
| `docker-compose-minimal.yml` | ⭐ | **Portainer, การทดสอบ, Production** |
| `docker-compose-simple.yml` | ⭐⭐ | Development, Advanced users |
| `docker-compose.yml` | ⭐⭐⭐ | Local development, File-based config |

---

**หมายเหตุ:** ไฟล์ `docker-compose-minimal.yml` ออกแบบมาเพื่อแก้ไขปัญหาทั้งหมดใน Portainer โดยเฉพาะ และมีโอกาส deploy สำเร็จสูงสุด
