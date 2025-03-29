module ServiceConfig
  class << self
    def fpt
      {
        base_uri: Rails.application.credentials.dig(:fpt, :base_uri),
        api_key: Rails.application.credentials.dig(:fpt, :api_key),
        timeout: Rails.application.credentials.dig(:fpt, :timeout)
      }
    end
  end
end
