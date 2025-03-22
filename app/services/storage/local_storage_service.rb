module Storage
  class LocalStorageService < BaseStorageService
    def upload(_file, path)
      # TODO: Implement local storage upload
      # Tạm thời chỉ lưu đường dẫn
      path
    end

    def download(path)
      # TODO: Implement local storage download
      File.read(path) if File.exist?(path)
    end

    def delete(path)
      # TODO: Implement local storage delete
      FileUtils.rm_f(path)
    end

    def url(path)
      # TODO: Implement local storage url
      "/uploads/#{path}"
    end
  end
end
