describe Fastlane::Actions::RomeAction do
  describe '#run' do
    it 'Prints the version message' do
      #expect(Fastlane::UI).to receive(:message).with(/Romam/)
      Fastlane::Actions::RomeAction.run({:binary_path => "/usr/local/bin/rome", :command => "version"})
    end
  end
end
