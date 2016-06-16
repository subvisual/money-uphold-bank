$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "webmock/rspec"

RSpec.configure do |config|
  WebMock.enable!

  config.before(:each) do
    WebMock.
      stub_request(:get, "https://api.uphold.com/v0/ticker").
      to_return(
        status: 200,
        body: File.read(File.join(File.dirname(__FILE__), "fixtures", "ticker.json")),
      )
  end
end
