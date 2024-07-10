#!/bin/sh
echo -ne '\033c\033]0;Rd-config-test\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Rd-config-test.x86_64" "$@"
