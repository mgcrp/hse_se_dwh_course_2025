#!/bin/bash
set -e

# create replicator user
psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'my_replicator_password';
    SELECT * FROM pg_create_physical_replication_slot('replication_slot_secondary1');
EOSQL

# Backup primary
pg_basebackup -D /var/lib/postgresql/data-secondary -S replication_slot_secondary1 -X stream -P -U replicator -Fp -R

# initialize secondary
cp /etc/postgresql/initialization/configs/secondary-config/* /var/lib/postgresql/data-secondary
cp /etc/postgresql/initialization/configs/primary-config/pg_hba.conf /var/lib/postgresql/data