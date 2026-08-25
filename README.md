# Enterprise Infrastructure Automation & Monitoring System (EIAMS)

## 📌 Overview

**Enterprise Infrastructure Automation & Monitoring System (EIAMS)** is a Linux-based infrastructure management and monitoring project developed using **Bash scripting**.

The system provides a centralized command-line interface for monitoring system resources, managing services and processes, performing security checks, creating backups, monitoring applications and databases, checking network connectivity, generating alerts, and automating recurring infrastructure tasks.

The project is designed to demonstrate practical **Linux administration, Bash scripting, networking, system monitoring, automation, security, and Git/GitHub** skills.

---

## 🎯 Objectives

* Automate common Linux infrastructure administration tasks.
* Monitor CPU, memory, disk, network, and system resources.
* Manage Linux users, services, processes, and configurations.
* Perform basic infrastructure security checks.
* Automate system health reporting and backups.
* Monitor application and database services.
* Detect and manage infrastructure alerts.
* Monitor service dependencies.
* Provide a centralized infrastructure dashboard.
* Maintain project history using Git and GitHub.

---

## 🏗️ Architecture

```text
                         EIAMS
                           │
                           ▼
                    ┌─────────────┐
                    │   Main CLI  │
                    │  eiams.sh   │
                    └──────┬──────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
       ▼                   ▼                   ▼
  MANAGEMENT          MONITORING           SECURITY
       │                   │                   │
       ├─ Users            ├─ System          ├─ Firewall
       ├─ Services         ├─ Network         ├─ SSH
       ├─ Processes        ├─ Application     ├─ Login Attempts
       ├─ Configuration    ├─ Database        ├─ Open Ports
       └─ Automation       ├─ Dependencies    └─ File Permissions
                           ├─ Alerts
                           └─ Dashboard

       ┌─────────────────────────────────────────┐
       │              SUPPORT SYSTEMS             │
       ├─────────────────────────────────────────┤
       │ Backups │ Logs │ Cron │ Git/GitHub      │
       └─────────────────────────────────────────┘
```

---

## 🚀 Key Features

### 1. User Management

Provides basic Linux user-management operations through the EIAMS interface.

Features include:

* User listing
* User information
* User creation
* User management operations

---

### 2. Service Management

Provides centralized Linux service management.

Features include:

* List services
* Check service status
* Start services
* Stop services
* Restart services
* Enable/disable services

Uses `systemctl` for service operations.

---

### 3. System Monitoring

Monitors important system resources.

Monitored resources include:

* CPU usage
* CPU model and architecture
* Memory usage
* Swap usage
* Disk usage
* System uptime
* Logged-in users
* Top CPU-consuming processes
* Top memory-consuming processes

The module also provides an overall resource health status.

---

### 4. Security Monitoring

Performs basic Linux security checks.

Security checks include:

* Firewall status
* SSH configuration
* Failed login attempts
* Listening network endpoints
* `/etc/shadow` permissions

The system calculates a security score out of 100.

Example:

```text
Security Score: 60/100
Security Status: WARNING
```

The scoring system uses five security checks, each contributing 20 points when passed.

---

### 5. Infrastructure Health Report

Generates a consolidated infrastructure health report containing important system information and resource conditions.

The report can be executed manually or automatically through cron.

---

### 6. Log Management

Provides centralized log-management operations.

Features include:

* View logs
* Search logs
* Monitor log files
* Analyze log information
* Manage EIAMS-generated logs

---

### 7. Backup Management

Provides automated infrastructure backup capabilities.

Backup types include:

* System backup
* Configuration backup
* Backup statistics

Example backup:

```text
backups/
├── eiams_system_YYYYMMDD_HHMMSS.tar.gz
└── eiams_config_YYYYMMDD_HHMMSS.tar.gz
```

Backup sizes and available backup files can be inspected through the EIAMS interface.

---

### 8. System Information

Collects detailed system information including:

* Operating system
* Kernel
* Architecture
* CPU
* Memory
* Disk
* Mounted filesystems
* Network configuration
* DNS
* Routing
* Listening ports
* Users
* Login information
* Shell information

---

### 9. Automation Management

Provides infrastructure automation capabilities using Bash and Linux scheduling mechanisms.

The project uses **cron** to execute recurring infrastructure tasks.

Example:

```text
*/30 * * * * /mnt/d/AWSProject/EIAMS/modules/health_report.sh >> /mnt/d/AWSProject/EIAMS/logs/cron.log 2>&1
```

This executes the health-report script every 30 minutes and stores the output in the EIAMS log directory.

