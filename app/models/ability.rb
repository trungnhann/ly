# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || AdminUser.new

    if @user.user_type_superadmin? || @user.user_type_admin?
      admin_abilities
    elsif @user.user_type_student?
      student_abilities
    else
      guest_abilities
    end
  end

  private

  def admin_abilities
    can :manage, :all
  end

  def student_abilities
    student_id = @user.student&.id
    return if student_id.blank?

    can %i[read update], Student, id: student_id
    can :manage, FaceVerificationSetting, id: student_id
    can :read, Certificate, student_id: student_id
    can :verify_face_authentication, Certificate, student_id: student_id
  end

  def guest_abilities; end
end
