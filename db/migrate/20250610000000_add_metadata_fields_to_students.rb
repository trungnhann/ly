class AddMetadataFieldsToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :phone, :string
    add_column :students, :major, :string
    add_column :students, :specialization, :string
    add_column :students, :address, :string
  end
end
