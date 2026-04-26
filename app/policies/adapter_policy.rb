# frozen_string_literal: true

class AdapterPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || record.user == user
  end

  def create?
    user.admin? || user.developer?
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end

  def archive?
    update?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
