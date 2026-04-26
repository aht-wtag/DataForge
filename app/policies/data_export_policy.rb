# frozen_string_literal: true

class DataExportPolicy < ApplicationPolicy
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
    false
  end

  def destroy?
    user.admin?
  end

  def download?
    show?
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
