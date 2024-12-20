#!/usr/bin/env bash

read -r -d '' symbols << 'EOL'
— em dash
– en dash
… ellipsis
' apostrophe
' left quote
" right quote
" left quote
× multiply
÷ divide
° degree
± plus-minus
• bullet
· middle dot
† dagger
‡ double dagger
™ trademark
© copyright
€ euro
£ pound
EOL

selected=$(echo "$symbols" | fuzzel --dmenu)
[ -z "$selected" ] && exit 0
symbol=$(echo "$selected" | awk '{print $1}')
wtype "$symbol"
