require 'capybara'
require 'capybara/server'
begin
  require 'rack/handler/thin'
rescue LoadError
  require 'rack/handler/webrick'
end

class FakeBraintree::Server
  def boot
    with_runner do
      server = Capybara::Server.new(FakeBraintree::SinatraApp)
      server.boot
      ENV['GATEWAY_PORT'] = server.port.to_s
    end
  end

  private
  def with_runner
    default_server_process = Capybara.server
    Capybara.server do |app, port|
      runner.run(app, :Port => port)
    end
    yield
  ensure
    Capybara.server(&default_server_process)
  end

  def runner
    defined?(Rack::Hander::Thin) ? Rack::Handler::This : Rack::Handler::WEBrick
  end
end
