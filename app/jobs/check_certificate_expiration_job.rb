class CheckCertificateExpirationJob < ApplicationJob
  queue_as :default

  def perform
    expiring_certificates = Certificate.includes(student: :admin_user).where(
      expiry_date: Time.current..30.days.from_now
    )

    expiring_certificates.each do |certificate|
      admin_user = certificate.student&.admin_user
      next if admin_user.nil?

      content = "Chứng chỉ #{certificate.code} của sinh viên sẽ hết hạn vào ngày " \
                "#{certificate.expiry_date.strftime('%d/%m/%Y')}"

      next if Notification.exists?(
        notification_type: :certificate_expiring,
        content: content,
        admin_user_id: admin_user.id
      )

      Notification.create!(
        title: 'Chứng chỉ sắp hết hạn',
        content: content,
        notification_type: :certificate_expiring,
        admin_user: admin_user
      )
    end
  end
end
