class KanbanColumnPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.account_id == account.id && record.user_id == user.id
  end

  def create?
    true
  end

  def update?
    record.account_id == account.id && record.user_id == user.id
  end

  def destroy?
    record.account_id == account.id && record.user_id == user.id
  end

  def reorder?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(account_id: account.id, user_id: user.id)
    end
  end
end
