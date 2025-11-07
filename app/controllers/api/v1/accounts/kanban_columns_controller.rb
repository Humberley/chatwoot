class Api::V1::Accounts::KanbanColumnsController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  before_action :fetch_kanban_columns, only: [:index]
  before_action :fetch_kanban_column, only: [:show, :update, :destroy]

  def index; end

  def show; end

  def create
    @kanban_column = Current.account.kanban_columns.create!(
      permitted_payload.merge(user: Current.user)
    )
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def update
    @kanban_column.update!(permitted_payload)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def destroy
    @kanban_column.destroy!
    head :no_content
  end

  def reorder
    board_type = params[:board_type] || 'contact'
    column_ids = params[:column_ids] || []

    authorize KanbanColumn, :reorder?

    column_ids.each_with_index do |column_id, index|
      column = Current.account.kanban_columns.find_by(
        id: column_id,
        user: Current.user,
        board_type: board_type
      )
      column&.update(position: index)
    end

    @kanban_columns = Current.account.kanban_columns.where(
      user: Current.user,
      board_type: board_type
    ).ordered

    render :index
  end

  private

  def fetch_kanban_columns
    board_type = params[:board_type] || 'contact'
    @kanban_columns = Current.account.kanban_columns.where(
      user: Current.user,
      board_type: board_type
    ).ordered
  end

  def fetch_kanban_column
    @kanban_column = Current.account.kanban_columns.where(
      user: Current.user
    ).find(params[:id])
    authorize @kanban_column
  end

  def permitted_payload
    params.require(:kanban_column).permit(
      :name,
      :color,
      :board_type,
      :position,
      filter_criteria: {}
    )
  end

  def check_authorization
    authorize KanbanColumn
  end
end
