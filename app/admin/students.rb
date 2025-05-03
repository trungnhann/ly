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

      begin
        puts "🔥 Bắt đầu xoá student ID: #{@student.id}"

        if @student.metadata.present?
          puts "🧹 Đang xoá metadata ID: #{@student.metadata.id}"
          @student.metadata.delete
        else
          puts '⚠️ Không tìm thấy metadata để xoá'
        end

        # Nếu student có certificates, xoá cả metadata của chúng
        if @student.certificates.any?
          puts "🗂 Đang xoá #{@student.certificates.count} certificate kèm metadata..."
          @student.certificates.each do |cert|
            puts " - Xoá certificate ##{cert.id} + metadata..."
            cert.metadata&.delete
            cert.destroy!
          end
        end

        # Xoá student
        @student.destroy!
        puts "✅ Student #{@student.id} đã được xoá thành công"

        redirect_to admin_students_path, notice: 'Student was successfully deleted.'
      rescue StandardError => e
        puts "❌ Xoá thất bại: #{e.message}"
        Rails.logger.error "Student deletion failed: #{e.message}"
        redirect_to admin_student_path(@student), alert: "Cannot delete student: #{e.message}"
      end
    end
  end
end
