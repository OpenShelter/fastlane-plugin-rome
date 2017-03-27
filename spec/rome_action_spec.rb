describe Fastlane::Actions::RomeAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The rome plugin is working!")

      Fastlane::Actions::RomeAction.run(nil)
    end
  end
end
