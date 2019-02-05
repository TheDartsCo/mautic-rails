module Mautic
  class ConnectionsController < ApplicationController

    before_action :set_mautic_connection

    def authorize
      redirect_to @mautic_connection.authorize
    end

    def oauth2
      response = @mautic_connection.get_code(params.require(:code))
      @mautic_connection.update(token: response.token,
                                refresh_token: response.refresh_token)
      render plain: 'Connection authorized!'
    rescue StandardError, OAuth2::Error => e
      render status: :unauthorized, plain: e.message
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_mautic_connection
      @mautic_connection = Mautic::Connection.new(base_url: request.base_url)
    end

    # Only allow a trusted parameter "white list" through.
    def mautic_connection_params
      params.require(:connection).permit(:url, :client_id, :secret, :type)
    end

  end
end
