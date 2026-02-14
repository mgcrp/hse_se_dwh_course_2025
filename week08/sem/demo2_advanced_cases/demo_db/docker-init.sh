echo "Clearing data"
rm -rf ./data/*
rm -rf ./data-secondary/*
docker-compose down

docker-compose up -d  postgres_primary

echo "Starting postgres_primary node..."
sleep 120  # Waits for primary node start complete

echo "Prepare replica config..."
docker exec -it postgres_primary sh /etc/postgresql/initialization/init.sh
echo "Restart primary node"
docker-compose restart postgres_primary
sleep 20

echo "Starting secondary node..."
docker-compose up -d  postgres_secondary
sleep 20  # Waits for node start complete

echo "Done"
