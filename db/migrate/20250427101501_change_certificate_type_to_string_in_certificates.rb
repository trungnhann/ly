class ChangeCertificateTypeToStringInCertificates < ActiveRecord::Migration[8.0]
  def change
    change_column :certificates, :certificate_type, :string
  end
end
