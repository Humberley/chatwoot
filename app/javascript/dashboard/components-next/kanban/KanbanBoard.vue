<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import KanbanColumn from './KanbanColumn.vue';
import ColumnManager from './ColumnManager.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  boardType: { type: String, required: true }, // 'contact' or 'conversation'
  items: { type: Array, default: () => [] }, // All contacts or conversations
});

const emit = defineEmits(['itemClick']);

const store = useStore();
const { t } = useI18n();
const alert = useAlert();

const showColumnManager = ref(false);
const columnManagerMode = ref('create');
const editingColumn = ref(null);
const isDragging = ref(false);

const columns = computed(() =>
  store.getters['kanban/getColumnsByBoardType'](props.boardType)
);

const uiFlags = computed(() => store.getters['kanban/getUIFlags']);

const getCardsByColumn = columnId => {
  return props.items.filter(
    item =>
      item.custom_attributes?.kanban_column_id === columnId.toString()
  );
};

const loadColumns = async () => {
  try {
    await store.dispatch('kanban/getColumns', props.boardType);
  } catch (error) {
    alert.error(t('KANBAN.ERRORS.FETCH_FAILED'));
  }
};

const handleAddColumn = () => {
  columnManagerMode.value = 'create';
  editingColumn.value = null;
  showColumnManager.value = true;
};

const handleEditColumn = column => {
  columnManagerMode.value = 'edit';
  editingColumn.value = column;
  showColumnManager.value = true;
};

const handleDeleteColumn = async column => {
  if (
    !confirm(
      t('KANBAN.COLUMN.DELETE_CONFIRMATION')
    )
  )
    return;

  try {
    await store.dispatch('kanban/deleteColumn', {
      boardType: props.boardType,
      columnId: column.id,
    });
    alert.success(t('KANBAN.SUCCESS.COLUMN_DELETED'));
  } catch (error) {
    alert.error(t('KANBAN.ERRORS.DELETE_FAILED'));
  }
};

const handleSaveColumn = async columnData => {
  try {
    if (columnManagerMode.value === 'edit') {
      await store.dispatch('kanban/updateColumn', {
        boardType: props.boardType,
        columnId: editingColumn.value.id,
        columnData: {
          ...columnData,
          board_type: props.boardType,
        },
      });
      alert.success(t('KANBAN.SUCCESS.COLUMN_UPDATED'));
    } else {
      await store.dispatch('kanban/createColumn', {
        boardType: props.boardType,
        columnData: {
          ...columnData,
          board_type: props.boardType,
        },
      });
      alert.success(t('KANBAN.SUCCESS.COLUMN_CREATED'));
    }
    showColumnManager.value = false;
  } catch (error) {
    alert.error(
      columnManagerMode.value === 'edit'
        ? t('KANBAN.ERRORS.UPDATE_FAILED')
        : t('KANBAN.ERRORS.CREATE_FAILED')
    );
  }
};

const handleCardMoved = async ({ card, toColumnId, position }) => {
  try {
    await store.dispatch('kanban/moveCard', {
      boardType: props.boardType,
      cardId: card.id,
      columnId: toColumnId,
      position,
    });
    alert.success(t('KANBAN.SUCCESS.CARD_MOVED'));
  } catch (error) {
    alert.error(t('KANBAN.ERRORS.MOVE_FAILED'));
  }
};

const handleCardClick = card => {
  emit('itemClick', card);
};

onMounted(() => {
  loadColumns();
});
</script>

<template>
  <div class="kanban-board-container flex flex-col h-full">
    <!-- Board Header -->
    <div class="flex items-center justify-between p-4 border-b border-n-slate-6 dark:border-n-slate-6">
      <h2 class="text-lg font-semibold text-n-slate-12 dark:text-n-slate-12">
        {{
          boardType === 'contact'
            ? t('KANBAN.CONTACTS_TITLE')
            : t('KANBAN.CONVERSATIONS_TITLE')
        }}
      </h2>
      <Button
        :disabled="uiFlags.isCreating"
        @click="handleAddColumn"
      >
        <i class="i-lucide-plus mr-2" />
        {{ t('KANBAN.HEADER.ADD_COLUMN') }}
      </Button>
    </div>

    <!-- Loading State -->
    <div
      v-if="uiFlags.isFetching"
      class="flex items-center justify-center flex-1 p-8"
    >
      <div class="text-n-slate-11 dark:text-n-slate-11">
        <i class="i-lucide-loader-2 animate-spin mr-2" />
        Loading...
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-else-if="columns.length === 0"
      class="flex flex-col items-center justify-center flex-1 p-8"
    >
      <i class="i-lucide-kanban text-6xl text-n-slate-11 dark:text-n-slate-11 mb-4" />
      <h3 class="text-lg font-semibold text-n-slate-12 dark:text-n-slate-12 mb-2">
        {{ t('KANBAN.EMPTY_STATE.TITLE') }}
      </h3>
      <p class="text-sm text-n-slate-11 dark:text-n-slate-11 mb-4">
        {{ t('KANBAN.EMPTY_STATE.SUBTITLE') }}
      </p>
      <Button @click="handleAddColumn">
        <i class="i-lucide-plus mr-2" />
        {{ t('KANBAN.EMPTY_STATE.CREATE_BUTTON') }}
      </Button>
    </div>

    <!-- Kanban Board -->
    <div
      v-else
      class="flex-1 overflow-x-auto overflow-y-hidden"
    >
      <div class="flex gap-4 p-6 h-full">
        <KanbanColumn
          v-for="column in columns"
          :key="column.id"
          :column="column"
          :cards="getCardsByColumn(column.id)"
          :board-type="boardType"
          :is-dragging="isDragging"
          @edit="handleEditColumn"
          @delete="handleDeleteColumn"
          @card-click="handleCardClick"
          @card-moved="handleCardMoved"
        />
      </div>
    </div>

    <!-- Column Manager Modal -->
    <ColumnManager
      :show="showColumnManager"
      :mode="columnManagerMode"
      :column="editingColumn"
      @close="showColumnManager = false"
      @save="handleSaveColumn"
    />
  </div>
</template>

<style scoped>
.kanban-board-container {
  height: calc(100vh - 64px);
}
</style>
