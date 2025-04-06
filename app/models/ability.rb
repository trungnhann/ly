# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(_user)
    can :manage, :all
    # return unless user.present?

    # if user.superadmin?
    #   can :manage, :all
    # elsif user.admin?
    #   can :manage, Student
    #   can :manage, Certificate
    # elsif user.accountant?
    #   can :read, Student
    #   can :read, Certificate
    # end
  end
end
