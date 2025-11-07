<script setup>
import { ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import Modal from 'dashboard/components/Modal.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  show: { type: Boolean, default: false },
  column: { type: Object, default: null },
  mode: { type: String, default: 'create' }, // 'create' or 'edit'
});

const emit = defineEmits(['close', 'save']);

const { t } = useI18n();

const formData = ref({
  name: '',
  color: '#4CAF50',
  filter_criteria: {},
});

const colors = [
  '#4CAF50', // Green
  '#2196F3', // Blue
  '#FF9800', // Orange
  '#9C27B0', // Purple
  '#F44336', // Red
  '#00BCD4', // Cyan
  '#FFEB3B', // Yellow
  '#795548', // Brown
];

const isNameValid = computed(() => formData.value.name.trim().length > 0);

const isFormValid = computed(() => isNameValid.value);

watch(
  () => props.show,
  newVal => {
    if (newVal) {
      if (props.mode === 'edit' && props.column) {
        formData.value = {
          name: props.column.name,
          color: props.column.color || '#4CAF50',
          filter_criteria: props.column.filter_criteria || {},
        };
      } else {
        formData.value = {
          name: '',
          color: '#4CAF50',
          filter_criteria: {},
        };
      }
    }
  }
);

const handleSave = () => {
  if (!isFormValid.value) return;
  emit('save', formData.value);
};

const handleClose = () => {
  emit('close');
};
</script>

<template>
  <Modal
    :show="show"
    :on-close="handleClose"
    class="kanban-column-manager"
  >
    <template #header>
      <h3 class="text-lg font-semibold text-n-slate-12 dark:text-n-slate-12">
        {{
          mode === 'edit'
            ? t('KANBAN.COLUMN.EDIT')
            : t('KANBAN.COLUMN.ADD')
        }}
      </h3>
    </template>

    <template #body>
      <div class="flex flex-col gap-4 p-6">
        <!-- Column Name -->
        <div>
          <label class="block text-sm font-medium mb-2 text-n-slate-12 dark:text-n-slate-12">
            {{ t('KANBAN.COLUMN.NAME') }}
          </label>
          <Input
            v-model="formData.name"
            :placeholder="t('KANBAN.COLUMN.NAME_PLACEHOLDER')"
            class="w-full"
          />
        </div>

        <!-- Color Picker -->
        <div>
          <label class="block text-sm font-medium mb-2 text-n-slate-12 dark:text-n-slate-12">
            {{ t('KANBAN.COLUMN.COLOR') }}
          </label>
          <div class="flex gap-2 flex-wrap">
            <button
              v-for="color in colors"
              :key="color"
              type="button"
              :class="[
                'w-10 h-10 rounded-lg border-2 transition-all',
                formData.color === color
                  ? 'border-n-slate-12 scale-110'
                  : 'border-transparent hover:scale-105',
              ]"
              :style="{ backgroundColor: color }"
              @click="formData.color = color"
            />
          </div>
        </div>

        <!-- Filter Criteria Placeholder -->
        <div class="text-sm text-n-slate-11 dark:text-n-slate-11">
          <i class="i-lucide-info mr-1" />
          {{ t('KANBAN.COLUMN.FILTER') }} (Coming soon)
        </div>
      </div>
    </template>

    <template #footer>
      <div class="flex gap-2 justify-end p-4">
        <Button
          variant="clear"
          @click="handleClose"
        >
          {{ t('GENERAL_SETTINGS.CANCEL') }}
        </Button>
        <Button
          :disabled="!isFormValid"
          @click="handleSave"
        >
          {{ mode === 'edit' ? t('GENERAL_SETTINGS.UPDATE') : t('GENERAL_SETTINGS.CREATE') }}
        </Button>
      </div>
    </template>
  </Modal>
</template>
