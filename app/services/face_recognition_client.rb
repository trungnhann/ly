#!/usr/bin/env ruby

require 'grpc'
require 'base64'
require_relative 'lib/grpc/face_pb'
require_relative 'lib/grpc/face_services_pb'

class FaceRecognitionClient
  def initialize(host = 'localhost:50051')
    @stub = FaceRecognition::FaceRecognition::Stub.new(host, :this_channel_is_insecure)
  end

  def register_face(student_id, image_path)
    begin
      image_data = File.read(image_path)
      image_base64 = Base64.strict_encode64(image_data)
    rescue StandardError => e
      puts "Error reading image file: #{e.message}"
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
      puts "gRPC error: #{e.message}"
      { success: false, message: e.message }
    end
  end

  # Nhận diện khuôn mặt từ ảnh
  def identify_face(image_path)
    # Đọc và mã hóa file ảnh thành base64
    begin
      image_data = File.read(image_path)
      image_base64 = Base64.strict_encode64(image_data)
    rescue StandardError => e
      puts "Error reading image file: #{e.message}"
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
      puts "gRPC error: #{e.message}"
      { success: false, message: e.message }
    end
  end

  # Phiên bản sử dụng data ảnh trực tiếp thay vì file path
  def identify_face_from_data(image_data)
    # Mã hóa dữ liệu ảnh thành base64
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
      puts "gRPC error: #{e.message}"
      { success: false, message: e.message }
    end
  end

  # Phiên bản đăng ký khuôn mặt sử dụng data ảnh trực tiếp
  def register_face_from_data(student_id, image_data)
    # Mã hóa dữ liệu ảnh thành base64
    image_base64 = Base64.strict_encode64(image_data)

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
      puts "gRPC error: #{e.message}"
      { success: false, message: e.message }
    end
  end
end

# Ví dụ sử dụng
if __FILE__ == $PROGRAM_NAME
  client = FaceRecognitionClient.new

  # Kiểm tra tham số dòng lệnh
  case ARGV[0]
  when 'register'
    if ARGV.length < 3
      puts 'Sử dụng: ruby face_recognition_client.rb register STUDENT_ID IMAGE_PATH'
      exit 1
    end
    result = client.register_face(ARGV[1], ARGV[2])
    if result[:success]
      puts "Đăng ký thành công: #{result[:message]}"
    else
      puts "Đăng ký thất bại: #{result[:message]}"
    end
  when 'identify'
    if ARGV.length < 2
      puts 'Sử dụng: ruby face_recognition_client.rb identify IMAGE_PATH'
      exit 1
    end
    result = client.identify_face(ARGV[1])
    if result[:success]
      puts 'Nhận diện thành công!'
      puts "Student ID: #{result[:student_id]}"
      puts "Độ tin cậy: #{result[:confidence]}"
    else
      puts "Nhận diện thất bại: #{result[:message]}"
    end
  else
    puts 'Hướng dẫn sử dụng:'
    puts '  ruby face_recognition_client.rb register STUDENT_ID IMAGE_PATH'
    puts '  ruby face_recognition_client.rb identify IMAGE_PATH'
    exit 1
  end
end
