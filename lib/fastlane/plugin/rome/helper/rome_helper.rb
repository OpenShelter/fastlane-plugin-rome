module Fastlane
  module Helper
    class RomeHelper
      # class methods that you define here become available in your action
      # as `Helper::RomeHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the rome plugin helper!")
      end
    end
  end
end