---

### 10. Configuration Management

Provides configuration-related operations for the EIAMS environment.

Configuration data is maintained separately from the application logic.

Example:

```text
config/
└── config.conf
```

---

### 11. Process Management

Provides process monitoring and management.

Features include:

* Process statistics
* Running process information
* Process searching
* Process identification

Example:

```text
Total Processes: 35
Running:         1
Sleeping:        32
Stopped:         0
Zombie:          0
```

---

### 12. Database Monitoring

Provides basic database-service monitoring and health checks.

The module is designed to identify database availability and service health within the infrastructure environment.

---

### 13. Application Monitoring

Provides application-level monitoring capabilities.

The module can inspect application processes and service availability and provide application health information through the EIAMS interface.

---

### 14. Network Monitoring

Provides network infrastructure monitoring.

Features include:

* Network interfaces
* IP addresses
* Default gateway
* DNS information
* Listening endpoints
* Connectivity testing
* Network summary

Example connectivity test:

```text
Testing connectivity to: google.com

Status: CONNECTIVITY OK
```

---

### 15. Alert & Incident Management

Provides basic infrastructure alert management.

Features include:

* View active alerts
* Generate system alerts
* View alert history
* Acknowledge alerts
* Clear resolved alerts
* Alert statistics

Example:

```text
Total Alerts:       1

By Status:
  Active:           0
  Acknowledged:     1
  Resolved:         0

By Severity:
  Critical:         0
  High:             1
  Medium:           0
  Low:              0
```

---

### 16. Service Dependency Monitoring

Checks relationships between important infrastructure services.

Example dependency checks:

```text
Docker Dependency
docker.service
        │
        ▼
containerd.service

Result: HEALTHY
```

The module provides:

* Healthy dependencies
* Warning dependencies
* Critical dependencies
* Overall dependency status

---

### 17. Centralized System Dashboard

The dashboard provides a consolidated view of the infrastructure state.

Example:

```text
==========================================
          EIAMS SYSTEM DASHBOARD
==========================================

SYSTEM
------------------------------------------
Hostname:          LAPTOP-3LTLFTKA
Uptime:            up 4 hours
CPU Usage:         1%
Memory Usage:      11%
Disk Usage:        1%

SERVICES
------------------------------------------
Running Services:  15
Failed Services:   0

NETWORK
------------------------------------------
Connectivity:      ONLINE
Listening Ports:   5

SECURITY
------------------------------------------
Security Score:    60/100 (WARNING)

DEPENDENCIES
------------------------------------------
Healthy:           3
Warning:           0
Critical:          0

ALERTS
------------------------------------------
Active:            0
Acknowledged:      1
```

The dashboard also calculates an overall infrastructure status based on resource, network, security, dependency, and alert conditions.

---

# 🛠️ Technology Stack

| Technology          | Purpose                                         |
| ------------------- | ----------------------------------------------- |
| Linux / Ubuntu      | Operating system and infrastructure environment |
| Bash                | Automation and system-management scripting      |
| systemd / systemctl | Service management                              |
| cron                | Task scheduling and automation                  |
| SSH                 | Remote administration concepts                  |
| UFW                 | Firewall monitoring                             |
| ss                  | Network and port monitoring                     |
| journalctl          | System and authentication log analysis          |
| tar                 | Backup creation                                 |
| Git                 | Version control                                 |
| GitHub              | Source-code hosting                             |
| Docker              | Container/service monitoring                    |

---

# 📁 Project Structure

```text
EIAMS/
│
├── backups/
│
├── config/
│   └── config.conf
│
├── logs/
│
├── modules/
│   ├── alert_management.sh
│   ├── application_monitoring.sh
│   ├── automation_management.sh
│   ├── backup_management.sh
│   ├── config_management.sh
│   ├── dashboard.sh
│   ├── database_monitoring.sh
│   ├── dependency_monitoring.sh
│   ├── health_report.sh
│   ├── log_management.sh
│   ├── network_monitoring.sh
│   ├── process_management.sh
│   ├── security_check.sh
│   ├── service_management.sh
│   ├── system_info.sh
│   ├── system_monitoring.sh
│   └── user_management.sh
│
├── scripts/
│   └── eiams.sh
│
├── .gitignore
└── README.md
```

---

# ⚙️ How to Run

## 1. Clone the repository

```bash
git clone <repository-url>
cd EIAMS
```

## 2. Verify permissions

```bash
find modules scripts -name "*.sh" -type f ! -executable -print
```

If necessary:

```bash
chmod +x scripts/eiams.sh
chmod +x modules/*.sh
```

