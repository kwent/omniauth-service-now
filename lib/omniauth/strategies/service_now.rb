require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ServiceNow < OmniAuth::Strategies::OAuth2

      SITE_REGEXP = /(?:https:\/\/)?(?:([^.]+)\.)?service-now\.com/

      args %i[client_id client_secret]

      option :name, 'service_now'

      option :client_options, {
        site: "https://<instance-id>.service-now.com",
        authorize_url: "/oauth_auth.do",
        token_url: "/oauth_token.do",
        response_type: 'code',
      }

      option :auth_token_params, {
        grant_type: 'authorization_code',
      }

      # When `true`, client_id and client_secret are returned in extra['raw_info'].
      option :extra_client_id_and_client_secret, false

      def authorize_params
        super.tap do |params|
          %w[client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      def build_access_token
        verifier = request.params["code"]
        # Override regular client when using setup: proc
        if env['omniauth.params']['client_id'] && env['omniauth.params']['client_secret'] && env['omniauth.params']['site']
          client = ::OAuth2::Client.new(
            env['omniauth.params']['client_id'],
            env['omniauth.params']['client_secret'],
            site: env['omniauth.params']['site'],
            authorize_url: options.client_options.authorize_url,
            token_url: options.client_options.token_url
          )
          client.auth_code.get_token(verifier, {:redirect_uri => callback_url}.merge(token_params.to_hash(:symbolize_keys => true)), deep_symbolize(options.auth_token_params))
        else
          super
        end
      end

      uid { smart_site }

      extra do
        { raw_info: raw_info, site: smart_site, instance_id: instance_id }
      end

      def raw_info
        @raw_info ||= options[:extra_client_id_and_client_secret] ? { client_id: smart_client_id, client_secret: smart_client_secret } : {}
      end

      def smart_client_id
        @smart_client_id ||= env['omniauth.params']['client_id'] || env['omniauth.strategy'].options.client_id
      end

      def smart_client_secret
        @smart_client_secret ||= env['omniauth.params']['client_secret'] || env['omniauth.strategy'].options.client_secret
      end

      def smart_site
        @site ||= env['omniauth.params']['site'] || env['omniauth.strategy'].options.site || options.client_options.site
      end

      def instance_id
        @instance_id ||= smart_site.match(SITE_REGEXP)[1] if smart_site
      end

      def callback_url
        options.redirect_url || (full_host + callback_path)
      end
    end
  end
end

OmniAuth.config.add_camelization 'service-now', 'ServiceNow'
OmniAuth.config.add_camelization 'service_now', 'ServiceNow'
OmniAuth.config.add_camelization 'servicenow', 'ServiceNow'