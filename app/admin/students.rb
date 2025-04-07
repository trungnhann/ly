ActiveAdmin.register Student do
  permit_params :code, :full_name, :id_card_number, :email, :avatar,
                :metadata_phone, :metadata_major, :metadata_specialization
  remove_filter :avatar_attachment
  remove_filter :avatar_blob

  form html: { multipart: true } do |f|
    f.inputs 'Student Details' do
      f.input :code
      f.input :full_name
      f.input :id_card_number
      f.input :email
      f.input :avatar, as: :file
    end

    f.inputs 'Student Metadata' do
      f.input :metadata_phone, label: 'Phone'
      f.input :metadata_major, label: 'Major'
      f.input :metadata_specialization, label: 'Specialization'
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

      row :avatar do |student|
        if student.avatar.attached?
          image_tag url_for(student.avatar), style: 'max-height: 200px;'
        else
          status_tag 'No Avatar'
        end
      end

      row :phone do |student|
        student.metadata&.phone
      end
      row :major do |student|
        student.metadata&.major
      end
      row :specialization do |student|
        student.metadata&.specialization
      end
    end
  end

  controller do
    def create
      @student = Student.new(permitted_params[:student].except(
                               :metadata_phone, :metadata_major, :metadata_specialization
                             ))

      @student.avatar.attach(permitted_params[:student][:avatar]) if permitted_params[:student][:avatar].present?

      if @student.save
        @student.create_or_update_metadata(permitted_params[:student])
        redirect_to admin_student_path(@student), notice: 'Student was successfully created.'
      else
        render :new
      end
    end

    def update
      student_params = permitted_params[:student]

      if resource.update(student_params.except(
                           :metadata_phone, :metadata_major, :metadata_specialization
                         ))
        if student_params[:avatar].present?
          resource.avatar.purge if resource.avatar.attached?
          resource.avatar.attach(student_params[:avatar])
        end

        resource.create_or_update_metadata(student_params)
        redirect_to admin_student_path(resource), notice: 'Student was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @student = Student.find(params[:id])
      ActiveRecord::Base.transaction do
        if @student.metadata.present?
          Rails.logger.info "Manually deleting metadata for student #{@student.id}"
          @student.metadata.delete
        end

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
