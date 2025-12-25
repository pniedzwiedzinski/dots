#!/bin/bash

# Configuration file for storing API key (XDG compliant)
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="$XDG_CONFIG_HOME/openrouter"
CONFIG_FILE="$CONFIG_DIR/config"

# Function to store API key
store_api_key() {
    read -s -p "Enter your OpenRouter API key: " api_key
    echo
    mkdir -p "$CONFIG_DIR"
    echo "OPENROUTER_API_KEY=\"$api_key\"" > "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
    echo "API key stored successfully in $CONFIG_FILE"
}

# Function to load API key
load_api_key() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

# Check if API key exists, if not prompt to store it
load_api_key
if [[ -z "${OPENROUTER_API_KEY}" ]]; then
    echo "OpenRouter API key not found."
    read -p "Would you like to store your API key now? [y/N]: " store_key
    if [[ "$store_key" =~ ^[Yy]$ ]]; then
        store_api_key
        load_api_key
    else
        echo "Error: OpenRouter API key is required. Please run the script again to store your key."
        exit 1
    fi
fi

# Read the plain English command from the user
if [ -z "$1" ]; then
    echo "Please enter a command in plain English:"
    read -r plain_command
else
    plain_command="$*"
fi

# Define the prompt for the OpenRouter API
prompt="You are a helpful assistant that translates plain English requests into bash commands. Your task is to understand what the user wants to accomplish and provide the appropriate bash command(s) to achieve that goal.

Rules:
1. Return ONLY the bash command(s), nothing else - no markdown, no backticks, no code blocks, no explanations
2. Output should be plain text that can be executed directly
3. If multiple commands are needed, separate them with && or ;
4. If the request cannot be accomplished with bash commands, return: CANNOT_EXECUTE

Request: \"$plain_command\""

# Properly format the JSON payload for OpenRouter
json_payload=$(jq -n --arg prompt "$prompt" '{
    model: "google/gemma-3-12b-it:free",
    messages: [{"role": "user", "content": $prompt}],
    max_tokens: 60,
    temperature: 0.5
}')

# Call the OpenRouter API
response=$(curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "HTTP-Referer: shell-command-generator" \
    -H "X-Title: Shell Command Generator" \
    -d "$json_payload")

# Print the full response for debugging (uncomment if needed)
# echo "API Response: $response"

# Check if the response contains an error
if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
    error_message=$(echo "$response" | jq -r '.error.message')
    echo "API Error: $error_message"
    exit 1
fi

# Extract the command from the API response using jq
bash_command=$(echo "$response" | jq -r '.choices[0].message.content' | sed 's/^ *//;s/ *$//')

# Check if the bash_command is null, empty, or cannot be executed
if [ -z "$bash_command" ] || [ "$bash_command" == "null" ] || [ "$bash_command" == "CANNOT_EXECUTE" ]; then
    echo "Error: No valid bash command was generated or request cannot be executed."
    exit 1
fi

# Confirm the command with the user before executing
echo "Bash command generated: $bash_command"
read -p "Do you want to execute this command? [y/N]: " confirmation

if [[ "$confirmation" =~ ^[Yy]$ ]]; then
    $bash_command
else
    echo "Command execution aborted."
fi
