require 'oauth2'
require 'mautic/engine'

module Mautic
  include ::ActiveSupport::Configurable

  autoload :FormHelper, 'mautic/form_helper'
  autoload :Proxy, 'mautic/proxy'
  autoload :RedisConnector, 'mautic/redis_connector'
  autoload :Model, 'mautic/model'
  autoload :Submissions, 'mautic/submissions'

  class RequestError < StandardError

    attr_reader :response, :errors

    def initialize(response, message = nil, request = [])
      @errors ||= []
      @response = response
      json_body = JSON.parse(response.body) rescue {}
      message ||= Array(json_body['errors']).collect do |error|
        msg = error['code'].to_s
        msg << " (#{error['type']}):" if error['type']
        msg << " #{error['message']}"
        @errors << error['message']
        msg
      end.join(', ')
      message += request.join(', ')
      super(message)
    end

  end

  class TokenExpiredError < RequestError
  end

  class ValidationError < RequestError

    def initialize(response, message = nil)
      @response = response
      json_body = JSON.parse(response.body) rescue {}
      @errors = Array(json_body['errors']).each_with_object({}) do |var, mem|
        mem.merge!(var['details'])
      end
      message ||= @errors.collect { |field, msg| "#{field}: #{msg.join(', ')}" }.join('; ')
      super(response, message)
    end

  end

  class AuthorizeError < RequestError
  end

  class RecordNotFound < RequestError
  end

  configure do |config|
    # Mautic URL
    config.mautic_url = 'https://mautic.my.app'
    # Public Key
    config.public_key = 'public_key'
    # Secret Key
    config.secret_key = 'secret_key'
    # Redis Connection Config
    config.redis_config = { url: 'redis://127.0.0.1:6379' }
  end
end
