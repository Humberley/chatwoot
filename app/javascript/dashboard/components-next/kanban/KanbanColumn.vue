<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Draggable from 'vuedraggable';
import Button from 'dashboard/components-next/button/Button.vue';
import DropdownMenu from 'dashboard/components-next/dropdown-menu/DropdownMenu.vue';
import DropdownItem from 'dashboard/components-next/dropdown-menu/base/DropdownItem.vue';

const props = defineProps({
  column: { type: Object, required: true },
  cards: { type: Array, default: () => [] },
  boardType: { type: String, required: true },
  isDragging: { type: Boolean, default: false },
});

const emit = defineEmits(['edit', 'delete', 'cardClick', 'cardMoved']);

const { t } = useI18n();

const localCards = computed({
  get: () => props.cards,
  set: value => {
    // This will be handled by the change event
  },
});

const columnStyle = computed(() => ({
  borderTopColor: props.column.color || '#4CAF50',
}));

const handleCardChange = event => {
  if (event.added) {
    const { element, newIndex } = event.added;
    emit('cardMoved', {
      card: element,
      toColumnId: props.column.id,
      position: newIndex,
    });
  }
};

const handleEditColumn = () => {
  emit('edit', props.column);
};

const handleDeleteColumn = () => {
  emit('delete', props.column);
};

const handleCardClick = card => {
  emit('cardClick', card);
};
</script>

<template>
  <div class="kanban-column flex flex-col w-80 flex-shrink-0 bg-n-slate-2 dark:bg-n-slate-2 rounded-lg border-t-4"
       :style="columnStyle">
    <!-- Column Header -->
    <div class="flex items-center justify-between p-4 border-b border-n-slate-6 dark:border-n-slate-6">
      <div class="flex items-center gap-2 flex-1 min-w-0">
        <h3 class="text-sm font-semibold text-n-slate-12 dark:text-n-slate-12 truncate">
          {{ column.name }}
        </h3>
        <span class="text-xs text-n-slate-11 dark:text-n-slate-11 flex-shrink-0">
          {{ cards.length }}
        </span>
      </div>

      <!-- Column Actions -->
      <DropdownMenu>
        <template #trigger>
          <Button
            variant="clear"
            size="small"
            icon="i-lucide-more-vertical"
            class="ml-2"
          />
        </template>
        <template #content>
          <DropdownItem
            icon="i-lucide-edit"
            @click="handleEditColumn"
          >
            {{ t('KANBAN.COLUMN.EDIT') }}
          </DropdownItem>
          <DropdownItem
            icon="i-lucide-trash"
            variant="danger"
            @click="handleDeleteColumn"
          >
            {{ t('KANBAN.COLUMN.DELETE') }}
          </DropdownItem>
        </template>
      </DropdownMenu>
    </div>

    <!-- Cards Container -->
    <div class="flex-1 p-3 overflow-y-auto min-h-[200px]">
      <Draggable
        v-model="localCards"
        :group="{ name: `kanban-${boardType}`, pull: true, put: true }"
        item-key="id"
        animation="200"
        ghost-class="kanban-card-ghost"
        drag-class="kanban-card-drag"
        class="flex flex-col gap-3 min-h-full"
        @change="handleCardChange"
      >
        <template #item="{ element }">
          <div
            class="kanban-card bg-white dark:bg-n-slate-1 rounded-lg p-3 shadow-sm border border-n-slate-6 dark:border-n-slate-6 cursor-pointer hover:shadow-md transition-shadow"
            @click="handleCardClick(element)"
          >
            <!-- Card Content for Contacts -->
            <div v-if="boardType === 'contact'" class="flex flex-col gap-2">
              <div class="flex items-start gap-2">
                <div class="w-8 h-8 rounded-full bg-n-slate-5 dark:bg-n-slate-5 flex items-center justify-center flex-shrink-0">
                  <i class="i-lucide-user text-sm text-n-slate-11 dark:text-n-slate-11" />
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-n-slate-12 dark:text-n-slate-12 truncate">
                    {{ element.name || 'Unnamed Contact' }}
                  </p>
                  <p v-if="element.email" class="text-xs text-n-slate-11 dark:text-n-slate-11 truncate">
                    {{ element.email }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Card Content for Conversations -->
            <div v-else class="flex flex-col gap-2">
              <div class="flex items-start gap-2">
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-n-slate-12 dark:text-n-slate-12 line-clamp-2">
                    {{ element.meta?.sender?.name || 'Unnamed Contact' }}
                  </p>
                  <p v-if="element.messages?.[0]" class="text-xs text-n-slate-11 dark:text-n-slate-11 line-clamp-1 mt-1">
                    {{ element.messages[0].content }}
                  </p>
                  <div class="flex items-center gap-2 mt-2">
                    <span :class="[
                      'text-xs px-2 py-0.5 rounded',
                      element.status === 'open' && 'bg-green-100 text-green-700',
                      element.status === 'pending' && 'bg-yellow-100 text-yellow-700',
                      element.status === 'resolved' && 'bg-blue-100 text-blue-700',
                    ]">
                      {{ element.status }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </Draggable>

      <!-- Empty State -->
      <div
        v-if="cards.length === 0"
        class="flex items-center justify-center h-full text-n-slate-11 dark:text-n-slate-11 text-sm"
      >
        {{ t('KANBAN.COLUMN.EMPTY') }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.kanban-card-ghost {
  @apply opacity-50 bg-n-slate-4 dark:bg-n-slate-4;
}

.kanban-card-drag {
  @apply shadow-xl rotate-2;
}

.kanban-column {
  max-height: calc(100vh - 200px);
}
</style>
