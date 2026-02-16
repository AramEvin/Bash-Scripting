# 🛡️ DevOps & Security Linux Tools Portfolio

This repository contains a collection of **Bash scripts** for Linux system hardening, monitoring, and auditing. All scripts are **modular, production-ready, and designed with DevOps best practices** in mind.  

It demonstrates expertise in:

- Linux security (CIS compliance)  
- System monitoring and health checks  
- Performance analysis  
- Process and filesystem auditing  
- Logging and compliance automation  

---

## 📁 Scripts Overview

| Script Name | Description | CIS / DevOps Relevance |
|------------|-------------|----------------------|
| **CIS Hardening** | Full CIS Level 1 hardening framework for Ubuntu/RHEL systems | Security baseline, compliance, infrastructure hardening |
| **Failed SSH Login Detector** | Monitors and reports failed SSH login attempts in real-time | Security monitoring, intrusion detection |
| **Log Rotate** | Configures log rotation and permissions for system logs | Logging hygiene, compliance, disk management |
| **OS Hardening Audit** | Audits system configuration against CIS/industry best practices | Compliance auditing, DevOps validation |
| **Service Health Check** | Checks and reports status of critical services | System reliability, monitoring |
| **Disk Usage Monitor** | Monitors disk usage and alerts on thresholds | Capacity planning, alerting |
| **Filesystem Health Checker** | Detects corrupt or misconfigured filesystems | System integrity, proactive maintenance |
| **Memory Leak Indicator** | Monitors memory usage trends to detect leaks | Performance monitoring |
| **Process CPU Grapher** | Generates CPU usage graphs for processes | Performance analysis, capacity planning |
| **SUID-SGID File Scanner** | Scans for SUID/SGID files to detect potential privilege escalation | Security auditing, risk assessment |
| **Error Summary Generator** | Parses system logs and generates summarized error reports | Monitoring, troubleshooting |
| **Find Large Files** | Searches and reports large files on the system | Disk management, cleanup |
| **Network Interface Monitor** | Monitors network interface traffic and errors | Networking monitoring, troubleshooting |
| **System Health Check** | Comprehensive system status report (CPU, memory, disk, services) | Infrastructure overview, operational readiness |

---

## ⚡ Key Features Across Scripts

- **Modular and Reusable:** Each script can run independently or as part of a larger automation pipeline.  
- **Logging & Audit:** Scripts include robust logging mechanisms for troubleshooting and compliance.  
- **Cross-Distro Support:** Works on Ubuntu 22.04 LTS and RHEL 8/9 (where applicable).  
- **CIS Compliance Mapping:** Many scripts directly implement or audit CIS Level 1 controls.  
- **Safety Features:** Backup and dry-run options prevent accidental configuration loss.  
- **Cloud/VM Awareness:** Scripts avoid breaking essential cloud-init services.  

---

