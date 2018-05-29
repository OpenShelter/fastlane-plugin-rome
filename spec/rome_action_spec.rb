describe Fastlane::Actions::RomeAction do
  describe '#run' do
    it 'calls the rome binary at the expected path' do
      path_to_rome_binary = `which rome`
      expect(Fastlane::UI).to receive(:message).with("#{path_to_rome_binary.chomp} --version")
      Fastlane::Actions::RomeAction.run({:binary_path => path_to_rome_binary, :command => "version"})
    end
  end
end
