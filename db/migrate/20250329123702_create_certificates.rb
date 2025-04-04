class CreateCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificates do |t|
      t.string :code, null: false
      t.string :title, null: false
      t.integer :certificate_type, null: false
      t.date :issue_date, null: false
      t.date :expiry_date, null: true
      t.boolean :is_verified, default: true
      t.string :metadata_id
      t.references :student, null: false, foreign_key: true
      t.timestamps
    end
    add_index :certificates, :code, unique: true
  end
end
