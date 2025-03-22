module Storage
  class BaseStorageService
    def upload(file, path)
      raise NotImplementedError, "#{self.class} must implement upload method"
    end

    def download(path)
      raise NotImplementedError, "#{self.class} must implement download method"
    end

    def delete(path)
      raise NotImplementedError, "#{self.class} must implement delete method"
    end

    def url(path)
      raise NotImplementedError, "#{self.class} must implement url method"
    end
  end
end
