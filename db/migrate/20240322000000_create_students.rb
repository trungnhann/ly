class CreateStudents < ActiveRecord::Migration[7.0]
  def change
    create_table :students do |t|
      t.string :code, null: false
      t.string :full_name, null: false
      t.string :id_card_number, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :students, :code, unique: true
    add_index :students, :id_card_number, unique: true
    add_index :students, :email, unique: true
  end
end
