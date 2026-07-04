<template>
  <div class="staff-container">
    <div class="staff-header">
      <h1>👥 Mi Personal</h1>
      <button class="btn-add" @click="showForm = true">+ Agregar personal</button>
    </div>

    <!-- Formulario para agregar -->
    <div v-if="showForm" class="staff-form">
      <h3>{{ editing ? 'Editar' : 'Nuevo' }} personal</h3>
      <input v-model="form.name" placeholder="Nombre completo" class="input" />
      <input v-model="form.email" placeholder="Email (opcional)" class="input" />
      <input v-model="form.phone" placeholder="Teléfono" class="input" />
      <input v-model="form.password" type="password" placeholder="Contraseña" class="input" />
      <select v-model="form.role" class="input">
        <option value="delivery">🛵 Delivery</option>
        <option value="staff">👤 Staff</option>
      </select>
      <div class="form-actions">
        <button class="btn-save" @click="saveStaff">Guardar</button>
        <button class="btn-cancel" @click="resetForm">Cancelar</button>
      </div>
    </div>

    <!-- Lista de staff -->
    <div v-if="staff.length" class="staff-list">
      <div v-for="s in staff" :key="s.id" class="staff-card">
        <div class="staff-info">
          <strong>{{ s.name }}</strong>
          <span class="role-badge">{{ s.role }}</span>
          <p>{{ s.email || 'Sin email' }} | {{ s.phone || 'Sin teléfono' }}</p>
        </div>
        <div class="staff-actions">
          <button @click="editStaff(s)">✏️</button>
          <button @click="deleteStaff(s.id)">🗑️</button>
        </div>
      </div>
    </div>
    <p v-else>No tienes personal registrado.</p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/axios'
import { useAuthStore } from '@/stores/authStore'

const authStore = useAuthStore()
const staff = ref([])
const showForm = ref(false)
const editing = ref(null)

const form = ref({
  name: '', email: '', phone: '', password: '', role: 'delivery'
})

const fetchStaff = async () => {
  const { data } = await api.get('/provider/staff', {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  staff.value = data.staff || []
}

const saveStaff = async () => {
  const url = editing.value ? '/provider/staff/update' : '/provider/staff/create'
  const payload = editing.value ? { id: editing.value.id, ...form.value } : form.value
  await api.post(url, payload, {
    headers: { Authorization: `Bearer ${authStore.token}` }
  })
  resetForm()
  fetchStaff()
}

const editStaff = (s) => {
  editing.value = s
  form.value = { name: s.name, email: s.email, phone: s.phone, password: '', role: s.role }
  showForm.value = true
}

const deleteStaff = async (id) => {
  if (confirm('¿Eliminar este personal?')) {
    await api.post('/provider/staff/delete', { id }, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    fetchStaff()
  }
}

const resetForm = () => {
  showForm.value = false
  editing.value = null
  form.value = { name: '', email: '', phone: '', password: '', role: 'delivery' }
}

onMounted(fetchStaff)
</script>

<style scoped>
.staff-container { padding: 20px; max-width: 600px; margin: auto; }
.staff-header { display: flex; justify-content: space-between; align-items: center; }
.btn-add { background: #667eea; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
.staff-form { background: #f5f5f5; padding: 20px; border-radius: 12px; margin: 20px 0; display: flex; flex-direction: column; gap: 10px; }
.input { padding: 10px; border: 1px solid #ddd; border-radius: 6px; }
.form-actions { display: flex; gap: 10px; }
.btn-save { background: #4caf50; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
.btn-cancel { background: #999; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
.staff-card { display: flex; justify-content: space-between; align-items: center; padding: 15px; background: white; border-radius: 8px; margin: 10px 0; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.role-badge { background: #667eea; color: white; padding: 3px 10px; border-radius: 20px; font-size: 0.8rem; margin-left: 10px; }
.staff-actions button { background: none; border: none; font-size: 1.2rem; cursor: pointer; margin: 0 5px; }
</style>
