# Base de Datos - TapClic

## Archivos
- tapclic_schema.sql - Estructura completa
- seed_data.sql - Datos iniciales

## Instalacion

### 1. Crear base de datos
mariadb -u root -p -e "CREATE DATABASE IF NOT EXISTS tapclic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

### 2. Importar estructura
mariadb -u root -p tapclic_db < database/tapclic_schema.sql

### 3. Importar datos iniciales
mariadb -u root -p tapclic_db < database/seed_data.sql

### 4. Verificar
mariadb -u root -p -e "USE tapclic_db; SHOW TABLES;"
