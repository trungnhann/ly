require_relative 'lib/grpc/face_pb'
require_relative 'lib/grpc/face_services_pb'

def test_grpc_connection
  begin
    # Kết nối đến service gRPC
    stub = FaceRecognition::FaceRecognition::Stub.new('localhost:50051', :this_channel_is_insecure)
    
    # In ra các phương thức có sẵn
    puts "Available methods:"
    puts FaceRecognition::FaceRecognition::Service.rpcs.keys

    # Tạo request để xóa khuôn mặt
    request = FaceRecognition::DeleteFaceRequest.new(
      student_id: "test_student"
    )

    # Gọi phương thức delete
    response = stub.delete_face(request)
    puts "Response: #{response.inspect}"
  rescue GRPC::BadStatus => e
    puts "Error: #{e.message}"
    puts "Debug error string: #{e.debug_error_string}"
  end
end

test_grpc_connection 