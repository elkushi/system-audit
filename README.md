# Linux System Security Audit Tool

> Automated Linux server security auditing tool for penetration testers and system administrators.

---

## Overview

A Bash script that automatically audits a Linux server for security misconfigurations, vulnerabilities, and potential attack vectors. Built as part of a red teaming and penetration testing portfolio.

This tool simulates the manual enumeration phase of a penetration test — gathering system information, checking for privilege escalation vectors, analyzing open ports, and reviewing authentication logs.

---

## Features

- **System Information** — OS version, kernel, uptime, CPU, RAM, disk usage
- **User Security** — Users with shell access, sudo group members, empty passwords
- **SUID/SGID Files** — Finds files that could be used for privilege escalation
- **Network Analysis** — Open ports, active connections, network interfaces
- **Process Monitoring** — Running processes, root-owned processes
- **Cron Job Enumeration** — System and user scheduled tasks
- **File Permission Audit** — Checks sensitive files like `/etc/shadow`, `/etc/sudoers`
- **SSH Configuration Review** — Root login, password auth, key auth settings
- **Authentication Logs** — Failed login attempts, successful logins
- **Full Report Export** — Saves timestamped report to a `.txt` file

---

## Requirements

```
OS:   Linux (tested on Ubuntu, Kali Linux, CentOS)
Shell: Bash
Tools: ss, find, grep, awk, dig (usually pre-installed)
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/elkushi/security-tools.git
cd security-tools

# Make the script executable
chmod +x system_audit.sh
```

---

## Usage

```bash
# Run as current user
./system_audit.sh

# Run with sudo for full results (recommended)
sudo ./system_audit.sh
```

The script will:
1. Run all checks automatically
2. Display results with color-coded output
3. Save a full report to `audit_report_YYYYMMDD_HHMMSS.txt`

---

## Output Example

```
================================================
  LINUX SECURITY AUDIT REPORT
  Date: 2026-04-09 12:00:00
  Host: target-server
  User: moustafa
================================================

========================================
  USER SECURITY
========================================
--- Users with shell access ---
root
moustafa
www-data

[OK] No users with empty passwords

--- Sudo users ---
moustafa

========================================
  SUID/SGID FILES (Privilege Escalation Risk)
========================================
[WARN] SUID files found:
/usr/bin/sudo
/usr/bin/passwd
/usr/bin/mount

========================================
  NETWORK & OPEN PORTS
========================================
--- Open ports ---
tcp  0.0.0.0:22    LISTEN  sshd
tcp  0.0.0.0:80    LISTEN  nginx
tcp  0.0.0.0:443   LISTEN  nginx
tcp  0.0.0.0:5432  LISTEN  postgres

========================================
  SSH CONFIGURATION
========================================
[OK] Root login disabled
[OK] Password auth disabled

========================================
  RECENT AUTHENTICATION LOGS
========================================
--- Failed login attempts ---
Apr 09 10:12:33 sshd: Failed password for root from 192.168.1.100
Apr 09 10:12:35 sshd: Failed password for admin from 192.168.1.100
```

---

## Color Legend

| Color | Meaning |
|---|---|
| 🟢 Green `[OK]` | No issue found |
| 🟡 Yellow `[WARN]` | Potential risk — review recommended |
| 🔴 Red `[CRITICAL]` | Security issue found — immediate action needed |
| 🔵 Blue | Section header |

---

## Use Cases

**Penetration Testing:**
- Initial enumeration after gaining access to a Linux system
- Privilege escalation research
- Post-exploitation information gathering

**System Administration:**
- Regular security audits of production servers
- Compliance checking
- Hardening verification after configuration changes

---

## What I Learned Building This

- Linux file permissions and the security implications of SUID/SGID bits
- How attackers enumerate systems after initial access
- SSH hardening best practices
- Reading and parsing system log files
- Bash scripting — variables, functions, loops, color output, file I/O

---

## Skills Demonstrated

```
- Bash scripting
- Linux system administration
- Security auditing methodology
- Privilege escalation concepts
- SSH hardening knowledge
- Log analysis
- Network port enumeration
```

---

## Real World Application

This script was tested against a production Ubuntu server running Django, Nginx, and PostgreSQL. It identified:

- SUID binaries that could be potential escalation vectors
- Open ports beyond what was expected
- SSH configuration status
- Recent failed authentication attempts (brute force detection)

---

## Author

**Moustafa Elkushi**
DevOps Engineer & Penetration Tester

- LinkedIn: linkedin.com/in/moustafa-elkushi
- GitHub: github.com/elkushi
- TryHackMe: tryhackme.com/p/moustafa

---

## Disclaimer

This tool is for **authorized security testing only**. Only use on systems you own or have explicit written permission to test. Unauthorized use is illegal and unethical.

---

## License

MIT License — free to use, modify, and distribute with attribution.
