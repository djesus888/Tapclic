<template>
  <div class="company-page">
    <!-- Header con gradiente -->
    <div class="header-gradient">
      <div class="header">
        <div class="title-section">
          <h1>
            <span class="company-icon">🏢</span>
            Nuestra Empresa
          </h1>
          <p class="subtitle">Conoce al equipo que hace posible nuestros servicios</p>
        </div>
      </div>
    </div>

    <!-- Contenido principal -->
    <div class="company-container">
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
        <div class="executives-section">
          <h2 class="section-title">
            <span class="title-icon">👔</span>
            Nuestros Directivos
          </h2>
         
          <div class="executives-grid">
            <!-- Fundador -->
            <div class="executive-card" v-if="getMemberByPosition('founder')">
              <div class="card-badge founder">Fundador</div>
              <div class="executive-avatar">
                <img
                  :src="getMemberByPosition('founder').avatar || 'https://via.placeholder.com/150?text=Fundador'"
                  :alt="getMemberByPosition('founder').name"
                  @error="handleImageError"
                >
                <div class="avatar-overlay">
                  <span class="avatar-icon">⭐</span>
                </div>
              </div>
              <div class="executive-info">
                <h3>{{ getMemberByPosition('founder').name }}</h3>
                <p class="position">Fundador & CEO</p>
                <p class="bio">{{ getMemberByPosition('founder').bio || 'Visionario y líder de la empresa' }}</p>
                <div class="social-links" v-if="getMemberByPosition('founder').social">
                  <a :href="getMemberByPosition('founder').social.linkedin" v-if="getMemberByPosition('founder').social.linkedin" target="_blank">🔗 LinkedIn</a>
                  <a :href="getMemberByPosition('founder').social.twitter" v-if="getMemberByPosition('founder').social.twitter" target="_blank">🐦 Twitter</a>
                  <a :href="getMemberByPosition('founder').social.email" v-if="getMemberByPosition('founder').social.email">📧 Email</a>
                </div>
              </div>
            </div>

            <!-- Director -->
            <div class="executive-card" v-if="getMemberByPosition('director')">
              <div class="card-badge director">Director</div>
              <div class="executive-avatar">
                <img
                  :src="getMemberByPosition('director').avatar || 'https://via.placeholder.com/150?text=Director'"
                  :alt="getMemberByPosition('director').name"
                  @error="handleImageError"
                >
              </div>
              <div class="executive-info">
                <h3>{{ getMemberByPosition('director').name }}</h3>
                <p class="position">Director General</p>
                <p class="bio">{{ getMemberByPosition('director').bio || 'Liderando la estrategia y operaciones' }}</p>
              </div>
            </div>

            <!-- Subdirector -->
            <div class="executive-card" v-if="getMemberByPosition('subdirector')">
              <div class="card-badge subdirector">Subdirector</div>
              <div class="executive-avatar">
