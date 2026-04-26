# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      scope.none
    end
  end
end
