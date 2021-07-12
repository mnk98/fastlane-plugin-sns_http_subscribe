describe Fastlane::Actions::SnsHttpSubscribeAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The sns_http_subscribe plugin is working!")

      Fastlane::Actions::SnsHttpSubscribeAction.run(nil)
    end
  end
end
