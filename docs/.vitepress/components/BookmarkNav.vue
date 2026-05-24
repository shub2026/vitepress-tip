<template>
  <div class="bookmark-nav">
    <div class="search-bar">
      <input
        v-model="keyword"
        type="text"
        placeholder="搜索书签..."
        class="search-input"
      />
    </div>
    <div v-for="group in filteredGroups" :key="group.title" class="nav-group">
      <h3 class="group-title">{{ group.title }}</h3>
      <div class="card-grid">
        <a
          v-for="item in group.items"
          :key="item.name"
          :href="item.url"
          target="_blank"
          rel="noopener noreferrer"
          class="nav-card"
        >
          <div class="card-icon">
            <img v-if="item.icon" :src="item.icon" :alt="item.name" @error="onIconError" />
            <span v-else class="icon-fallback">{{ item.name.charAt(0) }}</span>
          </div>
          <div class="card-info">
            <span class="card-name">{{ item.name }}</span>
            <span v-if="item.desc" class="card-desc">{{ item.desc }}</span>
          </div>
        </a>
      </div>
    </div>
    <div v-if="!filteredGroups.length" class="no-result">
      没有匹配的书签
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const keyword = ref('')

const onIconError = (e) => {
  e.target.style.display = 'none'
  const fallback = e.target.parentElement.querySelector('.icon-fallback')
  if (fallback) fallback.style.display = 'flex'
}

const props = defineProps({
  groups: { type: Array, required: true }
})

const filteredGroups = computed(() => {
  if (!keyword.value.trim()) return props.groups
  const kw = keyword.value.toLowerCase()
  return props.groups
    .map(group => ({
      ...group,
      items: group.items.filter(
        item =>
          item.name.toLowerCase().includes(kw) ||
          (item.desc && item.desc.toLowerCase().includes(kw))
      )
    }))
    .filter(group => group.items.length > 0)
})
</script>

<style scoped>
.bookmark-nav {
  max-width: 960px;
  margin: 0 auto;
}
.search-bar {
  margin-bottom: 2rem;
}
.search-input {
  width: 100%;
  padding: 0.75rem 1.25rem;
  font-size: 1rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  outline: none;
  transition: border-color 0.2s;
  box-sizing: border-box;
}
.search-input:focus {
  border-color: var(--vp-c-brand-1);
}
.nav-group {
  margin-bottom: 2.5rem;
}
.group-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
}
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 12px;
}
.nav-card {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  text-decoration: none;
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-soft);
  transition: all 0.2s;
}
.nav-card:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  transform: translateY(-1px);
}
.card-icon {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  border-radius: 6px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}
.card-icon img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}
.icon-fallback {
  width: 28px;
  height: 28px;
  display: none;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  background: var(--vp-c-brand-1);
  border-radius: 6px;
}
.card-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.card-name {
  font-size: 0.9rem;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.card-desc {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.no-result {
  text-align: center;
  padding: 3rem;
  color: var(--vp-c-text-3);
  font-size: 1rem;
}
@media (max-width: 640px) {
  .card-grid {
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  }
  .nav-card {
    padding: 8px 10px;
  }
}
</style>
