#!/bin/sh

api=RUNTIME_API_URL
js_prefix=RUNTIME_JS_VAR_

api_env_var=$(printenv | grep "$api")
js_env_vars=$(printenv | grep "^$js_prefix")

echo "window._env_ = {" > "$1"
echo "$api_env_var" | awk -F '=' '{printf "  %s: \"%s\",\n", $1, $2}' >> "$1"
if [ ! -z "$js_env_vars" ]; then
echo "$js_env_vars" | awk -F '=' '{printf "  %s: \"%s\",\n", $1, $2}' >> "$1"
fi
echo "}" >> "$1"

return 0