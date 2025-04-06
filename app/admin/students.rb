ActiveAdmin.register Student do
  permit_params :code, :full_name, :id_card_number, :email,
                :metadata_phone, :metadata_major, :metadata_specialization,
                :metadata_avatar, :metadata_id_card_front, :metadata_id_card_back

  form html: { multipart: true } do |f|
    f.inputs 'Student Details' do
      f.input :code
      f.input :full_name
      f.input :id_card_number
      f.input :email
    end

    f.inputs 'Student Metadata' do
      f.input :metadata_phone, label: 'Phone'
      f.input :metadata_major, label: 'Major'
      f.input :metadata_specialization, label: 'Specialization'
      f.input :metadata_avatar, as: :file, label: 'Avatar'
      f.input :metadata_id_card_front, as: :file, label: 'ID Card Front'
      f.input :metadata_id_card_back, as: :file, label: 'ID Card Back'
    end

    f.actions
  end

  show do
    attributes_table do
      row :code
      row :full_name
      row :id_card_number
      row :email
      row :created_at
      row :updated_at

      # Metadata fields
      row :phone do |student|
        student.metadata&.phone
      end
      row :major do |student|
        student.metadata&.major
      end
      row :specialization do |student|
        student.metadata&.specialization
      end
      row :avatar do |student|
        image_tag(student.metadata.avatar_url) if student.metadata&.avatar_url.present?
      end
      row :id_card_front do |student|
        image_tag(student.metadata.id_card_front_url) if student.metadata&.id_card_front_url.present?
      end
      row :id_card_back do |student|
        image_tag(student.metadata.id_card_back_url) if student.metadata&.id_card_back_url.present?
      end
    end
  end

  controller do
    def create
      @student = Student.new(permitted_params[:student].except(
                               :metadata_phone, :metadata_major, :metadata_specialization,
                               :metadata_avatar, :metadata_id_card_front, :metadata_id_card_back
                             ))

      if @student.save
        @student.create_or_update_metadata(permitted_params[:student])
        redirect_to admin_student_path(@student), notice: 'Student was successfully created.'
      else
        render :new
      end
    end

    def update
      if resource.update(permitted_params[:student].except(
                           :metadata_phone, :metadata_major, :metadata_specialization,
                           :metadata_avatar, :metadata_id_card_front, :metadata_id_card_back
                         ))
        resource.create_or_update_metadata(permitted_params[:student])
        redirect_to admin_student_path(resource), notice: 'Student was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @student = Student.find(params[:id])
      ActiveRecord::Base.transaction do
        # Force deletion of metadata first
        if @student.metadata.present?
          Rails.logger.info "Manually deleting metadata for student #{@student.id}"
          @student.metadata.delete
        end

        # Then delete the student
        raise ActiveRecord::Rollback unless @student.destroy

        redirect_to admin_students_path, notice: 'Student was successfully deleted.'
        return
      end

      redirect_to admin_student_path(@student), alert: 'Failed to delete student.'
    rescue StandardError => e
      Rails.logger.error "Student deletion error: #{e.message}"
      redirect_to admin_student_path(@student), alert: "Error: #{e.message}"
    end
  end

  # Make sure we're using the correct HTTP method for delete
  config.clear_action_items!

  action_item :edit, only: :show do
    link_to 'Edit Student', edit_admin_student_path(resource), class: 'edit_button'
  end

  action_item :destroy, only: :show do
    button_to 'Delete Student', admin_student_path(resource),
              method: :delete,
              form: { data: { confirm: 'Are you sure you want to delete this student?' } },
              class: 'delete_button'
  end
end
