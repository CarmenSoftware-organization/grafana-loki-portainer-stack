# Sentry Initialization Guide

## Step 1: Initialize Sentry Database and User
```bash
# Initialize the database
docker-compose exec sentry sentry upgrade --noinput 

# Create superuser
docker-compose exec sentry sentry createuser --email admin@localhost --password admin123 --superuser --no-input
```

## Step 2: Getting Your Sentry DSN

The DSN is not visible in logs - you need to create it through the web interface:

### Access Sentry Web Interface
- Open your browser: **http://localhost:3997**
- Login with: `admin@localhost` / `admin123`

### Create a Project to Get DSN
1. Complete initial organization setup
2. Click **"Create Project"**
3. Select platform (Python, JavaScript, etc.)
4. Name your project
5. **Your DSN will be displayed** in format: `http://key@localhost:3997/1`

### Alternative: Get DSN via API
```bash
# Get organization ID
ORG_ID=$(docker-compose exec sentry sentry shell -c "from sentry.models import Organization; print(Organization.objects.first().id)")

# Create project and get DSN programmatically
docker-compose exec sentry sentry shell -c "
from sentry.models import Organization, Project, ProjectKey
org = Organization.objects.first()
project, created = Project.objects.get_or_create(
    name='default-project',
    organization=org,
    defaults={'platform': 'python'}
)
key = ProjectKey.objects.filter(project=project).first()
if key:
    print(f'DSN: http://{key.public_key}@localhost:3997/{project.id}')
else:
    print('No key found')
"
```

## Services Access
- **Sentry**: http://localhost:3997 (admin@localhost/admin123)
- **Grafana**: http://localhost:3999 (admin/admin123)  
- **Loki**: http://localhost:3998