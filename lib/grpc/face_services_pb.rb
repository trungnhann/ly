# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: face.proto for package 'face_recognition'

require 'grpc'
require_relative 'face_pb'

module FaceRecognition
  module FaceRecognition
    class Service
      include ::GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'face_recognition.FaceRecognition'

      # Register a face with student ID
      rpc :RegisterFace, ::FaceRecognition::RegisterRequest, ::FaceRecognition::RegisterResponse
      # Identify a face and return student ID
      rpc :IdentifyFace, ::FaceRecognition::IdentifyRequest, ::FaceRecognition::IdentifyResponse
      # Delete face embedding by student ID
      rpc :DeleteFace, ::FaceRecognition::DeleteFaceRequest, ::FaceRecognition::DeleteFaceResponse
    end

    Stub = Service.rpc_stub_class
  end
end
