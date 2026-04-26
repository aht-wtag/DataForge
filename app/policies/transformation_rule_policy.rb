# frozen_string_literal: true

class TransformationRulePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.endpoint.adapter.user == user
  end

  def create?
    user.admin? || user.developer?
  end

  def update?
    user.admin? || record.endpoint.adapter.user == user
  end

  def destroy?
    user.admin? || record.endpoint.adapter.user == user
  end

  def reorder?
    update?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(endpoint: :adapter).where(adapters: { user_id: user.id })
      end
    end
  end
end
