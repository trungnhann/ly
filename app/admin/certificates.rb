ActiveAdmin.register Certificate do
  actions :all

  permit_params :code, :title, :certificate_type, :issue_date, :expiry_date, :is_verified, :student_id, :file,
                :metadata_issuer, :metadata_description,
                :metadata_degree_level, :metadata_degree_major, :metadata_degree_specialization,
                :metadata_degree_grade, :metadata_degree_graduation_year,
                :metadata_certificate_provider, :metadata_certificate_field,
                :metadata_certificate_score, :metadata_certificate_level,
                :metadata_certification_event, :metadata_certification_achievement,
                :metadata_certification_duration, :metadata_certification_organizer

  index do
    selectable_column
    id_column
    column :code
    column :title
    column :certificate_type
    column :issue_date
    column :expiry_date
    column :is_verified
    column :student
    column :created_at
    actions
  end

  filter :code
  filter :title
  filter :certificate_type
  filter :issue_date
  filter :expiry_date
  filter :is_verified
  filter :student, collection: proc { Student.all.map { |s| ["#{s.code} - #{s.full_name}", s.id] } }
  filter :created_at

  show do
    attributes_table do
      row :id
      row :code
      row :title
      row :certificate_type
      row :issue_date
      row :expiry_date
      row :is_verified
      row :student
      row :created_at
      row :updated_at

      row :file do |certificate|
        if certificate.file.attached?
          if certificate.file.content_type == 'application/pdf'
            link_to certificate.file.filename, url_for(certificate.file), target: '_blank', rel: 'noopener'
          else
            status_tag 'File không phải PDF'
          end
        else
          status_tag 'Không có file'
        end
      end
    end

    panel 'Metadata' do
      if resource.metadata.present?
        attributes_table_for resource.metadata do
          row :issuer
          row :description

          case resource.certificate_type
          when 'degree'
            row('Level') { |m| m.degree_info['level'] }
            row('Major') { |m| m.degree_info['major'] }
            row('Specialization') { |m| m.degree_info['specialization'] }
            row('Grade') { |m| m.degree_info['grade'] }
            row('Graduation Year') { |m| m.degree_info['graduation_year'] }
          when 'certificate'
            row('Provider') { |m| m.certificate_info['provider'] }
            row('Field') { |m| m.certificate_info['field'] }
            row('Score') { |m| m.certificate_info['score'] }
            row('Level') { |m| m.certificate_info['level'] }
          when 'certification'
            row('Event') { |m| m.certification_info['event'] }
            row('Achievement') { |m| m.certification_info['achievement'] }
            row('Duration') { |m| m.certification_info['duration'] }
            row('Organizer') { |m| m.certification_info['organizer'] }
          end
        end
      else
        para 'No metadata available'
      end
    end
  end

  form html: { multipart: true } do |f|
    f.inputs 'Certificate Details' do
      f.input :code
      f.input :title
      f.input :certificate_type, as: :select, collection: Certificate.certificate_types.keys,
                                 input_html: { id: 'certificate_type_select' }
      f.input :issue_date
      f.input :expiry_date
      f.input :is_verified
      f.input :student, as: :select, collection: Student.all.map { |s| ["#{s.code} - #{s.full_name}", s.id] },
                        input_html: {
                          style: 'width: 400px',
                          class: 'select2-student',
                          data: { placeholder: 'Tìm kiếm theo mã số sinh viên hoặc tên' }
                        }
      f.input :file, as: :file, hint: 'Chỉ chấp nhận file PDF (bắt buộc)', label: 'File PDF',
                     required: !f.object.file.attached?
    end

    f.inputs 'Common Metadata', id: 'common_metadata' do
      f.input :metadata_issuer
      f.input :metadata_description
    end

    f.inputs 'Degree Metadata', id: 'degree_metadata' do
      f.input :metadata_degree_level
      f.input :metadata_degree_major
      f.input :metadata_degree_specialization
      f.input :metadata_degree_grade
      f.input :metadata_degree_graduation_year
    end

    f.inputs 'Certificate Metadata', id: 'certificate_metadata' do
      f.input :metadata_certificate_provider
      f.input :metadata_certificate_field
      f.input :metadata_certificate_score
      f.input :metadata_certificate_level
    end

    f.inputs 'Certification Metadata', id: 'certification_metadata' do
      f.input :metadata_certification_event
      f.input :metadata_certification_achievement
      f.input :metadata_certification_duration
      f.input :metadata_certification_organizer
    end

    f.actions
  end

  controller do
    before_action :assign_form_metadata_from_model, only: [:edit]

    def create
      metadata_fields = permitted_metadata_fields
      @certificate = Certificate.new(permitted_params[:certificate].except(*metadata_fields))

      if params[:certificate][:file].blank?
        @certificate.errors.add(:file, 'là bắt buộc, vui lòng tải lên file PDF')
        assign_form_metadata_from_params
        render :new and return
      end

      if params[:certificate][:file].present?
        file = params[:certificate][:file]
        unless file.content_type == 'application/pdf'
          @certificate.errors.add(:file, 'phải là file PDF')
          assign_form_metadata_from_params
          render :new and return
        end
      end

      if @certificate.save
        assign_metadata(@certificate, permitted_params[:certificate])
        redirect_to admin_certificate_path(@certificate), notice: 'Certificate was successfully created.'
      else
        assign_form_metadata_from_params
        render :new
      end
    end

    def update
      metadata_fields = permitted_metadata_fields

      if !resource.file.attached? && params[:certificate][:file].blank?
        resource.errors.add(:file, 'là bắt buộc, vui lòng tải lên file PDF')
        assign_form_metadata_from_params
        render :edit and return
      end

      if params[:certificate][:file].present?
        file = params[:certificate][:file]
        unless file.content_type == 'application/pdf'
          resource.errors.add(:file, 'phải là file PDF')
          assign_form_metadata_from_params
          render :edit and return
        end
      end

      if resource.update(permitted_params[:certificate].except(*metadata_fields))
        assign_metadata(resource, permitted_params[:certificate])
        redirect_to admin_certificate_path(resource), notice: 'Certificate was successfully updated.'
      else
        assign_form_metadata_from_params
        render :edit
      end
    end

    private

    def assign_form_metadata_from_params
      permitted_metadata_fields.each do |field|
        resource.send("#{field}=", params[:certificate][field])
      end
    end

    def assign_form_metadata_from_model
      return if resource.metadata.blank?

      resource.metadata_issuer = resource.metadata.issuer
      resource.metadata_description = resource.metadata.description

      case resource.certificate_type
      when 'degree'
        if resource.metadata.degree_info.present?
          resource.metadata_degree_level = resource.metadata.degree_info['level']
          resource.metadata_degree_major = resource.metadata.degree_info['major']
          resource.metadata_degree_specialization = resource.metadata.degree_info['specialization']
          resource.metadata_degree_grade = resource.metadata.degree_info['grade']
          resource.metadata_degree_graduation_year = resource.metadata.degree_info['graduation_year']
        end
      when 'certificate'
        if resource.metadata.certificate_info.present?
          resource.metadata_certificate_provider = resource.metadata.certificate_info['provider']
          resource.metadata_certificate_field = resource.metadata.certificate_info['field']
          resource.metadata_certificate_score = resource.metadata.certificate_info['score']
          resource.metadata_certificate_level = resource.metadata.certificate_info['level']
        end
      when 'certification'
        if resource.metadata.certification_info.present?
          resource.metadata_certification_event = resource.metadata.certification_info['event']
          resource.metadata_certification_achievement = resource.metadata.certification_info['achievement']
          resource.metadata_certification_duration = resource.metadata.certification_info['duration']
          resource.metadata_certification_organizer = resource.metadata.certification_info['organizer']
        end
      end
    end

    def assign_metadata(certificate, params)
      metadata_params = {
        issuer: params['metadata_issuer'],
        description: params['metadata_description'],
        certificate_type: certificate.certificate_type
      }.compact

      case certificate.certificate_type
      when 'degree'
        metadata_params[:degree_info] = {
          level: params['metadata_degree_level'],
          major: params['metadata_degree_major'],
          specialization: params['metadata_degree_specialization'],
          grade: params['metadata_degree_grade'],
          graduation_year: params['metadata_degree_graduation_year']
        }.compact
        metadata_params[:certificate_info] = {}
        metadata_params[:certification_info] = {}
      when 'certificate'
        metadata_params[:certificate_info] = {
          provider: params['metadata_certificate_provider'],
          field: params['metadata_certificate_field'],
          score: params['metadata_certificate_score'],
          level: params['metadata_certificate_level']
        }.compact
        metadata_params[:degree_info] = {}
        metadata_params[:certification_info] = {}
      when 'certification'
        metadata_params[:certification_info] = {
          event: params['metadata_certification_event'],
          achievement: params['metadata_certification_achievement'],
          duration: params['metadata_certification_duration'],
          organizer: params['metadata_certification_organizer']
        }.compact
        metadata_params[:degree_info] = {}
        metadata_params[:certificate_info] = {}
      end

      if certificate.metadata
        certificate.metadata.update(metadata_params)
      else
        meta = CertificateMetadata.create(metadata_params.merge(
                                            certificate_id: certificate.id.to_s,
                                            certificate_type: certificate.certificate_type
                                          ))
        certificate.update_column(:metadata_id, meta.id.to_s)
      end
    end

    def permitted_metadata_fields
      %i[
        metadata_issuer metadata_description
        metadata_degree_level metadata_degree_major metadata_degree_specialization
        metadata_degree_grade metadata_degree_graduation_year
        metadata_certificate_provider metadata_certificate_field
        metadata_certificate_score metadata_certificate_level
        metadata_certification_event metadata_certification_achievement
        metadata_certification_duration metadata_certification_organizer
      ]
    end
  end
end
