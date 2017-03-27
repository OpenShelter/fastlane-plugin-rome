module Fastlane
  module Actions
    class RomeAction < Action
      def self.run(params)
        validate(params)

        cmd = ["rome"]
        command_name = params[:command]
        
        if command_name == "version"
          cmd << "--version"
        else
          cmd << command_name
        end

        if (command_name == "upload" || command_name == "download") && params[:frameworks].count > 0
          cmd.concat params[:frameworks]
        elsif command_name == "list"
          cmd << "--missing" if params[:missing] == true
        end

        cmd << "--platform #{params[:platform]}" if params[:platform]
        cmd << "-v " if params[:verbose]      

        Actions.sh(cmd.join(' '))
      end

      def self.validate(params)
        command_name = params[:command]
        if !(command_name == "upload" || command_name == "download")  && params[:frameworks].count > 0
          UI.user_error!("Frameworks option is available only for 'upload'' or 'download' commands.")
        end
        if command_name != "list" && params[:missing]
          UI.user_error!("Missing option is available only for 'list' command.")
        end
      end

      def self.available_commands
        %w(list download upload version)
      end

      def self.available_platforms
        %w(all iOS Mac tvOS watchOS)
      end

      def self.description
        "An S3 cache tool for Carthage"
      end

      def self.authors
        ["François Benaiteau"]
      end

      def self.details
        "Rome is a tool that allows developers on Apple platforms to use Amazon's S3 as a shared cache for frameworks built with Carthage."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: "FL_ROME_COMMAND",
                                       description: "Rome command (one of: #{available_commands.join(', ')})",
                                       default_value: "download",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid command. Use one of the following: #{available_commands.join(', ')}") unless available_commands.include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_ROME_VERBOSE",
                                       description: "Print xcodebuild output inline",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for verbose. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_ROME_PLATFORM",
                                       description: "Define which platform to build for",
                                       optional: true,
                                       verify_block: proc do |value|
                                         value.split(',').each do |platform|
                                           UI.user_error!("Please pass a valid platform. Use one of the following: #{available_platforms.join(', ')}") unless available_platforms.map(&:downcase).include?(platform.downcase)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :missing,
                                       env_name: "FL_ROME_MISSING",
                                       description: "Option to list only missing frameworks",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for missing. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),

          FastlaneCore::ConfigItem.new(key: :frameworks,
                                       description: "Framework name or names to upload/download, could be applied only along with the 'upload' or 'download' commands",
                                       default_value: [],
                                       is_string: false,
                                       type: Array),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        [:ios, :mac].include?(platform)
      end
    end
  end
end
