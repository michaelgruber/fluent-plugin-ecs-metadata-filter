module FluentECS
  module Resource
    def self.included(base)
      base.include HTTParty
      base.base_uri 'http://localhost:51678/v1'
      base.format :json

      base.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :resource_endpoint

      def get
        response = super(resource_endpoint)
        if response.success?
          response.parsed_response
        else
          err = "GET #{base_uri}#{resource_endpoint}" \
                " failed with code: #{response.code}"
          raise RequestError, err
        end
      rescue Errno::ECONNREFUSED, HTTParty::Error, Timeout::Error => e
        raise IntrospectError, e.message
      end
    end
  end
end
