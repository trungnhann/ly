class StudentsService
  def create(params)
    ActiveRecord::Base.transaction do
      student = Student.new(params.except(:avatar))
      student.avatar.attach(params[:avatar]) if params[:avatar].present?

      if student.save!
        admin_user = AdminUser.create!(
          email: "#{student.code}@actvn.edu.vn",
          password: 'password123',
          password_confirmation: 'password123',
          user_type: 'student',
          student_id: student.id,
          full_name: student.full_name
        )

        admin_user.create_face_verification_setting(FaceVerificationSetting.default_settings)

        student.create_or_update_metadata(params)
        { data: StudentSerializer.new(student).serializable_hash, status: :created }
      else
        { errors: student.errors.full_messages, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    { errors: e.record.errors.full_messages, status: :unprocessable_entity }
  rescue StandardError => e
    { errors: [e.message], status: :unprocessable_entity }
  end

  def update(student, params)
    if student.admin_user&.user_type_student? &&
       (params[:code].present? || params[:full_name].present? || params[:email].present? || params[:id_card_number].present?)
      return {
        errors: ['Không được phép cập nhật mã sinh viên, họ tên, email và số CMND/CCCD'],
        status: :forbidden
      }
    end

    ActiveRecord::Base.transaction do
      if params[:avatar].present?
        student.avatar.purge if student.avatar.attached?
        student.avatar.attach(params[:avatar])
      end

      student.create_or_update_metadata(params)
      {
        data: StudentSerializer.new(student).serializable_hash,
        status: :ok
      }
    end
  rescue StandardError => e
    {
      errors: [e.message],
      status: :unprocessable_entity
    }
  end

  def destroy(student)
    ActiveRecord::Base.transaction do
      student.avatar.purge if student.avatar.attached?
      student.metadata&.delete

      student.admin_user&.destroy!

      student.destroy!

      { message: 'Student was successfully deleted.', status: :ok }
    end
  rescue StandardError => e
    { errors: ["Failed to delete student: #{e.message}"], status: :unprocessable_entity }
  end
end
