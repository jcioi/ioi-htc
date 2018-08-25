require 'digest/sha2'
require 'json'

require 'hako/scripts/nginx_front'

module Hako
  module Scripts
    class IoiNginx < NginxFront
      HEALTH_CHECK_LABEL = 'net.ioi18.hako.health-check-path'.freeze
      DEFAULT_HEALTH_CHECK_PATH = '/site/sha'.freeze

      def deploy_starting(containers)
        super
        app = containers.fetch('app')
        configure_health_check_path(app)

        front = containers.fetch('front')
        front.docker_labels['net.ioi18.nginx-config-hash'] = Digest::SHA2.hexdigest(
                                             JSON.dump(@options.merge(_templates: Generator.templates_shasum)))
      end

      private

      def configure(*)
        super
        @options['client_max_body_size'] ||= '100m'
      end

      def configure_health_check_path(app)
        # Disable https_type redirect
        health_check_path = app.docker_labels.fetch(HEALTH_CHECK_LABEL, DEFAULT_HEALTH_CHECK_PATH)
        return if @options['locations'].key?(health_check_path)
        https_type = @options['locations']['/']['https_type']
        if https_type == 'always'
          https_type = 'public'
        end
        @options['locations'][health_check_path] = @options['locations']['/'].merge(
          'https_type' => https_type,
          'use_omniauth' => false,
          'basic_auth' => nil,
          'proxy_connect_timeout' => '5s',
          'proxy_send_timeout' => '20s',
          'proxy_read_timeout' => '20s',
        )
      end

      def generate_config(backend_host:)
        Generator.new(@options, backend_host: backend_host).render
      end

      class Generator < NginxFront::Generator
        def self.templates_shasum
          [nginx_conf_erb, nginx_location_conf_erb].map do |path|
            Digest::SHA256.file(path).hexdigest
          end
        end

        def self.templates_directory
          File.expand_path('../../templates', __FILE__)
        end

        # @return [String]
        def nginx_conf_erb; self.class.nginx_conf_erb; end
        def nginx_location_conf_erb; self.class.nginx_location_conf_erb; end

        # @return [String]
        def self.nginx_conf_erb
          File.join(templates_directory, 'nginx.conf.erb')
        end

        # @return [String]
        def self.nginx_location_conf_erb
          File.join(templates_directory, 'nginx.location.conf.erb')
        end

        def locations
          unless defined?(@locations)
            @locations = {}
            @options.fetch('locations', {}).each do |k, loc|
              @locations[k] = Location.new(loc)
            end
          end
          @locations
        end

        def location_uses_omniauth?
          locations.each_value.any?(&:use_omniauth?)
        end

        class Location < NginxFront::Generator::Location
          DEFAULT_PROXY_PASS = 'http://backend_server'
          DEFAULT_PROXY_SET_HEADER = {
            'X-Forwarded-Proto' => '$request_proto',
            'X-Forwarded-Port' => '',
            'Connection' => '',
            'Host' => '$http_host',
          }

          def raw
            @config.fetch('raw', nil)
          end

          def root
            @config.fetch('root', nil)
          end

          def try_files
            @config.fetch('try_files', nil)
          end

          def https_type
            @config.fetch('https_type', nil)
          end

          def use_omniauth?
            @config.fetch('use_omniauth', false)
          end

          def omniauth_except_internal?
            @config.fetch('omniauth_except_internal', true)
          end

          def proxy_connect_timeout
            @config.fetch('proxy_connect_timeout', '5s')
          end

          def proxy_send_timeout
            @config.fetch('proxy_send_timeout', '60s')
          end

          def proxy_read_timeout
            @config.fetch('proxy_read_timeout', '60s')
          end

          def proxy_set_header
            DEFAULT_PROXY_SET_HEADER.merge(@config.fetch('proxy_set_header', {}))
          end

          def proxy_pass
            @config.fetch('proxy_pass', DEFAULT_PROXY_PASS)
          end

          def add_header
            @config.fetch('add_header', {})
          end
        end
      end
    end
  end
end

