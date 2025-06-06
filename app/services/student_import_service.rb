require 'roo'

class StudentImportService
  REQUIRED_HEADERS = [
    'Mã Số Sinh Viên',
    'Họ Và Tên',
    'Số CCCD'
  ].freeze

  def initialize(file_path)
    @file_path = file_path
    @errors = []
  end

  def import
    ActiveRecord::Base.transaction do
      spreadsheet = open_spreadsheet
      validate_headers(spreadsheet)

      # Bỏ qua hàng header
      (2..spreadsheet.last_row).each do |i|
        row = spreadsheet.row(i)
        next if row.compact.empty? # Bỏ qua hàng trống

        student_data = {
          code: row[header_index('Mã Số Sinh Viên')],
          full_name: row[header_index('Họ Và Tên')],
          id_card_number: row[header_index('Số CCCD')],
          email: "#{row[header_index('Mã Số Sinh Viên')]}@actvn.edu.vn"
        }

        import_student!(student_data, i)
      end

      raise ActiveRecord::Rollback, 'Có lỗi xảy ra trong quá trình import' if @errors.any?
    end

    if @errors.any?
      { success: false, message: 'Import thất bại', errors: @errors }
    else
      { success: true, message: 'Import thành công' }
    end
  rescue StandardError
    { success: false, message: 'Import thất bại', errors: @errors }
  end

  private

  def open_spreadsheet
    case File.extname(@file_path).downcase
    when '.xlsx' then Roo::Excelx.new(@file_path)
    when '.xls' then Roo::Excel.new(@file_path)
    else raise "Định dạng file không được hỗ trợ: #{File.extname(@file_path)}"
    end
  end

  def validate_headers(spreadsheet)
    headers = spreadsheet.row(1)
    missing_headers = REQUIRED_HEADERS - headers

    raise "Thiếu các cột bắt buộc: #{missing_headers.join(', ')}" unless missing_headers.empty?

    @header_indices = {}
    headers.each_with_index do |header, index|
      @header_indices[header] = index
    end
  end

  def header_index(header_name)
    @header_indices[header_name]
  end

  def import_student!(student_data, row_number)
    if student_data[:code].blank? || student_data[:full_name].blank? || student_data[:id_card_number].blank?
      @errors << "Dòng #{row_number}: Thiếu thông tin bắt buộc"
      raise "Dòng #{row_number}: Thiếu thông tin bắt buộc"
    end

    existing_student = Student.find_by(code: student_data[:code])
    if existing_student
      @errors << "Dòng #{row_number}: Sinh viên với mã #{student_data[:code]} đã tồn tại"
      raise "Dòng #{row_number}: Sinh viên với mã #{student_data[:code]} đã tồn tại"
    end

    student = Student.new(student_data)

    unless student.valid?
      @errors << "Dòng #{row_number}: #{student.errors.full_messages.join(', ')}"
      raise "Dòng #{row_number}: #{student.errors.full_messages.join(', ')}"
    end

    student.save!

    AdminUser.create!(
      email: student.email,
      password: 'password123',
      password_confirmation: 'password123',
      user_type: 'student',
      student_id: student.id,
      full_name: student.full_name
    )
  end
end
