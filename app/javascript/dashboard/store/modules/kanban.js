import types from '../mutation-types';
import KanbanAPI from '../../api/kanban';

const BOARD_TYPES = {
  CONTACT: 'contact',
  CONVERSATION: 'conversation',
};

export const state = {
  [BOARD_TYPES.CONTACT]: {
    columns: [],
  },
  [BOARD_TYPES.CONVERSATION]: {
    columns: [],
  },
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

export const getters = {
  getUIFlags(_state) {
    return _state.uiFlags;
  },
  getColumnsByBoardType: _state => boardType => {
    return _state[boardType].columns;
  },
  getContactColumns(_state) {
    return _state[BOARD_TYPES.CONTACT].columns;
  },
  getConversationColumns(_state) {
    return _state[BOARD_TYPES.CONVERSATION].columns;
  },
};

export const actions = {
  getColumns: async ({ commit }, boardType = BOARD_TYPES.CONTACT) => {
    commit(types.SET_KANBAN_UI_FLAG, { isFetching: true });
    try {
      const response = await KanbanAPI.getColumns(boardType);
      commit(types.SET_KANBAN_COLUMNS, {
        columns: response.data,
        boardType,
      });
    } catch (error) {
      console.error('Error fetching kanban columns:', error);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isFetching: false });
    }
  },

  createColumn: async ({ commit }, { boardType, columnData }) => {
    commit(types.SET_KANBAN_UI_FLAG, { isCreating: true });
    try {
      const response = await KanbanAPI.createColumn(columnData);
      commit(types.ADD_KANBAN_COLUMN, {
        column: response.data,
        boardType,
      });
      return response.data;
    } catch (error) {
      const errorMessage =
        error?.response?.data?.error || 'Failed to create column';
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isCreating: false });
    }
  },

  updateColumn: async ({ commit }, { boardType, columnId, columnData }) => {
    commit(types.SET_KANBAN_UI_FLAG, { isUpdating: true });
    try {
      const response = await KanbanAPI.updateColumn(columnId, columnData);
      commit(types.UPDATE_KANBAN_COLUMN, {
        column: response.data,
        boardType,
      });
      return response.data;
    } catch (error) {
      const errorMessage =
        error?.response?.data?.error || 'Failed to update column';
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isUpdating: false });
    }
  },

  deleteColumn: async ({ commit }, { boardType, columnId }) => {
    commit(types.SET_KANBAN_UI_FLAG, { isDeleting: true });
    try {
      await KanbanAPI.deleteColumn(columnId);
      commit(types.DELETE_KANBAN_COLUMN, {
        columnId,
        boardType,
      });
    } catch (error) {
      const errorMessage =
        error?.response?.data?.error || 'Failed to delete column';
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isDeleting: false });
    }
  },

  reorderColumns: async ({ commit }, { boardType, columnIds }) => {
    commit(types.SET_KANBAN_UI_FLAG, { isUpdating: true });
    try {
      const response = await KanbanAPI.reorderColumns(boardType, columnIds);
      commit(types.SET_KANBAN_COLUMNS, {
        columns: response.data,
        boardType,
      });
    } catch (error) {
      const errorMessage =
        error?.response?.data?.error || 'Failed to reorder columns';
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isUpdating: false });
    }
  },

  moveCard: async (
    { commit },
    { boardType, cardId, columnId, position }
  ) => {
    commit(types.SET_KANBAN_UI_FLAG, { isUpdating: true });
    try {
      if (boardType === BOARD_TYPES.CONTACT) {
        await KanbanAPI.moveContact(cardId, columnId, position);
      } else {
        await KanbanAPI.moveConversation(cardId, columnId, position);
      }
    } catch (error) {
      const errorMessage =
        error?.response?.data?.error || 'Failed to move card';
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_KANBAN_UI_FLAG, { isUpdating: false });
    }
  },
};

export const mutations = {
  [types.SET_KANBAN_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.SET_KANBAN_COLUMNS]: (_state, { columns, boardType }) => {
    _state[boardType].columns = columns;
  },

  [types.ADD_KANBAN_COLUMN]: (_state, { column, boardType }) => {
    _state[boardType].columns.push(column);
  },

  [types.UPDATE_KANBAN_COLUMN]: (_state, { column, boardType }) => {
    const index = _state[boardType].columns.findIndex(c => c.id === column.id);
    if (index !== -1) {
      _state[boardType].columns[index] = column;
    }
  },

  [types.DELETE_KANBAN_COLUMN]: (_state, { columnId, boardType }) => {
    _state[boardType].columns = _state[boardType].columns.filter(
      c => c.id !== columnId
    );
  },

  [types.REORDER_KANBAN_COLUMNS]: (_state, { columns, boardType }) => {
    _state[boardType].columns = columns;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
