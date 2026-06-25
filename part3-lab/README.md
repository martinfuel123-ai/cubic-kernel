# Part 3: Black Hat Bash Lab

**Student:** Jose Martin  
**Tool:** Black Hat Bash Lab (Chapter 3)  
**Repo:** https://github.com/dolevf/Black-Hat-Bash

---

## Lab setup

I cloned the BHB repo and deployed the lab with Docker Compose. It has 8 containers on two networks:

**Public network (172.16.10.0/24):**
- p-jumpbox-01 (172.16.10.13) — entry point / attacker machine
- p-web-01 (172.16.10.10) — Flask web app on port 8081
- p-web-02 (172.16.10.12) — WordPress on port 80
- p-ftp-01 (172.16.10.11) — vsFTPd on port 21

**Corporate network (10.1.0.0/24):**
- p-jumpbox-01 (10.1.0.12) — also on corp network
- p-web-02 (10.1.0.11) — also on corp network
- c-backup-01 (10.1.0.13) — Python HTTP backup server (port 8080)
- c-redis-01 (10.1.0.14) — Redis cache
- c-db-01 (10.1.0.15) — MySQL database
- c-db-02 (10.1.0.16) — MySQL database

## Attack: Nuclei vulnerability scan

I used Nuclei (ProjectDiscovery) to scan the public targets. It runs automated templates against the target and flags vulnerabilities.

Ran this command:
```
docker run --rm --network public projectdiscovery/nuclei:latest \
  -u http://172.16.10.12 -tags wordpress,cve
```

**Results:**

- **CRITICAL** — WordPress install page exposed (wp-admin/install.php returns HTTP 200)
- INFO — WordPress readme.html accessible
- INFO — license.txt accessible

The critical finding means anyone can reinstall WordPress with their own credentials just by visiting that URL, effectively taking over the site.

I also checked the FTP server manually and confirmed weak passwords like "123456" and "password" work for the ftp user. Anonymous login is also enabled.

## Remediation

- Delete or block wp-admin/install.php with .htaccess
- Enforce strong passwords on FTP
- Disable anonymous FTP

## Screenshots and evidence

All in `screenshots/` folder: docker ps output, network verification, docker exec, Nuclei scan results.
