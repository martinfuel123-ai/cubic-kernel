# Part 3: Black Hat Bash Lab

**Student:** Jose Martin  
**Tool:** Black Hat Bash Lab (Chapter 3)  
**Repo:** https://github.com/dolevf/Black-Hat-Bash

## Lab setup

Cloné el repo de Black Hat Bash y desplegué el laboratorio con Docker Compose. Tiene 8 contenedores en dos redes:

**Public network (172.16.10.0/24):** p-jumpbox-01 (172.16.10.13) como entry point, p-web-01 (172.16.10.10) con Flask en puerto 8081, p-web-02 (172.16.10.12) con WordPress en puerto 80, y p-ftp-01 (172.16.10.11) con vsFTPd en puerto 21.

**Corporate network (10.1.0.0/24):** p-jumpbox-01 (10.1.0.12), p-web-02 (10.1.0.11), c-backup-01 (10.1.0.13) servidor Python HTTP backup en puerto 8080, c-redis-01 (10.1.0.14) Redis, c-db-01 (10.1.0.15) MySQL, y c-db-02 (10.1.0.16) MySQL.

## Scan con Nuclei

Usé Nuclei de ProjectDiscovery para escanear los targets públicos. Busca vulnerabilidades usando templates automatizados.

Comando usado:

```
docker run --rm --network public projectdiscovery/nuclei:latest \
  -u http://172.16.10.12 -tags wordpress,cve
```

Resultados: encontró un CRITICAL (exposición del panel de instalación de WordPress en wp-admin/install.php) y algunos INFO (readme.html, license.txt accesibles).

## Screenshots

Las capturas están en la carpeta screenshots/ e incluyen docker ps, las redes, docker exec a un contenedor, y el resultado del scan de Nuclei.
