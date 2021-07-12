require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SnsHttpSubscribeHelper
      # class methods that you define here become available in your action
      # as `Helper::SnsHttpSubscribeHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the sns_http_subscribe plugin helper!")
      end
    end
  end
end
