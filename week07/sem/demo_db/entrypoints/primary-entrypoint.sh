#!/bin/bash

# Start PostgreSQL in the background
docker-entrypoint.sh postgres &

# Wait for PostgreSQL to start up
while ! pg_isready -U postgres; do
  sleep 1
done

# Replication setup commands

# Check if replicator user already exists
# psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1 FROM pg_roles WHERE rolname='replicator'" | grep -q 1 || {
    # Create replicator user if it doesn't exist
#     psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'my_replicator_password';"
#     psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT * FROM pg_create_physical_replication_slot('replication_slot_secondary1');"
# }

# Check if the directory exists and is not empty
# if [ -d "/var/lib/postgresql/data-secondary" ] && [ "$(ls -A /var/lib/postgresql/data-secondary)" ]; then
#     echo "Directory /var/lib/postgresql/data-secondary is not empty. Clearing contents..."
#     rm -r /var/lib/postgresql/data-secondary/*
# fi


# create replicator user
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'my_replicator_password';
    SELECT * FROM pg_create_physical_replication_slot('replication_slot_secondary1');
EOSQL

## Backup primary
pg_basebackup -D /var/lib/postgresql/data-secondary -S replication_slot_secondary1 -X stream -P -U replicator -Fp -R

## initialize secondary
cp /etc/postgresql/initialization/configs/secondary-config/* /var/lib/postgresql/data-secondary
cp /etc/postgresql/initialization/configs/primary-config/pg_hba.conf /var/lib/postgresql/data

# Keep PostgreSQL running in the foreground
wait %1
