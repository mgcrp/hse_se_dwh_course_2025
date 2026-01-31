#!/bin/bash

# Start PostgreSQL in the background
docker-entrypoint.sh postgres &

# Keep PostgreSQL running in the foreground
wait %1
