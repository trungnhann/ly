class AddIsPublicToCertificates < ActiveRecord::Migration[8.0]
  def change
    add_column :certificates, :is_public, :boolean, default: false
  end
end
