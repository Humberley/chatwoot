# == Schema Information
#
# Table name: kanban_columns
#
#  id              :bigint           not null, primary key
#  board_type      :integer          default("contact"), not null
#  color           :string
#  filter_criteria :jsonb
#  name            :string           not null
#  position        :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_kanban_columns_on_account_user_board  (account_id,user_id,board_type)
#  index_kanban_columns_on_position            (position)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (user_id => users.id)
#
class KanbanColumn < ApplicationRecord
  belongs_to :user
  belongs_to :account

  enum board_type: { contact: 0, conversation: 1 }

  validates :name, presence: true, length: { maximum: 50 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :board_type, presence: true
  validate :validate_number_of_columns

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_board_type, ->(type) { where(board_type: type) }
  scope :ordered, -> { order(position: :asc) }

  before_create :set_position

  def move_to_position(new_position)
    transaction do
      if new_position < position
        # Moving left
        self.class.where(account_id: account_id, user_id: user_id, board_type: board_type)
                  .where('position >= ? AND position < ?', new_position, position)
                  .update_all('position = position + 1')
      elsif new_position > position
        # Moving right
        self.class.where(account_id: account_id, user_id: user_id, board_type: board_type)
                  .where('position > ? AND position <= ?', position, new_position)
                  .update_all('position = position - 1')
      end

      update!(position: new_position)
    end
  end

  def cards
    base_scope = board_type == 'contact' ? account.contacts : account.conversations

    # Filter by cards in this column
    base_scope = base_scope.where("custom_attributes->>'kanban_column_id' = ?", id.to_s)

    # Apply column filters if any
    base_scope = apply_column_filters(base_scope) if filter_criteria.present?

    base_scope.order("(custom_attributes->>'kanban_position')::integer ASC NULLS LAST, id ASC")
  end

  private

  def set_position
    return if position.present?

    max_position = self.class.where(account_id: account_id, user_id: user_id, board_type: board_type).maximum(:position)
    self.position = (max_position || -1) + 1
  end

  def validate_number_of_columns
    return if user_id.blank? || account_id.blank?

    max_columns = 20 # Reasonable limit
    columns_count = self.class.where(account_id: account_id, user_id: user_id, board_type: board_type).count
    return if persisted? || columns_count < max_columns

    errors.add(:base, "You can't have more than #{max_columns} columns per board")
  end

  def apply_column_filters(scope)
    # TODO: Implement filter application logic
    # This will integrate with existing FilterService
    # For now, return scope as-is
    scope
  end
end
