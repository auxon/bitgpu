#!/bin/bash

echo "Setting up local Supabase instance for GPU Marketplace"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

# Create a directory for Supabase
mkdir -p ./supabase && cd ./supabase

# Download the docker-compose.yml file
curl -o docker-compose.yml https://raw.githubusercontent.com/supabase/supabase/master/docker/docker-compose.yml

# Start Supabase
docker-compose up -d

echo "Waiting for Supabase to start..."
sleep 30

# Create the training_data table
docker-compose exec db psql -U postgres -c "
CREATE TABLE training_data (
    id SERIAL PRIMARY KEY,
    features FLOAT[] NOT NULL,
    label FLOAT NOT NULL
);"

# Create indexes for better performance
docker-compose exec db psql -U postgres -c "
CREATE INDEX idx_training_data_id ON training_data (id);
CREATE INDEX idx_training_data_label ON training_data (label);"

# Create the model_params table
docker-compose exec db psql -U postgres -c "
CREATE TABLE model_params (
    id SERIAL PRIMARY KEY,
    layer VARCHAR(255) NOT NULL,
    params FLOAT[] NOT NULL
);"

echo "Local Supabase instance is set up and configured for GPU Marketplace"
echo "Supabase Studio URL: http://localhost:3000"
echo "API URL: http://localhost:8000"
echo "Database URL: postgresql://postgres:postgres@localhost:5432/postgres"
echo "Default email: admin@admin.com"
echo "Default password: admin"

# Generate a random API key
API_KEY=$(openssl rand -hex 32)
echo "Generated API key: $API_KEY"
echo "Please add this API key to your .env file or use it in your setup_env.zsh script"

cd ..