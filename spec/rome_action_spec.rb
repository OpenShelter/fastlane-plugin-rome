describe Fastlane::Actions::RomeAction do
  describe '#run' do
    it 'calls the rome binary at the expected path' do
      path_to_rome_binary = `which rome`
      expect(Fastlane::UI).to receive(:message).with("#{path_to_rome_binary.chomp} --version")
      Fastlane::Actions::RomeAction.run({:binary_path => path_to_rome_binary, :command => "version"})
    end
    it 'checks minimum version correctly' do
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.0.0.1", "")).to be true
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.0.0.0", "")).to be true
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0", "1")).to be false
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.18.0.51", "0.13.1.15")).to be true
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.13.1.15", "0.18.0.51")).to be false
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.18.0.51", "0")).to be true
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.18.0.51", "0.18.1.51")).to be false
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.18.1.51", "0.18.0.51")).to be true
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.18.0.51", "0.18.1.0")).to be false
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.18.0.51", "0.19.0.49")).to be false
      expect(Fastlane::Actions::RomeAction.version_is_greater_or_equal("0.19.0.49", "0.18.0.51")).to be true
    end
  end
end
