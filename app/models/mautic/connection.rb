module Mautic
  class Connection
    attr_accessor :base_url, :mautic_url, :public_key, :secret_key, :token,
                  :refresh_token, :redis_connector

    def initialize(args = {})
      @base_url = args[:base_url] if args.present?

      @redis_connector = RedisConnector.new
      @token = @redis_connector.token
      @refresh_token = @redis_connector.refresh_token

      @mautic_url = Mautic.config.mautic_url
      @public_key = Mautic.config.public_key
      @secret_key = Mautic.config.secret_key
    end

    # @param [ActionController::Parameters] params
    def self.receive_webhook(params)
      WebHook.new(find(params.require(:mautic_id)), params)
    end

    def client
      @client ||= OAuth2::Client.new(
        @public_key,
        @secret_key,
        site: @mautic_url,
        authorize_url: 'oauth/v2/authorize',
        token_url: 'oauth/v2/token',
        raise_errors: false
      )
    end

    def authorize
      client.auth_code.authorize_url(redirect_uri: callback_url)
    end

    def get_code(code)
      response = client.auth_code.get_token(code, redirect_uri: callback_url)

      return response unless response.params['errors']

      raise response.params['errors'][0]['message']
    end

    def connection
      @connection ||= OAuth2::AccessToken.new(client,
                                              @token,
                                              refresh_token: @refresh_token)
    end

    def refresh!
      @connection = connection.refresh!
      @redis_connector.token = @connection.token
      @redis_connector.refresh_token = @connection.refresh_token
      @connection
    end

    %w[assets campaigns categories companies emails forms messages
       notes notifications pages points roles stats users].each do |entity|
      define_method entity do
        Proxy.new(self, entity)
      end
    end

    def contacts
      Proxy.new(self, 'contacts', default_params: { search: '!is:anonymous' })
    end

    def tags
      Proxy.new(self, 'tags')
    end

    def activities
      Proxy.new(self, 'activities')
    end

    def request(type, path, params = {})
      @last_request = [type, path, params]
      response = connection.request(type, path, params)
      parse_response(response)
    end

    def update(attributes)
      @redis_connector.token = attributes[:token]
      @redis_connector.refresh_token = attributes[:refresh_token]
    end

    private

    def callback_url
      "#{@base_url}#{Mautic::Engine.routes.url_helpers.oauth2_path}"
    end

    def parse_response(response)
      case response.status
      when 400
        raise Mautic::ValidationError.new(response)
      when 404
        raise Mautic::RecordNotFound.new(response)
      when 401
        raise Mautic::AuthorizeError.new(response, nil, @last_request) if @try_to_refresh
        @try_to_refresh = true
        refresh!
        json = request(*@last_request)
      when 200, 201
        json = JSON.parse(response.body) rescue {}
      else
        raise Mautic::RequestError.new(response, nil, @last_request)
      end

      json
    end
  end
end
