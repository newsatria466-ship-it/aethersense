#!/bin/bash
# Script untuk menjalankan Smart City Tegal dalam ukuran layar HP di laptop
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
"$DIR/build/linux/x64/debug/bundle/smart_city_tegal" "$@"
