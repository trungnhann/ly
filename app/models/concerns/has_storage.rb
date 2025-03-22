module HasStorage
  extend ActiveSupport::Concern

  included do
    class_attribute :storage_service
    self.storage_service = Storage::LocalStorageService.new
  end

  def upload_file(file, path)
    self.class.storage_service.upload(file, path)
  end

  def download_file(path)
    self.class.storage_service.download(path)
  end

  def delete_file(path)
    self.class.storage_service.delete(path)
  end

  def file_url(path)
    self.class.storage_service.url(path)
  end
end
