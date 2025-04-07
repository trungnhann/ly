Rails.application.config.to_prepare do
  # ✅ PATCH ActiveStorage::Attachment
  ActiveStorage::Attachment.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      [] # chặn filter attachment
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end
  end

  ActiveStorage::Blob.class_eval do
    def self.ransackable_attributes(_auth_object = nil)
      [] # cũng chặn filter blob (tên file, content_type,...)
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end
  end
end
