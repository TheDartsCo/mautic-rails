module Mautic
  # Connector for Redis
  class RedisConnector
    attr_accessor :connection, :key_prefix

    def initialize
      @connection = Redis.new(Mautic.config.redis_config)
      @key_prefix = Rails.application.class.parent_name
    end

    def token=(token)
      @connection.set("#{key_prefix}_mautic_token", token)
    end

    def token
      @connection.get("#{key_prefix}_mautic_token")
    end

    def refresh_token=(refresh_token)
      @connection.set("#{key_prefix}_mautic_refresh_token", refresh_token)
    end

    def refresh_token
      @connection.get("#{key_prefix}_mautic_refresh_token")
    end
  end
end
