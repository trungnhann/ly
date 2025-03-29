class FptIdCardService < BaseService
  include HTTParty
  base_uri ServiceConfig.fpt[:base_uri]
  default_timeout ServiceConfig.fpt[:timeout]

  ERROR_MESSAGES = {
    1 => 'Tham số không hợp lệ hoặc thiếu thông tin (ví dụ: thiếu key hoặc image trong request body)',
    2 => 'Không thể cắt ảnh - CCCD trong ảnh thiếu góc nên không thể cắt theo định dạng chuẩn',
    3 => 'Không tìm thấy CCCD trong ảnh hoặc chất lượng ảnh kém (quá mờ, quá tối/sáng)',
    5 => 'Không có URL trong request - Request sử dụng image_url nhưng giá trị trống',
    6 => 'Không thể mở URL - Request sử dụng image_url nhưng hệ thống không thể mở URL này',
    7 => 'File ảnh không hợp lệ - File tải lên không phải là file ảnh',
    8 => 'Dữ liệu xấu - File ảnh tải lên bị hỏng hoặc định dạng không được hỗ trợ',
    9 => 'Không có chuỗi base64 trong request - Request sử dụng image_base64 nhưng giá trị trống',
    10 => 'Chuỗi base64 không hợp lệ - Request sử dụng image_base64 nhưng chuỗi không hợp lệ'
  }.freeze

  def initialize(image_file)
    @image_file = image_file
    @config = ServiceConfig.fpt
  end

  def call
    validate_image
    scan_id_card
  end

  private

  def validate_image
    raise ServiceError, 'Invalid image file' unless validate_file(@image_file)
  end

  def validate_file(file)
    return false if file.blank?
    return false unless file.respond_to?(:read)
    return false unless file.respond_to?(:content_type)

    true
  end

  def scan_id_card
    options = {
      headers: {
        'api-key' => @config[:api_key],
        'Content-Type' => 'multipart/form-data'
      },
      multipart: true,
      body: {
        image: File.open(@image_file.tempfile)
      }
    }

    Rails.logger.info "Sending request to FPT API with options: #{options.inspect}"

    begin
      response = self.class.post('/', options)
      handle_response(response)
    rescue HTTParty::Error => e
      Rails.logger.error "FPT API Error: #{e.message}"
      handle_error(e)
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.message}"
      raise FptIdCardError, "Lỗi không xác định: #{e.message}"
    end
  end

  def handle_response(response)
    data = response.parsed_response
    Rails.logger.info "FPT API Response: #{data.inspect}"

    if data['errorCode'] != 0
      error_message = ERROR_MESSAGES[data['errorCode']] || 'Lỗi không xác định từ FPT API'
      raise FptIdCardError.new(error_message, data['errorCode'])
    end

    format_id_card_data(data['data'])
  end

  def handle_error(error)
    data = error.response.parsed_response
    error_message = ERROR_MESSAGES[data['errorCode']] || "Lỗi từ FPT API: #{data['errorMessage']}"
    raise FptIdCardError.new(error_message, data['errorCode'])
  rescue StandardError
    raise FptIdCardError, "Lỗi kết nối đến FPT API: #{error.message}"
  end

  def format_id_card_data(data)
    return {} if data.blank?

    id_card_data = data.first
    return {} if id_card_data.blank?

    {
      id_card: {
        number: id_card_data['id'],
        full_name: id_card_data['name'],
        date_of_birth: parse_date(id_card_data['dob']),
        gender: id_card_data['sex'] == 'NAM' ? 'male' : 'female',
        nationality: id_card_data['nationality'],
        hometown: id_card_data['home'],
        address: id_card_data['address'],
        issue_date: parse_date(id_card_data['doe']),
        issue_place: id_card_data['address_entities']['province'],
        expiry_date: parse_date(id_card_data['doe'])
      }
    }
  end

  def parse_date(date_string)
    return nil if date_string.blank?

    begin
      if date_string.include?('/')
        day, month, year = date_string.split('/')
      elsif date_string.include?('-')
        year, month, day = date_string.split('-')
      else
        return nil
      end

      year = year.to_i
      month = month.to_i
      day = day.to_i

      return nil if year < 1900 || year > 2100
      return nil if month < 1 || month > 12
      return nil if day < 1 || day > 31

      Date.new(year, month, day)
    rescue StandardError => e
      Rails.logger.error "Error parsing date: #{date_string} - #{e.message}"
      nil
    end
  end
end
