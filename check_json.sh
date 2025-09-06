#!/bin/bash
# Uso: ./check_json.sh <URL> <JSON_DATA>

URL="$1"
DATA="$2"
TMPFILE="response.json"

# Ejecuta curl y guarda la respuesta
curl -s -X POST "$URL" \
     -H "Content-Type: application/json" \
     -d "$DATA" -o "$TMPFILE"

# Muestra los primeros 20 bytes en octal/caracter para detectar caracteres extra
echo "=== Primeros bytes de la respuesta ==="
head -c 20 "$TMPFILE" | od -c

# Busca el primer { para ver dónde empieza el JSON
pos=$(grep -abo '{' "$TMPFILE" | head -n1 | cut -d: -f1)
if [ -z "$pos" ]; then
    echo "❌ No se encontró '{' en la respuesta, salida inválida"
    cat "$TMPFILE"
else
    echo "✅ JSON detectado desde el byte $pos"
    tail -c +"$((pos+1))" "$TMPFILE" | jq .
fi
