ActiveAdmin.register Certificate do
  actions :all

  permit_params :code, :title, :certificate_type, :issue_date, :expiry_date, :is_verified, :student_id,
                :metadata_issuer, :metadata_description, :metadata_image_path,
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
  filter :student
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
    end

    panel 'Metadata' do
      if resource.metadata.present?
        attributes_table_for resource.metadata do
          row :issuer
          row :description
          row :image_path

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

  form do |f|
    f.inputs 'Certificate Details' do
      f.input :code
      f.input :title
      f.input :certificate_type, as: :select, collection: Certificate.certificate_types.keys,
                                 input_html: { id: 'certificate_type_select' }
      f.input :issue_date
      f.input :expiry_date
      f.input :is_verified
      f.input :student
    end

    f.inputs 'Common Metadata', id: 'common_metadata' do
      f.input :metadata_issuer
      f.input :metadata_description
      f.input :metadata_image_path
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
    def create
      metadata_fields = permitted_metadata_fields
      @certificate = Certificate.new(permitted_params[:certificate].except(*metadata_fields))

      if @certificate.save
        create_or_update_metadata(@certificate, permitted_params[:certificate])
        redirect_to admin_certificate_path(@certificate), notice: 'Certificate was successfully created.'
      else
        render :new
      end
    end

    def update
      metadata_fields = permitted_metadata_fields
      if resource.update(permitted_params[:certificate].except(*metadata_fields))
        create_or_update_metadata(resource, permitted_params[:certificate])
        redirect_to admin_certificate_path(resource), notice: 'Certificate was successfully updated.'
      else
        render :edit
      end
    end

    private

    def permitted_metadata_fields
      %i[
        metadata_issuer metadata_description metadata_image_path
        metadata_degree_level metadata_degree_major metadata_degree_specialization
        metadata_degree_grade metadata_degree_graduation_year
        metadata_certificate_provider metadata_certificate_field
        metadata_certificate_score metadata_certificate_level
        metadata_certification_event metadata_certification_achievement
        metadata_certification_duration metadata_certification_organizer
      ]
    end

    def create_or_update_metadata(certificate, params)
      metadata_params = {
        issuer: params['metadata_issuer'],
        description: params['metadata_description'],
        image_path: params['metadata_image_path']
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
      when 'certificate'
        metadata_params[:certificate_info] = {
          provider: params['metadata_certificate_provider'],
          field: params['metadata_certificate_field'],
          score: params['metadata_certificate_score'],
          level: params['metadata_certificate_level']
        }.compact
      when 'certification'
        metadata_params[:certification_info] = {
          event: params['metadata_certification_event'],
          achievement: params['metadata_certification_achievement'],
          duration: params['metadata_certification_duration'],
          organizer: params['metadata_certification_organizer']
        }.compact
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
  end
end
