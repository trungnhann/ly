module FptAi
  class IdCardVerifyService
    prepend ServiceModule::Base

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

    def call(image_file:)
      @config = ServiceConfig.fpt

      run :validate_image
      run :scan_id_card
      run :format_id_card_data
    end

    private

    def validate_image(image_file:)
      return failure('Invalid image file') unless valid_file?(image_file)

      success(image_file:)
    end

    def valid_file?(file)
      return false if file.blank?
      return false unless file.respond_to?(:read)
      return false unless file.respond_to?(:content_type)

      true
    end

    def scan_id_card(image_file:)
      options = {
        headers: {
          'api-key' => @config[:api_key],
          'Content-Type' => 'multipart/form-data'
        },
        multipart: true,
        body: {
          image: File.open(image_file.tempfile)
        }
      }

      Rails.logger.info "Sending request to FPT API with options: #{options.inspect}"

      begin
        response = self.class.post('/', options)
        data = response.parsed_response
        Rails.logger.info "FPT API Response: #{data.inspect}"

        if data['errorCode'] != 0
          error_message = ERROR_MESSAGES[data['errorCode']] || 'Lỗi không xác định từ FPT API'
          return failure(error_message, { error_code: data['errorCode'] })
        end

        success(image_file: image_file, id_card_data: data['data'])
      rescue HTTParty::Error => e
        handle_api_error(e)
      rescue StandardError => e
        Rails.logger.error "Unexpected error: #{e.message}"
        failure("Lỗi không xác định: #{e.message}")
      end
    end

    def handle_api_error(error)
      data = error.response.parsed_response
      error_message = ERROR_MESSAGES[data['errorCode']] || "Lỗi từ FPT API: #{data['errorMessage']}"
      failure(error_message, { error_code: data['errorCode'] })
    rescue StandardError
      failure("Lỗi kết nối đến FPT API: #{error.message}")
    end

    def format_id_card_data(image_file:, id_card_data:)
      return failure('Không có dữ liệu CCCD') if id_card_data.blank?

      id_card = id_card_data.first
      return failure('Dữ liệu CCCD không hợp lệ') if id_card.blank?

      formatted_data = {
        number: id_card['id'],
        full_name: id_card['name'],
        date_of_birth: parse_date(id_card['dob']),
        gender: id_card['sex'] == 'NAM' ? 'male' : 'female',
        nationality: id_card['nationality'],
        hometown: id_card['home'],
        address: id_card['address'],
        issue_date: parse_date(id_card['doe']),
        issue_place: id_card['address_entities']&.dig('province'),
        expiry_date: parse_date(id_card['doe'])
      }

      success(id_card_data: formatted_data)
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
end
