#!/usr/bin/env zsh

echo "Setting up environment variables for GPU Marketplace"

# Function to prompt for a variable and set it
prompt_and_set() {
    local var_name=$1
    local var_description=$2
    local default_value=$3

    if [[ -n $default_value ]]; then
        read "?Enter $var_description [$default_value]: " value
        value=${value:-$default_value}
    else
        read "?Enter $var_description: " value
    fi

    export $var_name=$value
    echo "export $var_name=$value" >> ~/.zshrc
}

# Supabase configuration
prompt_and_set SUPABASE_URL "Supabase URL"
prompt_and_set SUPABASE_KEY "Supabase API Key"

# API Key for the application
prompt_and_set SECRET_KEY_BASE "Secret Key Base for the application" $(openssl rand -hex 64)

# HandCash configuration
prompt_and_set HANDCASH_APP_ID "HandCash App ID"
prompt_and_set HANDCASH_APP_SECRET "HandCash App Secret"

# Other configuration
prompt_and_set EXLA_TARGET "EXLA target (e.g., cuda, rocm, host)" "host"
prompt_and_set PORT "Port for the Phoenix server" "4000"

# Add this line
prompt_and_set SIGNING_SALT "Signing salt for session cookies" $(openssl rand -hex 32)

echo "Environment variables have been set and added to ~/.zshrc"
echo "Please restart your terminal or run 'source ~/.zshrc' to apply the changes"