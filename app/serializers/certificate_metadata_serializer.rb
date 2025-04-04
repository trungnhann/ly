class CertificateMetadataSerializer < BaseSerializer
  attributes :id, :certificate_id, :type, :created_at, :updated_at

  def attributes(*args)
    data = super
    case object.type
    when 'degree'
      data.merge!(degree_info)
    when 'certificate'
      data.merge!(certificate_info)
    when 'certification'
      data.merge!(certification_info)
    end
    data
  end

  private

  def degree_info
    {
      degree_name: object.degree_name,
      major: object.major,
      graduation_date: object.graduation_date,
      honors: object.honors
    }.compact
  end

  def certificate_info
    {
      program_name: object.program_name,
      completion_date: object.completion_date,
      grade: object.grade
    }.compact
  end

  def certification_info
    {
      certification_name: object.certification_name,
      validity_period: object.validity_period,
      issuing_organization: object.issuing_organization
    }.compact
  end
end
