# == Schema Information
#
# Table name: students
#
#  id             :bigint           not null, primary key
#  code           :string           not null, indexed
#  email          :string           not null, indexed
#  full_name      :string           not null
#  id_card_number :string           not null, indexed
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_students_on_code            (code) UNIQUE
#  index_students_on_email           (email) UNIQUE
#  index_students_on_id_card_number  (id_card_number) UNIQUE
#
require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
