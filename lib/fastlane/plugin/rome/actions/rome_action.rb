module Fastlane
  module Actions
    class RomeAction < Action
      def self.run(params)
        UI.message("The rome plugin is working!")
      end

      def self.description
        "An S3 cache tool for Carthage"
      end

      def self.authors
        ["François Benaiteau"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Rome is a tool that allows developers on Apple platforms to use Amazon's S3 as a shared cache for frameworks built with Carthage."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "ROME_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
