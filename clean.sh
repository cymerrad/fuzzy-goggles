# should be already using make
find . -type f ! \( -name 'package.json' -or -name 'input.json' \) ! -path './node_modules/*' -iname "*.json" -delete
find . -type f ! -path './node_modules/*' -iname "*.sol" -delete