## 3. Start EIAMS

```bash
./scripts/eiams.sh
```

The main menu provides access to all infrastructure modules.

---

# 🔄 Automation

EIAMS uses Linux cron for scheduled infrastructure operations.

Example:

```text
*/30 * * * * /mnt/d/AWSProject/EIAMS/modules/health_report.sh >> /mnt/d/AWSProject/EIAMS/logs/cron.log 2>&1
```

This demonstrates practical Linux task scheduling and automated infrastructure reporting.

---

# 💾 Backup Strategy

EIAMS creates compressed backup archives using `tar`.

Example:

```bash
tar -tzf backups/eiams_config_20260825_064446.tar.gz
```

Backups can be inspected and restored using standard Linux archive utilities.

---

# 🔐 Security Approach

The security module uses multiple independent checks:

```text
Firewall
   +
SSH Configuration
   +
Failed Login Attempts
   +
Listening Endpoints
   +
Sensitive File Permissions
   │
   ▼
Security Score /100
   │
   ├── 80–100 → GOOD
   ├── 60–79  → WARNING
   └── <60    → CRITICAL
```

This provides a simple rule-based infrastructure security assessment.

---

# 📊 Monitoring Approach

EIAMS follows a modular monitoring architecture.

```text
System
  │
  ├── CPU
  ├── Memory
  ├── Disk
  └── Processes

Network
  │
  ├── Interfaces
  ├── Gateway
  ├── DNS
  ├── Ports
  └── Connectivity

Services
  │
  ├── Service Status
  └── Dependencies

Applications
  │
  └── Application Health

Database
  │
  └── Database Health

Security
  │
  ├── Firewall
  ├── SSH
  ├── Login Attempts
  └── Permissions

        ↓

   Dashboard + Alerts
```

---

# 🔀 Git Workflow

Git is used to track infrastructure-project development.

The project follows a commit-based workflow:

```text
Development
     ↓
Testing
     ↓
git status
     ↓
git add
     ↓
git commit
     ↓
git push
     ↓
GitHub
```

The project was developed incrementally using separate commits for individual infrastructure features.

---

# 🧪 Validation

Before completing the project, Bash syntax validation was performed across the scripts:

```bash
for file in modules/*.sh scripts/*.sh; do
    bash -n "$file" || echo "ERROR: $file"
done
```

Executable permissions were also verified:

```bash
find modules scripts -name "*.sh" -type f ! -executable -print
```

The EIAMS main menu and its available modules were manually tested.

---

# ☁️ AWS / Cloud Relevance

Although EIAMS is primarily a **Linux and Bash infrastructure project**, the concepts are directly relevant to cloud environments.

The same infrastructure-management principles can be applied to an AWS Linux server.

For example:

```text
AWS EC2
   │
   ▼
Ubuntu / Amazon Linux
   │
   ▼
EIAMS
   │
   ├── System Monitoring
   ├── Network Monitoring
   ├── Service Monitoring
   ├── Security Checks
   ├── Backups
   ├── Logs
   └── Automation
```

Potential cloud integrations include:

* AWS EC2
* Amazon CloudWatch
* Amazon S3
* IAM
* VPC
* Load Balancers
* Automated backup storage

These are potential future integrations rather than components currently implemented by EIAMS.

---

# 🔮 Future Enhancements

Possible future improvements include:

* AWS CloudWatch integration
* S3 backup storage
* Email/Slack alert notifications
* Remote server monitoring through SSH
* Multi-server monitoring
* Web-based dashboard
* Centralized log aggregation
* Container monitoring
* Prometheus/Grafana integration
* Role-based access control
* Configuration-driven thresholds
* Automatic incident escalation

---

# 🎓 Skills Demonstrated

This project demonstrates practical knowledge of:

* Linux administration
* Bash scripting
* Shell commands
* Process management
* Service management
* systemd
* Networking
* DNS
* TCP/IP concepts
* Firewall concepts
* SSH
* Log management
* Cron scheduling
* Backup automation
* Security auditing
* Monitoring
* Alert management
* Git
* GitHub
* Docker concepts
* Infrastructure automation

---

# 👩‍💻 Author

**Monika**

B.Tech Computer Science Engineering

Project: **Enterprise Infrastructure Automation & Monitoring System (EIAMS)**

---

## 📌 Project Summary

**EIAMS is a modular Linux infrastructure automation and monitoring system built with Bash. It combines system monitoring, service management, networking, security auditing, backup automation, alert management, dependency monitoring, and centralized infrastructure reporting into a single command-line interface.**
