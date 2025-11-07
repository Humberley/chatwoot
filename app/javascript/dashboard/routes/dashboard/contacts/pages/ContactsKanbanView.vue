<script setup>
import { computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import KanbanBoard from 'dashboard/components-next/kanban/KanbanBoard.vue';

const store = useStore();
const router = useRouter();

const contacts = computed(() => store.getters['contacts/getContacts']);
const uiFlags = computed(() => store.getters['contacts/getUIFlags']);

const handleContactClick = contact => {
  router.push({
    name: 'contacts_dashboard',
    params: { contactId: contact.id },
  });
};

const loadContacts = async () => {
  try {
    // Load all contacts for the Kanban board
    // We'll load contacts without pagination for Kanban view
    await store.dispatch('contacts/get');
  } catch (error) {
    console.error('Error loading contacts:', error);
  }
};

onMounted(() => {
  loadContacts();
});
</script>

<template>
  <div class="contacts-kanban-view h-full">
    <KanbanBoard
      board-type="contact"
      :items="contacts"
      @item-click="handleContactClick"
    />
  </div>
</template>

<style scoped>
.contacts-kanban-view {
  height: 100%;
  background: var(--n-slate-1);
}
</style>
