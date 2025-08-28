# คู่มือติดตั้งบน Portainer

## 📋 วิธีการติดตั้งบน Portainer

### วิธีที่ 1: ใช้ Docker Compose (แนะนำ)

1. **เปิด Portainer Dashboard**
2. **ไปที่ Stacks → Add Stack**
3. **ใส่ชื่อ Stack: `grafana-stack`**
4. **เลือก "Upload" และอัปโหลดไฟล์ `docker-compose.yml`**
5. **หรือ Copy เนื้อหาไฟล์ `docker-compose.yml` ใส่ใน Web editor**
6. **กด "Deploy the stack"**

### วิธีที่ 2: ใช้ Git Repository

1. **ไปที่ Stacks → Add Stack**
2. **เลือก "Repository"**
3. **ใส่ URL ของ Git repository**
4. **ใส่ path ไปยัง `docker-compose.yml`**
5. **กด "Deploy the stack"**

## ⚠️ ข้อควรระวัง

### การจัดการ Configuration Files

เนื่องจาก Portainer ไม่สามารถ mount local files ได้โดยตรง จึงมี 2 วิธีแก้ไข:

#### วิธีที่ 1: ใช้ Configs (แนะนำ)
1. **สร้าง Configs ใน Portainer ก่อน deploy:**
   - `loki-config` → copy เนื้อหาจาก `configs/loki-config.yml`
   - `promtail-config` → copy เนื้อหาจาก `configs/promtail-config.yml`
   - `grafana-datasources` → copy เนื้อหาจาก `configs/grafana-datasources.yml`
   - `grafana-dashboards` → copy เนื้อหาจาก `configs/grafana-dashboards.yml`
   - `logs-dashboard` → copy เนื้อหาจาก `dashboards/logs-dashboard.json`

2. **ใช้ไฟล์ `portainer-stack.yml` แทน `docker-compose.yml`**

#### วิธีที่ 2: ใช้ Volumes และ Init Containers
แก้ไข docker-compose.yml ให้ใช้ named volumes แทน bind mounts

### การแก้ไข docker-compose.yml สำหรับ Portainer

```yaml
# เปลี่ยนจาก bind mounts
volumes:
  - ./configs/loki-config.yml:/etc/loki/local-config.yaml

# เป็น named volumes
volumes:
  - loki-config:/etc/loki/local-config.yaml
```

## 🔧 Configuration Steps สำหรับ Portainer

### 1. สร้าง Configs

ใน Portainer Dashboard:
1. **ไปที่ Configs → Add Config**
2. **สร้าง configs ต่อไปนี้:**

#### Loki Config
- **Name**: `loki-config`
- **Content**: Copy จาก `configs/loki-config.yml`

#### Promtail Config  
- **Name**: `promtail-config`
- **Content**: Copy จาก `configs/promtail-config.yml`

#### Grafana Datasources
- **Name**: `grafana-datasources`
- **Content**: Copy จาก `configs/grafana-datasources.yml`

#### Grafana Dashboards
- **Name**: `grafana-dashboards`  
- **Content**: Copy จาก `configs/grafana-dashboards.yml`

#### Logs Dashboard
- **Name**: `logs-dashboard`
- **Content**: Copy จาก `dashboards/logs-dashboard.json`

### 2. สร้าง Volumes

1. **ไปที่ Volumes → Add Volume**
2. **สร้าง volumes:**
   - `grafana-data`
   - `loki-data`

### 3. Deploy Stack

1. **ใช้ไฟล์ `portainer-stack.yml`**
2. **หรือแก้ไข `docker-compose.yml` ให้ใช้ named volumes**

## 🚀 ตัวอย่าง Docker Compose สำหรับ Portainer

```yaml
version: '3.8'

services:
  loki:
    image: grafana/loki:2.9.0
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - loki-data:/loki
    environment:
      - LOKI_CONFIG_INLINE=|
        auth_enabled: false
        server:
          http_listen_port: 3100
        common:
          path_prefix: /loki
          storage:
            filesystem:
              chunks_directory: /loki/chunks
              rules_directory: /loki/rules
          replication_factor: 1
          ring:
            instance_addr: 127.0.0.1
            kvstore:
              store: inmemory
        schema_config:
          configs:
            - from: 2020-10-24
              store: boltdb-shipper
              object_store: filesystem
              schema: v11
              index:
                prefix: index_
                period: 24h
    command: -config.expand-env=true -config.file=/etc/loki/local-config.yaml
    networks:
      - grafana-stack
    restart: unless-stopped

volumes:
  loki-data:
  grafana-data:

networks:
  grafana-stack:
    driver: bridge
```

## 📊 การเข้าถึงหลัง Deploy

- **Grafana**: `http://[portainer-host]:3999`
- **Loki**: `http://[portainer-host]:3998`

## 🔍 Troubleshooting

### ปัญหาที่พบบ่อย:

1. **Config files ไม่ถูก mount**
   - ตรวจสอบว่าสร้าง Configs ใน Portainer แล้ว
   - ตรวจสอบ syntax ของ configs

2. **Volumes permission denied**
   - ใช้ named volumes แทน bind mounts
   - ตรวจสอบ user permissions

3. **Network connectivity issues**
   - ตรวจสอบว่า services อยู่ใน network เดียวกัน
   - ใช้ service names สำหรับ internal communication

### การดู Logs ใน Portainer:

1. **ไปที่ Containers**
2. **คลิกที่ container ที่ต้องการ**
3. **ไปที่ tab "Logs"**

---

**หมายเหตุ**: คู่มือนี้เหมาะสำหรับ Portainer CE และ Portainer Business Edition
