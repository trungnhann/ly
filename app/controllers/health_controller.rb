class HealthController < ApplicationController
  def check
    db_status = check_database_connection
    mongo_status = check_mongo_connection

    render json: {
      status: db_status[:connected] && mongo_status[:connected] ? 'OK' : 'ERROR',
      environment: Rails.env,
      version: '1.0.0',
      postgres_database: {
        status: db_status[:connected] ? 'Connected' : 'Disconnected',
        message: db_status[:message]
      },
      mongodb: {
        status: mongo_status[:connected] ? 'Connected' : 'Disconnected',
        message: mongo_status[:message]
      }
    }, status: db_status[:connected] && mongo_status[:connected] ? :ok : :service_unavailable
  end

  private

  def check_database_connection
    ActiveRecord::Base.connection.execute('SELECT 1')
    {
      connected: true,
      message: 'Database connection successful'
    }
  rescue StandardError => e
    {
      connected: false,
      message: "Database connection failed: #{e.message}"
    }
  end

  def check_mongo_connection
    uri = Rails.application.credentials.dig(Rails.env.to_sym, :mongodb_uri) || ENV.fetch('MONGODB_URI', nil)
    options = {
      server_selection_timeout: 5,
      connect_timeout: 5,
      socket_timeout: 5,
      max_pool_size: 5,
      min_pool_size: 1
    }

    begin
      if uri.nil?
        return {
          connected: false,
          message: 'MongoDB URI is missing'
        }
      end

      client = Mongo::Client.new(uri, options)
      client.database.command(ping: 1)
      {
        connected: true,
        message: 'MongoDB connection successful'
      }
    rescue StandardError => e
      {
        connected: false,
        message: "MongoDB connection failed: #{e.message}"
      }
    end
  end
end
