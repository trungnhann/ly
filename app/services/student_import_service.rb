class StudentImportService
  require 'roo'

  def initialize(file_path)
    @file_path = file_path
    @errors = []
    @success_count = 0
  end

  def import
    spreadsheet = Roo::Spreadsheet.open(@file_path)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      ActiveRecord::Base.transaction do
        student = Student.new(
          student_code: row['student_code'],
          full_name: row['full_name'],
          date_of_birth: row['date_of_birth'],
          gender: row['gender'],
          class_name: row['class_name'],
          major: row['major'],
          faculty: row['faculty']
        )

        if student.save
          # Tạo tài khoản AdminUser cho sinh viên
          admin_user = AdminUser.new(
            email: row['email'],
            password: generate_default_password,
            full_name: row['full_name'],
            user_type: 'student'
          )

          if admin_user.save
            student.update(admin_user: admin_user)
            @success_count += 1
          else
            @errors << "Dòng #{i}: Lỗi tạo tài khoản - #{admin_user.errors.full_messages.join(', ')}"
            raise ActiveRecord::Rollback
          end
        else
          @errors << "Dòng #{i}: Lỗi tạo sinh viên - #{student.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
      end
    end

    {
      success_count: @success_count,
      error_count: @errors.size,
      errors: @errors
    }
  end

  private

  def generate_default_password
    # Tạo mật khẩu mặc định là ngày sinh (format: DDMMYYYY)
    # Ví dụ: 01/01/2000 -> 01012000
    SecureRandom.hex(8)
  end
end
