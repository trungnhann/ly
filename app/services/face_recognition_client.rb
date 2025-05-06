require 'base64'
require Rails.root.join('lib/grpc/face_pb')
require Rails.root.join('lib/grpc/face_services_pb')

class FaceRecognitionClient
  def initialize(host = 'localhost:50051')
    @stub = FaceRecognition::FaceRecognition::Stub.new(host, :this_channel_is_insecure)
  end

  def register_face(student_id, image_path)
    begin
      image_data = File.read(image_path)
      image_base64 = Base64.strict_encode64(image_data)
    rescue StandardError => e
      Rails.logger.error("Error reading image file: #{e.message}")
      return { success: false, message: e.message }
    end

    # Tạo request
    request = FaceRecognition::RegisterRequest.new(
      student_id: student_id,
      image_base64: image_base64
    )

    # Gửi request
    begin
      response = @stub.register_face(request)
      {
        success: response.success,
        message: response.message
      }
    rescue GRPC::BadStatus => e
      Rails.logger.error("gRPC error: #{e.message}")
      { success: false, message: e.message }
    end
  end

  def register_face_from_data(student_id, image_data)
    image_base64 = Base64.strict_encode64(image_data)

    request = FaceRecognition::RegisterRequest.new(
      student_id: student_id,
      image_base64: image_base64
    )

    begin
      response = @stub.register_face(request)
      {
        success: response.success,
        message: response.message
      }
    rescue GRPC::BadStatus => e
      Rails.logger.error("gRPC error: #{e.message}")
      { success: false, message: e.message }
    end
  end

  def identify_face(image_path)
    # Đọc và mã hóa file ảnh thành base64
    begin
      image_data = File.read(image_path)
      image_base64 = Base64.strict_encode64(image_data)
    rescue StandardError => e
      Rails.logger.error("Error reading image file: #{e.message}")
      return { success: false, message: e.message }
    end

    # Tạo request
    request = FaceRecognition::IdentifyRequest.new(
      image_base64: image_base64
    )

    # Gửi request
    begin
      response = @stub.identify_face(request)
      {
        success: response.success,
        student_id: response.student_id,
        confidence: response.confidence,
        message: response.message
      }
    rescue GRPC::BadStatus => e
      Rails.logger.error("gRPC error: #{e.message}")
      { success: false, message: e.message }
    end
  end

  def identify_face_from_data(image_data)
    image_base64 = Base64.strict_encode64(image_data)

    # Tạo request
    request = FaceRecognition::IdentifyRequest.new(
      image_base64: image_base64
    )

    # Gửi request
    begin
      response = @stub.identify_face(request)
      {
        success: response.success,
        student_id: response.student_id,
        confidence: response.confidence,
        message: response.message
      }
    rescue GRPC::BadStatus => e
      Rails.logger.error("gRPC error: #{e.message}")
      { success: false, message: e.message }
    end
  end
end
