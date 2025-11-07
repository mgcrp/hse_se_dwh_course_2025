#Backup master
pg_basebackup -D /var/lib/postgresql/data-replica -S replication_slot_1 -X stream -P -U replicator -Fp -R
