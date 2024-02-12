#!/bin/sh

escape_slashes() {
    local input="$1"
    local escaped_input=$(echo "$input" | sed 's/\//\\\//g')
    echo "$escaped_input"
}

port=$(printenv | grep "APP_PORT" | awk -F'=' '{print $2}')
sed -i "s/\$PORT/$port/g" "$1"

enable_backend_proxy=$(printenv | grep "RUNTIME_ENABLE_BACKEND_PROXY" | awk -F'=' '{print $2}')

if [ "$enable_backend_proxy" = true ]; then
  api=RUNTIME_API_URL
  proxy_backend=RUNTIME_PROXY_BACKEND

  api_env_var=$(printenv | grep "$api" | awk -F'=' '{print $2}')
  proxy_backend_var=$(printenv | grep "$proxy_backend" | awk -F'=' '{print $2}')

  escaped_api_env_var=$(escape_slashes "$api_env_var")
  sed -i "s/\$RUNTIME_API_URL/$escaped_api_env_var/g" "$1"
  escaped_proxy_backend_var=$(escape_slashes "$proxy_backend_var")
  sed -i "s/\$RUNTIME_PROXY_BACKEND/$escaped_proxy_backend_var/g" "$1"
else
  sed -i '/location $RUNTIME_API_URL {/,/}/d' text "$1"
fi

return 0