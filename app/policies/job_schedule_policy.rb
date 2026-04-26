# frozen_string_literal: true

class JobSchedulePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.adapter.user == user
  end

  def create?
    user.admin? || user.developer?
  end

  def update?
    user.admin? || record.adapter.user == user
  end

  def destroy?
    user.admin? || record.adapter.user == user
  end

  def enable?
    update?
  end

  def disable?
    update?
  end

  def run_now?
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
