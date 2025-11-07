<script setup>
import { computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import KanbanBoard from 'dashboard/components-next/kanban/KanbanBoard.vue';

const store = useStore();
const router = useRouter();

const conversations = computed(() => store.getters['getAllConversations']);
const uiFlags = computed(() => store.getters['getUIFlags']);

const handleConversationClick = conversation => {
  router.push({
    name: 'inbox_conversation',
    params: { conversation_id: conversation.id },
  });
};

const loadConversations = async () => {
  try {
    // Load all conversations for the Kanban board
    await store.dispatch('fetchAllConversations');
  } catch (error) {
    console.error('Error loading conversations:', error);
  }
};

onMounted(() => {
  loadConversations();
});
</script>

<template>
  <div class="conversations-kanban-view h-full">
    <KanbanBoard
      board-type="conversation"
      :items="conversations"
      @item-click="handleConversationClick"
    />
  </div>
</template>

<style scoped>
.conversations-kanban-view {
  height: 100%;
  background: var(--n-slate-1);
}
</style>
