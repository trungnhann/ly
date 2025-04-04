# Student and Certificate Management System 🎓

## Overview 🎯
A comprehensive system for managing student information and certificates, enabling the administration of student data including personal information and related certificates/degrees.

## System Requirements 🛠
- Ruby 3.x
- PostgreSQL
- MongoDB (for metadata)
- Docker (optional)

## Installation & Setup 📥

### Standard Installation
```bash
# Clone repository
git clone <repository_url>
cd datn-cmt

# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate

# Run server
bin/dev
```

### Using Docker 🐳
```bash
# Build and run containers
docker-compose up --build
```

## Environment Configuration ⚙️
Create a `.env` file with the following environment variables:
```
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
RAILS_MAX_THREADS=5
```

## API Documentation 📚

### Authentication 🔐
```
POST /api/v1/login
POST /api/v1/signup
DELETE /api/v1/logout
```

### Students API 👨‍🎓

#### List Students
```
GET /api/v1/students
```
Params:
- code: Student ID
- full_name: Full Name
- id_card_number: ID Card Number
- email: Email
- created_at: Creation Date (format: "YYYY-MM-DD,YYYY-MM-DD")

#### Create Student
```
POST /api/v1/students
```
Body:
```json
{
  "student": {
    "code": "SV001",
    "full_name": "John Doe",
    "id_card_number": "123456789",
    "email": "example@email.com"
  }
}
```

#### Scan ID Card 📱
```
POST /api/v1/students/scan_id_card
```

### Certificates API 📜

#### List Certificates
```
GET /api/v1/certificates
```

#### Create Certificate
```
POST /api/v1/certificates
```
Body:
```json
{
  "certificate": {
    "code": "CERT001",
    "title": "English Certificate",
    "certificate_type": "certificate",
    "issue_date": "2024-03-22",
    "student_id": 1
  }
}
```

## Certificate Types 📋
- degree (1): Degree
- certificate (2): Certificate
- certification (3): Certification

## Metadata Management 🗄️
Both Student and Certificate entities can store additional metadata in MongoDB:

### Student Metadata
```
GET /api/v1/students/:id/metadata
POST /api/v1/students/:student_id/metadata
PUT /api/v1/students/:student_id/metadata
DELETE /api/v1/students/:student_id/metadata
```

### Certificate Metadata
```
GET /api/v1/certificates/:id/metadata
POST /api/v1/certificates/:certificate_id/metadata
PUT /api/v1/certificates/:certificate_id/metadata
DELETE /api/v1/certificates/:certificate_id/metadata
```

## License 📄
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
