# frozen_string_literal: true

class CreateKanbanColumns < ActiveRecord::Migration[7.1]
  def change
    create_table :kanban_columns do |t|
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :color
      t.integer :board_type, null: false, default: 0
      t.references :account, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true, index: false
      t.jsonb :filter_criteria, default: {}

      t.timestamps
    end

    add_index :kanban_columns, [:account_id, :user_id, :board_type], name: 'index_kanban_columns_on_account_user_board'
    add_index :kanban_columns, :position
  end
end
