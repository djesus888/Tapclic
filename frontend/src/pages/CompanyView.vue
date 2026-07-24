<template>
  <div class="company-page">
    <!-- Header con gradiente -->
    <div class="header-gradient">
      <div class="header">
        <div class="title-section">
          <h1>
            <span class="company-icon">🏢</span>
            {{ companyInfo.name || 'Nuestra Empresa' }}
          </h1>
          <p class="subtitle">Conoce al equipo que hace posible nuestros servicios</p>
        </div>
      </div>
    </div>

    <!-- Contenido principal -->
    <div class="company-container" v-if="!loading">
      <div class="company-content">
        <!-- Hero Section con misión y visión -->
        <div class="hero-section">
          <div class="hero-card">
            <div class="hero-text">
              <h2>✨ Nuestra Historia</h2>
              <p>{{ companyInfo.mission || 'Trabajamos para conectar profesionales con clientes que necesitan servicios de calidad, creando una comunidad confiable y eficiente.' }}</p>
            </div>
            <div class="hero-stats">
              <div class="stat">
                <span class="stat-number">{{ teamMembers.length }}</span>
                <span class="stat-label">Miembros del equipo</span>
              </div>
              <div class="stat">
                <span class="stat-number">{{ companyInfo.years || '5+' }}</span>
                <span class="stat-label">Años de experiencia</span>
              </div>
              <div class="stat">
                <span class="stat-number">{{ clientCount }}</span>
                <span class="stat-label">Clientes satisfechos</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Visión -->
        <div class="vision-section" v-if="companyInfo.vision">
          <div class="vision-card">
            <h2>🔮 Nuestra Visión</h2>
            <p>{{ companyInfo.vision }}</p>
          </div>
        </div>

        <!-- Timeline de la empresa -->
        <div class="timeline-section" v-if="milestones.length">
          <h2 class="section-title">📅 Nuestra Trayectoria</h2>
          <div class="timeline">
            <div v-for="(milestone, index) in milestones" :key="index" class="timeline-item">
              <div class="timeline-year">{{ milestone.year }}</div>
              <div class="timeline-content">
                <h4>{{ milestone.title }}</h4>
                <p>{{ milestone.description }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Grid de Directivos -->
        <div class="executives-section" v-if="teamMembers.length">
          <h2 class="section-title">
            <span class="title-icon">👔</span>
            Nuestro Equipo
          </h2>

          <div class="executives-grid">
            <div 
              v-for="member in teamMembers" 
              :key="member.id" 
              class="executive-card"
            >
              <div class="card-badge" :class="member.position">
                {{ getPositionLabel(member.position) }}
              </div>
              <div class="executive-avatar">
                <img
               :src="member.avatar ? getImageUrl(member.avatar, 'avatars') : 'https://via.placeholder.com/150?text=' + encodeURIComponent(member.name)"
               :alt="member.name"
               @error="handleImageError"
               >
              </div>
              <div class="executive-info">
                <h3>{{ member.name }}</h3>
                <p class="position">{{ getPositionLabel(member.position) }}</p>
                <p class="bio">{{ member.bio || 'Miembro del equipo' }}</p>
                <div class="social-links" v-if="member.social">
                  <a :href="member.social.linkedin" v-if="member.social.linkedin" target="_blank" title="LinkedIn">🔗</a>
                  <a :href="member.social.twitter" v-if="member.social.twitter" target="_blank" title="Twitter">🐦</a>
                  <a :href="'mailto:' + member.social.email" v-if="member.social.email" title="Email">📧</a>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Contacto -->
        <div class="contact-section" v-if="companyInfo.email || companyInfo.phone">
          <h2 class="section-title">📞 Contacto</h2>
          <div class="contact-info">
            <div class="contact-item" v-if="companyInfo.email">
              <span class="contact-icon">📧</span>
              <span>{{ companyInfo.email }}</span>
            </div>
            <div class="contact-item" v-if="companyInfo.phone">
              <span class="contact-icon">📱</span>
              <span>{{ companyInfo.phone }}</span>
            </div>
            <div class="contact-item" v-if="companyInfo.address">
              <span class="contact-icon">📍</span>
              <span>{{ companyInfo.address }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-else class="loading-container">
      <div class="spinner"></div>
      <p>Cargando información...</p>
    </div>
  </div>
</template>

<script setup>
import { getImageUrl } from '@/utils/imageHelper'
import { ref, onMounted } from 'vue'
import api from '@/axios'

const companyInfo = ref({})
const teamMembers = ref([])
const milestones = ref([])
const clientCount = ref(0)
const loading = ref(true)

onMounted(async () => {
  try {
    const response = await api.get('/company')
    if (response.data?.data) {
      companyInfo.value = response.data.data.company || {}
      teamMembers.value = response.data.data.team || []
      milestones.value = response.data.data.milestones || []
      clientCount.value = response.data.data.clients || 0
    }
  } catch (error) {
    console.error('Error cargando datos de la empresa:', error)
  } finally {
    loading.value = false
  }
})

function getPositionLabel(position) {
  const labels = {
    'founder': 'Fundador & CEO',
    'director': 'Director General',
    'subdirector': 'Subdirector',
    'team': 'Miembro del equipo'
  }
  return labels[position] || position || 'Miembro del equipo'
}

function handleImageError(event) {
  event.target.src = 'https://via.placeholder.com/150?text=Equipo'
}
</script>

<style scoped>
.company-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.header-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 60px 20px;
  text-align: center;
  color: white;
}

.header-gradient h1 {
  font-size: 2.5em;
  margin-bottom: 10px;
}

.subtitle {
  font-size: 1.2em;
  opacity: 0.9;
}

.company-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.hero-card {
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
  margin-bottom: 30px;
}

.hero-stats {
  display: flex;
  justify-content: space-around;
  margin-top: 30px;
  padding-top: 30px;
  border-top: 1px solid #eee;
}

.stat {
  text-align: center;
}

.stat-number {
  display: block;
  font-size: 2.5em;
  font-weight: bold;
  color: #667eea;
}

.stat-label {
  font-size: 0.9em;
  color: #666;
}

.vision-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 16px;
  padding: 40px;
  margin-bottom: 30px;
  text-align: center;
}

