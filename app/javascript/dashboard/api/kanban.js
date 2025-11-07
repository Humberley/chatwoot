/* global axios */
import ApiClient from './ApiClient';

class KanbanAPI extends ApiClient {
  constructor() {
    super('kanban_columns', { accountScoped: true });
  }

  getColumns(boardType = 'contact') {
    return axios.get(`${this.url}?board_type=${boardType}`);
  }

  createColumn(columnData) {
    return axios.post(this.url, {
      kanban_column: columnData,
    });
  }

  updateColumn(columnId, columnData) {
    return axios.patch(`${this.url}/${columnId}`, {
      kanban_column: columnData,
    });
  }

  deleteColumn(columnId) {
    return axios.delete(`${this.url}/${columnId}`);
  }

  reorderColumns(boardType, columnIds) {
    return axios.post(`${this.url}/reorder`, {
      board_type: boardType,
      column_ids: columnIds,
    });
  }

  moveContact(contactId, columnId, position) {
    const contactsUrl = this.url.replace('kanban_columns', 'contacts');
    return axios.patch(`${contactsUrl}/${contactId}/update_kanban_position`, {
      column_id: columnId,
      position,
    });
  }

  moveConversation(conversationId, columnId, position) {
    const conversationsUrl = this.url.replace(
      'kanban_columns',
      'conversations'
    );
    return axios.patch(
      `${conversationsUrl}/${conversationId}/update_kanban_position`,
      {
        column_id: columnId,
        position,
      }
    );
  }
}

export default new KanbanAPI();
