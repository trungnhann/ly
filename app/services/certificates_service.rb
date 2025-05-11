class CertificatesService
  def index(params)
    certificates = Certificate.accessible_by(Ability.new(Current.user))
    certificates = certificates.where(student_id: params[:student_id]) if params[:student_id].present?
    certificates = certificates.where(certificate_type: params[:certificate_type]) if params[:certificate_type].present?

    # if params[:q].present?
    #   keyword = "%#{params[:q]}%"
    #   certificates = certificates.where('title ILIKE ? OR code ILIKE ?', keyword, keyword)
    # end

    data = certificates.map do |certificate|
      CertificateSerializer.new(certificate).serializable_hash
    end

    { data:, status: :ok }
  rescue StandardError => e
    { errors: [e.message], status: :internal_server_error }
  end

  def show(certificate)
    { data: CertificateSerializer.new(certificate).serializable_hash, status: :ok }
  rescue StandardError => e
    { errors: [e.message], status: :internal_server_error }
  end

  def find_by_code(code)
    certificate = Certificate.find_by(code: code)

    if certificate.present?
      { data: CertificateSerializer.new(certificate, include: [:student]).serializable_hash, status: :ok }
    else
      { errors: ['Không tìm thấy chứng chỉ với mã đã cung cấp'], status: :not_found }
    end
  rescue StandardError => e
    { errors: [e.message], status: :internal_server_error }
  end

  def create(params)
    certificate = Certificate.new(params.except(:file, :metadata))

    attach_file(certificate, params[:file]) if params[:file].present?

    if certificate.save
      update_metadata(certificate, params[:metadata])
      { data: CertificateSerializer.new(certificate).serializable_hash, status: :created }
    else
      { errors: certificate.errors.full_messages, status: :unprocessable_entity }
    end
  end

  def update(certificate, params)
    if params[:file].present?
      certificate.file.purge if certificate.file.attached?
      attach_file(certificate, params[:file])
    end

    if certificate.update(params.except(:file, :metadata))
      update_metadata(certificate, params[:metadata])
      { data: CertificateSerializer.new(certificate).serializable_hash, status: :ok }
    else
      { errors: certificate.errors.full_messages, status: :unprocessable_entity }
    end
  end

  def destroy(certificate)
    certificate.file.purge if certificate.file.attached?
    certificate.cleanup_metadata if certificate.respond_to?(:cleanup_metadata)

    if certificate.destroy
      { message: 'Certificate was successfully deleted.', status: :ok }
    else
      { errors: certificate.errors.full_messages, status: :unprocessable_entity }
    end
  end

  def attach_file(certificate, file)
    if file.content_type != 'application/pdf'
      certificate.errors.add(:file, 'phải là file PDF')
      return
    end

    certificate.file.attach(file)
  end

  def update_metadata(certificate, metadata_params)
    return if metadata_params.blank?

    metadata = certificate.metadata || CertificateMetadata.new(certificate_id: certificate.id.to_s)

    metadata.certificate_type = certificate.certificate_type
    metadata.issuer = metadata_params[:issuer] if metadata_params[:issuer].present?
    metadata.description = metadata_params[:description] if metadata_params[:description].present?

    metadata.degree_info = {}
    metadata.certificate_info = {}
    metadata.certification_info = {}

    case certificate.certificate_type
    when 'degree'
      if metadata_params[:degree_info].present?
        metadata.degree_info = {
          level: metadata_params.dig(:degree_info, :level),
          major: metadata_params.dig(:degree_info, :major),
          specialization: metadata_params.dig(:degree_info, :specialization),
          grade: metadata_params.dig(:degree_info, :grade),
          graduation_year: metadata_params.dig(:degree_info, :graduation_year)
        }.compact
      end
    when 'certificate'
      if metadata_params[:certificate_info].present?
        metadata.certificate_info = {
          provider: metadata_params.dig(:certificate_info, :provider),
          field: metadata_params.dig(:certificate_info, :field),
          score: metadata_params.dig(:certificate_info, :score),
          level: metadata_params.dig(:certificate_info, :level)
        }.compact
      end
    when 'certification'
      if metadata_params[:certification_info].present?
        metadata.certification_info = {
          event: metadata_params.dig(:certification_info, :event),
          achievement: metadata_params.dig(:certification_info, :achievement),
          duration: metadata_params.dig(:certification_info, :duration),
          organizer: metadata_params.dig(:certification_info, :organizer)
        }.compact
      end
    end
    Rails.logger.debug { "Metadata trước khi lưu: #{metadata.inspect}" }

    if metadata.save
      Rails.logger.debug { "Metadata sau khi lưu: #{metadata.inspect}" }
      certificate.update_column(:metadata_id, metadata.id.to_s) if certificate.metadata_id.blank?
    else
      Rails.logger.error "Lỗi khi lưu metadata: #{metadata.errors.full_messages}"
    end
  end
end
