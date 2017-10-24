module Fastlane
  module Actions
    class RomeAction < Action
      def self.run(params)
        check_tools!
        validate(params)

        cmd = ["rome"]
        command_name = params[:command]

        if command_name == "version"
          cmd << "--version"
        elsif command_name == "help"
          cmd << "--help"
        else
          cmd << command_name
        end

        if (command_name == "upload" || command_name == "download") && params[:frameworks].count > 0
          cmd.concat params[:frameworks]
        elsif command_name == "list"
          cmd << "--missing" if params[:missing] == true
        end

        cmd << "--platform #{params[:platform]}" if params[:platform]
        cmd << "--cache-prefix #{params[:cacheprefix]}" if params[:cacheprefix]
        cmd << "--print-format #{params[:printformat]}" if params[:printformat]
        cmd << "-v " if params[:verbose]

        Actions.sh(cmd.join(' '))
      end

      def self.meet_minimum_version(minimum_version)
        version = Actions.sh('rome --version') #i.e. 0.12.0.31 - Romam uno die non fuisse conditam.
        version_number = version.split(' - ')[0]

        minimum_version_parts = minimum_version.split('.')
        version_parts = version_number.split('.')
        for i in 0..version_parts.length do
          part = version_parts[i]
          min_part = minimum_version_parts[i]
          if part.to_i < min_part.to_i
            return false
          end
        end
        return true
      end

      def self.validate(params)
        unless params
          Actions.sh("rome --help")
          exit
        end

        command_name = params[:command]
        if !(command_name == "upload" || command_name == "download") && params[:frameworks].count > 0
          UI.user_error!("Frameworks option is available only for 'upload'' or 'download' commands.")
        end
        if command_name != "list" && (params[:missing] || params [:present])
          UI.user_error!("Missing/Present option is available only for 'list' command.")
        end
        if command_name == "list" && !(params[:printformat] == nil || params[:printformat] == "JSON" || params[:printformat] == "Text")
            UI.user_error!("Unsupported print format. Supported print formats are 'JSON' and 'Text'.")
        end
      end

      def self.check_tools!
        unless `which rome`.include?('rome')
          UI.important("Install Rome for the plugin to work")
          UI.important("")
          UI.error("Install it using (Homebrew):")
          UI.command("brew install blender/homebrew-tap/rome")
          UI.error("")
          UI.error("If you don't have homebrew, visit http://brew.sh")

          UI.user_error!("Install Rome and start your lane again!")
        end
      end

      def self.available_commands
        %w(list download upload version help)
      end

      def self.available_platforms
        %w(all iOS Mac tvOS watchOS)
      end

      def self.available_print_formats
        %w(JSON Text)
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
                                       default_value: "help",
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

          FastlaneCore::ConfigItem.new(key: :present,
                                       env_name: "FL_ROME_PRESENT",
                                       description: "Option to list only present frameworks",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for present. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),

          FastlaneCore::ConfigItem.new(key: :frameworks,
                                       description: "Framework name or names to upload/download, could be applied only along with the 'upload' or 'download' commands",
                                       default_value: [],
                                       is_string: false,
                                       type: Array),

          FastlaneCore::ConfigItem.new(key: :cacheprefix,
                                       env_name: "FL_ROME_CACHE_PREFIX",
                                       description: "Allow a prefix for top level directories to be specified for all commands. Useful to store frameworks built with different Swift versions",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Requires Rome version '0.12.0.31' or later") if !meet_minimum_version("0.12.0.31")
                                       end),

          FastlaneCore::ConfigItem.new(key: :printformat,
                                       env_name: "FL_ROME_PRINT_FORMAT",
                                       description: "Specify what format to use in the output of the list command. One of 'JSON' or 'Text'. Defaults to 'Text' if omitted",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid print format. Use one of the following: JSON, Text") unless value == nil || value == "JSON" || value == "Text"
                                         UI.user_error!("Requires Rome version '0.13.0.33' or later") if !meet_minimum_version("0.13.0.33")
                                       end)

        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        %i(ios mac).include?(platform)
      end
    end
  end
end
