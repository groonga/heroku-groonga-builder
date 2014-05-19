# -*- ruby -*-

require "fileutils"

class Uploader
  class ValidationError < StandardError
  end

  def initialize(request, response)
    @request = request
    @response = response
    @response["Content-Type"] = "text/plain"
  end

  def run
    begin
      validate
    rescue ValidationError
    else
      upload
    end

    @response.finish
  end

  private
  def validate
    validate_method
    validate_path
    validate_content
  end

  def validation_error(message)
    @response.status = 400
    @response.write(message)
    raise ValidationError
  end

  def validate_method
    return if @request.put?
    validation_error("must be PUT\n")
  end

  def validate_path
    return unless @request.path.end_with?("/")
    validation_error("must be file name\n")
  end

  def validate_content
    return if @request.body
    validation_error("body is required\n")
  end

  def upload
    path = "public#{@request.path}"
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "wb") do |output|
      buffer_size = 8912
      buffer = ""
      while @request.body.read(buffer_size, buffer)
        output.write(buffer)
      end
    end

    @response.write("Uploaded\n")
  end
end

file_server = Rack::File.new("public")
directory_server = Rack::Directory.new("public")

application = lambda do |env|
  request = Rack::Request.new(env)
  response = Rack::Response.new
  if request.get?
    if request.path.end_with?("/")
      directory_server.call(env)
    else
      file_server.call(env)
    end
  else
    uploader = Uploader.new(request, response)
    uploader.run
  end
end
run application
