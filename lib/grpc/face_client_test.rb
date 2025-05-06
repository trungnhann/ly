require 'grpc'
require_relative 'face_pb'
require_relative 'face_services_pb'

module FaceRecognition
  class ClientTester
    def initialize(host: 'localhost:50051')
      @stub = FaceRecognition::FaceRecognition::Stub.new(host, :this_channel_is_insecure)
    end

    # Test đăng ký khuôn mặt
    def test_register_face(student_id, image_path)
      image_data = File.binread(image_path)
      request = RegisterRequest.new(
        student_id: student_id,
        image_base64: Base64.strict_encode64(image_data)
      )

      response = @stub.register_face(request)
      puts "Register Response: #{response.inspect}"
    rescue GRPC::BadStatus => e
      puts "Register Error: #{e.message}"
    end

    # Test nhận diện khuôn mặt
    def test_identify_face(image_path)
      image_data = File.binread(image_path)
      request = IdentifyRequest.new(
        image_base64: Base64.strict_encode64(image_data)
      )

      response = @stub.identify_face(request)
      puts "Identify Response: #{response.inspect}"
    rescue GRPC::BadStatus => e
      puts "Identify Error: #{e.message}"
    end
  end
end

# Hướng dẫn sử dụng:
# client = FaceRecognition::ClientTester.new
# client.test_register_face('SV001', 'path/to/image.jpg')
# client.test_identify_face('path/to/test_image.jpg')
