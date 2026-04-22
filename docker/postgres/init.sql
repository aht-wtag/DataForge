SELECT 'CREATE DATABASE dataforge_test' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'dataforge_test')\gexec
GRANT ALL PRIVILEGES ON DATABASE dataforge_test TO dataforge;
