require 'capybara'
require 'capybara/server'
require 'rack/deflater'
require 'rack/builder'
begin
  require 'rack/handler/thin'
rescue LoadError
  require 'rack/handler/webrick'
end

class FakeBraintree::Server
  def boot
    puts "Runner is #{runner}"
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
      runner.run(app, :Port => port, :AccessLog => [])
    end
    yield
  ensure
    Capybara.server(&default_server_process)
  end

  def runner
    defined?(Thin) ? Rack::Handler::Thin : Rack::Handler::WEBrick
  end
end