.section-title {
  text-align: center;
  font-size: 2em;
  margin-bottom: 30px;
  color: #333;
}

.timeline {
  position: relative;
  padding: 20px 0;
}

.timeline::before {
  content: '';
  position: absolute;
  left: 50%;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #667eea;
  transform: translateX(-50%);
}

.timeline-item {
  display: flex;
  justify-content: center;
  margin-bottom: 40px;
  position: relative;
}

.timeline-year {
  background: #667eea;
  color: white;
  padding: 10px 20px;
  border-radius: 20px;
  font-weight: bold;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  top: -15px;
  z-index: 1;
}

.timeline-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
  margin-top: 20px;
  max-width: 400px;
}

.executives-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
  margin-bottom: 40px;
}

.executive-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 5px 20px rgba(0,0,0,0.1);
  transition: transform 0.3s;
  text-align: center;
  position: relative;
}

.executive-card:hover {
  transform: translateY(-5px);
}

.card-badge {
  position: absolute;
  top: 15px;
  right: 15px;
  padding: 5px 15px;
  border-radius: 20px;
  font-size: 0.8em;
  font-weight: bold;
  color: white;
  z-index: 1;
}

.card-badge.founder { background: #f59e0b; }
.card-badge.director { background: #667eea; }
.card-badge.subdirector { background: #10b981; }
.card-badge.team { background: #6b7280; }

.executive-avatar {
  width: 120px;
  height: 120px;
  margin: 30px auto 15px;
  border-radius: 50%;
  overflow: hidden;
  border: 4px solid #667eea;
}

.executive-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.executive-info {
  padding: 0 20px 25px;
}

.executive-info h3 {
  font-size: 1.2em;
  margin-bottom: 5px;
}

.position {
  color: #667eea;
  font-weight: 600;
  margin-bottom: 10px;
}

.bio {
  color: #666;
  font-size: 0.9em;
  line-height: 1.5;
}

.social-links {
  margin-top: 15px;
  display: flex;
  justify-content: center;
  gap: 10px;
}

.social-links a {
  font-size: 1.2em;
  text-decoration: none;
}

.contact-section {
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 5px 20px rgba(0,0,0,0.1);
}

.contact-info {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 30px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.1em;
}

.contact-icon {
  font-size: 1.5em;
}

.loading-container {
  text-align: center;
  padding: 100px 20px;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 4px solid #e0e0e0;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
