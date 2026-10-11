#!/bin/bash
set -euo pipefail

echo "Wachten tot todoappdb healthy is..."
for i in $(seq 1 30); do
    STATUS=$(docker inspect -f '{{.State.Health.Status}}' todoappdb 2>/dev/null || echo "starting")
    [ "$STATUS" = "healthy" ] && break
    sleep 2
done

docker exec -i todoappdb mariadb -utodo_usr -pletmeinplz todo_db << '_EOF_'
CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    is_done BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
_EOF_