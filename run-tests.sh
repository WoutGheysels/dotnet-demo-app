#!/bin/bash
set -euo pipefail

DB_CONTAINER=$(docker ps -q -f name=^todoappdb$)
[ -n "$DB_CONTAINER" ] || { echo "Databasecontainer niet gevonden"; exit 1; }

docker exec -i "$DB_CONTAINER" mariadb -uroot -psekrit << '_EOF_'
CREATE DATABASE IF NOT EXISTS todo_test_db;
GRANT ALL PRIVILEGES ON todo_test_db.* TO 'todo_usr'@'%';
FLUSH PRIVILEGES;
_EOF_

docker exec -i "$DB_CONTAINER" mariadb -utodo_usr -pletmeinplz todo_test_db << '_EOF_'
CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    is_done BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
_EOF_

docker build -t dotnet-demo-tests -f Dockerfile.test .
docker run --rm --network container:"$DB_CONTAINER" dotnet-demo-tests dotnet test