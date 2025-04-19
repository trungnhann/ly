Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    if Rails.env.development?
      origins 'http://localhost:4000', 'http://localhost:3000'
    else
      origins '*'
    end

    resource '*',
             headers: :any,
             methods: :any,
             expose: %w[Authorization X-CSRF-Token],
             credentials: true
  end
end
