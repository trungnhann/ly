require 'roo'

module Students
  class ImportStudentFromExcelService
    prepend ServiceModule::Base

    REQUIRED_HEADERS = [
      'Mã Số Sinh Viên',
      'Họ Và Tên',
      'Số CCCD'
    ].freeze

    ALLOWED_FILE_EXTENSIONS = %w[.xlsx .xls].freeze

    def call(file_path:)
      run :validate_file_path
      run :open_spreadsheet
      run :validate_headers
      run :process_rows
      run :create_success_result
    end

    private

    def validate_file_path(file_path:)
      return failure('File path không được để trống') if file_path.blank?
      return failure('File không tồn tại') unless File.exist?(file_path)

      file_extension = File.extname(file_path).downcase
      return failure('Vui lòng chọn file Excel để import') unless ALLOWED_FILE_EXTENSIONS.include?(file_extension)

      success(file_path: file_path)
    end

    def open_spreadsheet(file_path:)
      spreadsheet = case File.extname(file_path).downcase
                    when '.xlsx' then Roo::Excelx.new(file_path)
                    when '.xls' then Roo::Excel.new(file_path)
                    end

      success(file_path: file_path, spreadsheet: spreadsheet)
    rescue StandardError => e
      failure("Không thể mở file: #{e.message}")
    end

    def validate_headers(file_path:, spreadsheet:)
      headers = spreadsheet.row(1)
      missing_headers = REQUIRED_HEADERS - headers

      return failure("Thiếu các cột bắt buộc: #{missing_headers.join(', ')}") unless missing_headers.empty?

      header_indices = {}
      headers.each_with_index do |header, index|
        header_indices[header] = index
      end

      success(
        file_path: file_path,
        spreadsheet: spreadsheet,
        header_indices: header_indices
      )
    end

    def process_rows(file_path:, spreadsheet:, header_indices:)
      errors = []
      imported_count = 0

      ActiveRecord::Base.transaction do
        (2..spreadsheet.last_row).each do |row_number|
          row = spreadsheet.row(row_number)
          next if row.compact.empty?

          result = import_single_student(row, row_number, header_indices)

          if result[:success]
            imported_count += 1
          else
            errors << result[:error]
          end
        end
        raise ActiveRecord::Rollback if errors.any?
      end

      if errors.any?
        failure('Import thất bại', errors)
      else
        success(
          file_path: file_path,
          imported_count: imported_count,
          errors: errors
        )
      end
    end

    def create_success_result(file_path:, imported_count:)
      success(
        message: "Import thành công #{imported_count} sinh viên",
        imported_count: imported_count,
        file_path: file_path
      )
    end

    def import_single_student(row, row_number, header_indices)
      student_data = extract_student_data(row, header_indices)

      if student_data[:code].blank? || student_data[:full_name].blank? || student_data[:id_card_number].blank?
        return { success: false, error: "Dòng #{row_number}: Thiếu thông tin bắt buộc" }
      end

      # Check for existing student
      if Student.exists?(code: student_data[:code])
        return { success: false, error: "Dòng #{row_number}: Sinh viên với mã #{student_data[:code]} đã tồn tại" }
      end

      # Create student
      student = Student.new(student_data)
      unless student.valid?
        return { success: false, error: "Dòng #{row_number}: #{student.errors.full_messages.join(', ')}" }
      end

      student.save!

      admin_user = AdminUser.new(
        email: student.email,
        password: 'password123',
        password_confirmation: 'password123',
        user_type: 'student',
        student_id: student.id,
        full_name: student.full_name
      )

      unless admin_user.valid?
        return { success: false,
                 error: "Dòng #{row_number}: Lỗi tạo tài khoản - #{admin_user.errors.full_messages.join(', ')}" }
      end

      admin_user.save!

      { success: true, student: student, admin_user: admin_user }
    rescue StandardError => e
      { success: false, error: "Dòng #{row_number}: #{e.message}" }
    end

    def extract_student_data(row, header_indices)
      code = row[header_indices['Mã Số Sinh Viên']]
      {
        code: code,
        full_name: row[header_indices['Họ Và Tên']],
        id_card_number: row[header_indices['Số CCCD']],
        email: "#{code}@actvn.edu.vn"
      }
    end
  end
end
