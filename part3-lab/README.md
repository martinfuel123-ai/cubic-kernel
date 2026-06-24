# Part 3 — Black Hat Bash Lab

**Author:** Jose Martin  
**Tool:** Black Hat Bash Lab (Chapter 3)  
**Repo:** https://github.com/dolevf/Black-Hat-Bash

---

## 3.A — Lab Deployment

### Architecture

The lab consists of **8 containers** distributed across two isolated Docker networks.

| Container | Hostname | Public IP (172.16.10.0/24) | Corporate IP (10.1.0.0/24) | Role |
|-----------|----------|---------------------------|---------------------------|------|
| p-jumpbox-01 | p-jumpbox-01.acme-infinity-servers.com | 172.16.10.13 | 10.1.0.12 | Jumpbox / attacker entry point |
| p-web-01 | p-web-01.acme-infinity-servers.com | 172.16.10.10 | — | Flask web application (port 8081) |
| p-web-02 | p-web-02.acme-infinity-servers.com | 172.16.10.12 | 10.1.0.11 | WordPress (Apache + PHP, port 80) |
| p-ftp-01 | p-ftp-01.acme-infinity-servers.com | 172.16.10.11 | — | FTP server (vsFTPd, port 21) |
| c-backup-01 | c-backup-01.acme-infinity-servers.com | — | 10.1.0.13 | Backup server (Python HTTP, port 8080) |
| c-redis-01 | c-redis-01.acme-infinity-servers.com | — | 10.1.0.14 | Redis in-memory cache |
| c-db-01 | c-db-01.acme-infinity-servers.com | — | 10.1.0.15 | MySQL database |
| c-db-02 | c-db-02.acme-infinity-servers.com | — | 10.1.0.16 | MySQL database |

### Network Diagram

```
┌─────────────────────────────────────────────────────┐
│                  DOCKER HOST                          │
│                                                       │
│  ┌─────────────────────────┐  ┌───────────────────┐  │
│  │   Public Network        │  │ Corporate Network  │  │
│  │   172.16.10.0/24        │  │   10.1.0.0/24      │  │
│  │                         │  │                    │  │
│  │  p-web-01   .10         │  │  p-web-02    .11   │  │
│  │  p-web-02   .12         │  │  p-jumpbox-01 .12  │  │
│  │  p-ftp-01   .11         │  │  c-backup-01  .13  │  │
│  │  p-jumpbox-01 .13       │  │  c-redis-01   .14  │  │
│  └─────────────────────────┘  │  c-db-01     .15   │  │
│                                │  c-db-02     .16   │  │
│                                └────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Deployment Commands

```bash
git clone https://github.com/dolevf/Black-Hat-Bash.git
cd Black-Hat-Bash/lab

# Build base image
docker build -f machines/Dockerfile-base -t lab_base .

# Build and start all containers
docker compose build --parallel
docker compose up --detach
```

### Verification

```bash
# Check all 8 containers are running
docker ps --format "table {{.Names}}\t{{.Status}}"

# Expected output:
# p-web-02                     Up
# p-jumpbox-01                 Up
# p-web-01                     Up
# p-ftp-01                     Up
# c-backup-01                  Up
# c-redis-01                   Up
# c-db-02                      Up
# c-db-01                      Up
```

```bash
# Verify networks
docker network ls | grep -E "public|corporate"

# Expected:
# corporate    bridge    local
# public       bridge    local

docker network inspect public --format "{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}"
docker network inspect corporate --format "{{.Name}}: {{range .IPAM.Config}}{{.Subnet}}{{end}}"

