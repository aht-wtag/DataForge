# frozen_string_literal: true

class ExecutionLogPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.adapter.user == user
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    user.admin?
  end

  def retry?
    user.admin? || record.adapter.user == user
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:adapter).where(adapters: { user_id: user.id })
      end
    end
  end
end
