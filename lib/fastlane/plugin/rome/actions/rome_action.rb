module Fastlane
  module Actions
    class RomeAction < Action
      def self.run(params)
        validate(params)

        cmd = [params[:binary_path].chomp]
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
        cmd << "--romefile #{params[:romefile]}" if params[:romefile]
        cmd << "--no-ignore" if params[:noignore] == true
        cmd << "--no-skip-current" if params[:noskipcurrent] == true
        cmd << "-v " if params[:verbose]

        action = Actions.sh(cmd.join(' '))
        UI.message(action)
        return action
      end

      def self.meet_minimum_version(binary_path, minimum_version)
        version = Actions.sh("#{binary_path} --version") # i.e. 0.12.0.31 - Romam uno die non fuisse conditam.
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
        binary_path = params[:binary_path].chomp
        unless binary_path.include?('rome')
          UI.important("Install Rome for the plugin to work")
          UI.important("")
          UI.error("Or install it using CocoaPods:")
          UI.error("Add `pod 'Rome'` to your Podfile, and set `binary_path` option to `Pods/Rome/rome`")
          UI.error("")
          UI.error("Install it using Homebrew:")
          UI.command("brew install blender/homebrew-tap/rome")
          UI.error("")
          UI.error("If you don't have homebrew, visit http://brew.sh")

          UI.user_error!("Install Rome and start your lane again!")
        end

        command_name = params[:command]
        if !(command_name == "upload" || command_name == "download") && (params[:frameworks] || []).count > 0
          UI.user_error!("Frameworks option is available only for 'upload'' or 'download' commands.")
        end

        if command_name != "list" && (params[:missing] || params [:present])
          UI.user_error!("Missing/Present option is available only for 'list' command.")
        end

        if command_name == "list" && !(params[:printformat] == nil || params[:printformat] == "JSON" || params[:printformat] == "Text")
          UI.user_error!("Unsupported print format. Supported print formats are 'JSON' and 'Text'.")
          UI.user_error!("'printformat' option requires Rome version '0.13.0.33' or later") if !meet_minimum_version(binary_path, "0.13.0.33")
        end

        noignore = params[:noignore]
        if noignore != nil
          UI.user_error!("'noignore' option requires Rome version '0.13.1.35' or later") if !meet_minimum_version(binary_path, "0.13.1.35")
        end
        cacheprefix = params[:cacheprefix]
        if cacheprefix != nil
          UI.user_error!("'cacheprefix' option requires Rome version '0.12.0.31' or later") if !meet_minimum_version(binary_path, "0.12.0.31")
        end
        noskipcurrent = params[:noskipcurrent]
        if noskipcurrent != nil
          UI.user_error!("'noskipcurrent' option requires Rome version '0.18.0.51' or later") if !meet_minimum_version(binary_path, "0.18.0.51")
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
        ["François Benaiteau", "Tommaso Piazza"]
      end

      def self.details
        "Rome is a tool that allows developers on Apple platforms to use Amazon's S3  and/or others as a shared cache for frameworks built with Carthage."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       env_name: "FL_ROME_BINARY_PATH",
                                       description: "Rome binary path, set to `Pods/Rome/rome` if you install Rome via CocoaPods",
                                       optional: true,
                                       default_value: `which rome`),

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

          FastlaneCore::ConfigItem.new(key: :noignore,
                                       env_name: "FL_ROME_NOIGNORE",
                                       description: "Ignore the `ignoreMap` section of a Romefile",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for noignore. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
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
                                       is_string: true),

          FastlaneCore::ConfigItem.new(key: :printformat,
                                       env_name: "FL_ROME_PRINT_FORMAT",
                                       description: "Specify what format to use in the output of the list command. One of 'JSON' or 'Text'. Defaults to 'Text' if omitted",
                                       optional: true,
                                       is_string: true),

          FastlaneCore::ConfigItem.new(key: :romefile,
                                       env_name: "FL_ROME_ROMEFILE",
                                       description: "The path to the Romefile to use. Defaults to the \"Romefile\" in the current directory",
                                       optional: true,
                                       is_string: true),

          FastlaneCore::ConfigItem.new(key: :noskipcurrent,
                                       env_name: "FL_ROME_NOSKIPCURRENT",
                                       description: "Use the `currentMap` section when performing the operation",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for noskipcurrent. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
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
