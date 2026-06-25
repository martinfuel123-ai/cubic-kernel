# Black Hat Bash Lab - Part 3

---

## General Information

**Student:** Rafael Patin

**Tool:** Black Hat Bash Lab (Chapter 3)

**Repo:** https://github.com/dolevf/Black-Hat-Bash

---

## 3.A — Lab up and running

### 1. Pre-requisites and Core Environment Deployment
To initialize the virtualization layer, Docker and Docker Compose were installed and configured on the host system to ensure a reproducible laboratory environment. The deployment followed these standard operational steps:

# Update local repository indexes to ensure package compatibility
sudo apt-get update

# Install required Docker engine components and orchestration plugins
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Clone the official laboratory repository to the local workspace
git clone https://github.com/dolevf/Black-Hat-Bash.git
cd Black-Hat-Bash/lab

# Execute the automated deployment script to build the container stack
sudo make deploy

---

### 2. Infrastructure Validation
After deployment, the integrity of the 8-container stack was verified through native command-line auditing:

* Automated Lab Check: The command "sudo make test" was executed to validate the environment, returning the confirmation: "Lab is up."
* Container Inventory: The execution of "sudo docker ps --format "{{.Names}}"" confirmed the presence of exactly 8 containers (p-jumpbox-01, p-web-01, p-web-02, p-ftp-01, c-redis-01, c-backup-01, c-db-01, c-db-02), ensuring all services are isolated and running correctly.
* Network Segmentation Validation: The virtual bridges were audited using "ip addr" to ensure strict network isolation between segments:
    * Public Network (br_public): Bound to 172.16.10.1/24, hosting external-facing assets.
    * Corporate Network (br_corporate): Bound to 10.1.0.1/24, providing a restricted environment for data storage.

### 3. Interactive Access Demonstration
To verify operational control, interactive access to the production web instance was established:

### Accessing the web server container interactively
sudo docker exec -it p-web-01 bash

---

### 4. Architecture Table
| Machine / Service | Public Network (IP) | Corporate Network (IP) | Hostname | Role |
| :--- | :--- | :--- | :--- | :--- |
| **p-jumpbox-01** | 172.16.10.20 | 10.1.0.20 | `p-jumpbox-01` | Management Bastion |
| **p-web-01** | 172.16.10.11 | - | `p-web-01` | Apache Web Server |
| **p-web-02** | 172.16.10.11 | - | `p-web-02` | Nginx Web Server |
| **p-ftp-01** | 172.16.10.12 | - | `p-ftp-01` | Public FTP Server |
| **c-redis-01** | - | 10.1.0.10 | `c-redis-01` | In-Memory Cache |
| **c-backup-01** | - | 10.1.0.11 | `c-backup-01` | Persistence/Backup |
| **c-db-01** | - | 10.1.0.12 | `c-db-01` | Primary Database |
| **c-db-02** | - | 10.1.0.13 | `c-db-02` | Database Replica |

---

## 3.B — Hacking technique in the lab

### 1. Selected Technique: Directory and Path Enumeration
* **Objective:** Audit the public web interface (http://172.16.10.11) to discover hidden administrative resources, backup files, and sensitive backend configurations that are not explicitly linked in the main interface.
* **Tool Used:** dirsearch (v0.4.3).
* **Justification:** Directory enumeration is a fundamental reconnaissance technique. It allows an auditor to map the site structure and identify files often inadvertently left by developers during deployment, which can lead to information disclosure or full system compromise.

---

### 2. Execution and Methodology
After performing a manual header inspection to identify the server environment, an automated enumeration scan was performed against the target Apache/2.4.66 server.

# Perform directory brute-force attack on target web server
dirsearch -u http://172.16.10.11 -e php,html,txt,json

---

### 3. Technical Analysis of Findings
The audit yielded critical data regarding the server's security posture:

* Structural Leakage: The scanner identified multiple administrative files (e.g., .htaccess.bak1, .htpasswd_test) returning a 403 Forbidden status. While these are not directly accessible, their existence confirms the internal file system layout and naming conventions used on the server.
* Critical Security Vulnerability: The path /backup/ returned a 200 OK status. This indicates a high-severity security misconfiguration where internal backups are exposed to public anonymous users. This path is the primary vector for a full system compromise, as it potentially contains raw application source code, configuration files, and database exports.

---

### 4. Deliverables and Validation
* Lab Status: Infrastructure validated via "make test".
* Access Control: Interactive shell access verified and validated via "docker exec -it p-web-01 bash".
* Evidence: All command outputs and enumeration results are documented as part of the technical audit report.
