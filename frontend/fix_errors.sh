#!/bin/bash

ARCHIVO="src/pages/admin/ContentManager.vue"
TEMP="${ARCHIVO}.temp"

# Restaurar desde backup si existe
if [ -f "${ARCHIVO}.backup" ]; then
    echo "🔄 Restaurando desde backup..."
    cp "${ARCHIVO}.backup" "$ARCHIVO"
fi

# Aplicar solo correcciones necesarias y seguras
echo "🔧 Aplicando correcciones seguras..."

# 1. Corregir línea 668 (asignación NO puede tener ?.)
sed -i '668s/loading?.value = true/loading.value = true/' "$ARCHIVO"

# 2. En template (solo lectura, está bien usar ?.)
sed -i '79s/{{ categories.length }}/{{ categories?.length }}/' "$ARCHIVO"
sed -i '322s/{{ faqs.length }}/{{ faqs?.length }}/' "$ARCHIVO"

# 3. En computed properties (solo lectura dentro de funciones)
sed -i '619s/c\.is_active/c?.is_active/' "$ARCHIVO"
sed -i '623s/cat\.service_count/cat?.service_count/' "$ARCHIVO"

# 4. En condiciones v-if (solo lectura)
sed -i 's/v-if="categories\.length === 0"/v-if="!categories?.length"/' "$ARCHIVO"
sed -i 's/v-if="faqs\.length === 0"/v-if="!faqs?.length"/' "$ARCHIVO"

# 5. NO usar ?. en asignaciones o llamadas a métodos
# Revertir cualquier ?. incorrecto en el lado izquierdo de asignaciones
sed -i 's/\([a-zA-Z_$][a-zA-Z0-9_$]*\)\?\.\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*=\s*/\1.\2 = /g' "$ARCHIVO"

echo "✅ Correcciones seguras aplicadas."
