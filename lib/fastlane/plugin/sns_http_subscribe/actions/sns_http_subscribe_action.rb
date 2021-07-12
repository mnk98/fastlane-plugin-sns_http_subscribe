require 'aws-sdk-sns'
require 'fastlane/action'
require_relative '../helper/sns_http_subscribe_helper'

module Fastlane
  module Actions
    class SnsHttpSubscribeAction < Action
      def self.run(params)
        client = Aws::SNS::Client.new(
          region: params[:aws_region]
        )
        next_token = nil
        i = 0
        topic_arn = params[:topic_arn]
        endpoint_url = params[:endpoint_url]
        uri = URI.parse(endpoint_url)
        if uri.scheme == "https"
          protocol = "https"
        else
          protocol = "http"
        end

        UI.message( "Checking if Subscription already exist")
       
        loop do 
          subscriptions = client.list_subscriptions_by_topic({
            topic_arn: topic_arn,
            next_token:next_token
          })
          next_token = subscriptions.next_token

          subscriptions.subscriptions.each do |s|
            i = i + 1
            begin
             if s.endpoint.include? endpoint_url
              UI.message( "Subscription already exist for #{endpoint_url}")
              return
             end
            rescue
            UI.message( "Not a valid Subscription or something went wrong!")
           end
            
          end

          break if next_token == nil
        end 

        UI.message( "Subscription does not exist, creating new")

        attributes = {}
        if params[:filter_policy]
          attributes = {
            "FilterPolicy" => params[:filter_policy],
          }
        end

        begin
          resp = client.subscribe({
            topic_arn: topic_arn, # required
            protocol: protocol,
            endpoint: endpoint_url,
            attributes: attributes
          })  
          UI.success("☝️  created subscription #{endpoint_url} on topic #{topic_arn}")
       rescue
        UI.user_error!("Error while creating subscription #{endpoint_url} on topic #{topic_arn}")
       end

      end

      def self.description
        "Subscribe to sns topic using http/https endpoint"
      end

      def self.authors
        ["mnk98"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Subscribe to sns topic using http/https endpoint"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :aws_region,
                                  env_name: "AWS_REGION",
                               description: "AWS region",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :topic_arn,
                                  env_name: "TOPIC_ARN",
                               description: "AWS sns topic arn",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :endpoint_url,
                                 env_name: "ENDPOINT_URL",
                               description: "AWS sns endpoint url",
                                    optional: false,
                                      type: String),
            FastlaneCore::ConfigItem.new(key: :filter_policy,
                                env_name: "FILTER_POLICY",
                              description: "AWS sns filter policy",
                                    optional: true,
                                      type: String)
          
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