# Expected:
# public: 172.16.10.0/24
# corporate: 10.1.0.0/24
```

```bash
# Access a container
docker exec -it p-web-01 bash
```

---

## 3.B — Hacking Technique: Advanced Vulnerability Scanning with Nuclei

### What is Nuclei?

[Nuclei](https://github.com/projectdiscovery/nuclei) is an open-source, template-based vulnerability scanner developed by ProjectDiscovery. It sends requests to targets based on YAML templates and matches responses against predefined patterns to detect security issues.

**Why it works:** Instead of manually testing each vulnerability, Nuclei automates the process by running thousands of pre-written templates (CVEs, misconfigurations, exposed panels, etc.) against the target. Each template defines:
- The HTTP/TCP request to send
- The expected (malicious) response pattern
- The severity level

### Execution

```bash
# Scan all public targets with Nuclei (critical, high, medium severity)
docker run --rm --network public \
  projectdiscovery/nuclei:latest \
  -list targets.txt \
  -severity critical,high,medium
```

### Results (19 findings)

#### CRITICAL: WordPress Installation Panel Exposed

```
[wp-install] [critical] http://172.16.10.12:80/wp-admin/install.php?step=1
```

**What it means:** The WordPress installation page (`wp-admin/install.php`) is publicly accessible on p-web-02. This page is normally disabled or redirected after the initial WordPress setup. An attacker accessing this page can:
- Reinstall WordPress from scratch, overwriting the existing installation
- Set a new admin username and password
- Gain full administrative access to the WordPress site
- Upload malicious themes/plugins to execute arbitrary code

**Evidence:** HTTP 200 OK response from `install.php` confirms the page is accessible:
```bash
$ curl -s -o /dev/null -w "%{http_code}" http://172.16.10.12:80/wp-admin/install.php
200
```

#### HIGH: Weak FTP Credentials

```
[ftp-weak-credentials] [high] 172.16.10.11:21
  ─ password="123456", username="ftp"
  ─ password="password", username="ftp"
  ─ password="guest", username="ftp"
  ─ password="toor", username="ftp"
  ─ password="default", username="ftp"
  ─ password="stingray", username="ftp"
  ─ password="nas", username="ftp"
  ─ password="pass1", username="ftp"
```

**What it means:** The FTP server on p-ftp-01 accepts common weak passwords for the `ftp` user. An attacker can brute-force or guess these credentials and gain access to the FTP server, potentially:
- Uploading malicious files (web shells, malware)
- Downloading sensitive data from the server
- Modifying existing files

#### MEDIUM: Anonymous FTP Login

```
[ftp-anonymous-login] [medium] 172.16.10.11:21
```

**What it means:** The FTP server allows anonymous logins (username `anonymous`, no password required). This confirms:
```bash
$ echo -e "USER anonymous\r\nPASS \r\nQUIT\r\n" | nc 172.16.10.11 21
220 (vsFTPd 3.0.5)
331 Please specify the password.
230 Login successful.
```

### Interpretation

The three findings together paint a concerning security picture for the ACME Infinity corporate network:

1. **Critical (WP install):** The web development team deployed WordPress but left the installation script accessible. A single HTTP request can reinitialize the CMS with attacker-controlled credentials, leading to a full website takeover and potential server compromise.

2. **High (FTP credentials):** The FTP server uses dictionary-attackable credentials (`123456`, `password`). Once the `ftp` user password is guessed, an attacker gains file read/write access on the server.

3. **Medium (Anonymous FTP):** Anonymous access is enabled unnecessarily — the public should not be able to connect without authentication.

### Remediation

| Finding | Fix |
|---------|-----|
| WP install page | Delete or restrict `wp-admin/install.php`; configure `.htaccess` |
| Weak FTP credentials | Enforce strong password policy (min 12 chars, complexity) |
| Anonymous FTP | Disable anonymous login in `vsftpd.conf` (`anonymous_enable=NO`) |

---

## Deliverables

| Item | Location |
|------|----------|
| Lab architecture diagram | Above (network diagram) |
| Container table | Above (architecture table) |
| `docker ps` output | `screenshots/docker_ps.txt` |
| Network verification | `screenshots/networks.txt` |
| `docker exec` access | Verified: `p-web-01` hostname is `p-web-01.acme-infinity-servers.com` |
| Nuclei scan results | `screenshots/nuclei_results.txt` |
| Attack technique | Nuclei — template-based vulnerability scanning (see section 3.B) |
