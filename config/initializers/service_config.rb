module ServiceConfig
  class << self
    def fpt
      {
        base_uri: 'https://api.fpt.ai/vision/idr/vnm',
        api_key: 'b3vlzpFoPCJ6pzSDHdttDHw7ScWqTrfU',
        timeout: 30
      }
    end
  end
end
