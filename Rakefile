require "pathname"
require "net/http"

task :default => :build

task :build do
  groonga_version = ENV["GROONGA_VERSION"] || "4.0.1"
  base_name = "groonga-#{groonga_version}"
  archive_name = "#{base_name}.tar.gz"
  sh("curl", "-O", "http://packages.groonga.org/source/groonga/#{archive_name}")
  sh("tar", "xf", archive_name)

  install_dir = File.join(Dir.pwd, "vendor", "groonga")
  Dir.chdir(base_name) do
    configure_args = []
    if ENV["DEBUG"] == "yes"
      configure_args << "--enable-debug"
    end
    sh("./configure",
       "--prefix=#{install_dir}",
       "--disable-document",
       *configure_args)
    sh("make", "-j4")
    sh("make", "install")
  end

  built_archive_name = "heroku-#{base_name}.tar.xz"
  sh("tar", "cJf", built_archive_name, "vendor/groonga")

  upload_base_url = ENV["UPLOAD_BASE_URL"]
  upload_base_url ||= "http://groonga-builder.herokuapp.com"
  upload_url = "#{upload_base_url}/#{built_archive_name}"
  uri = URI(upload_url)
  Net::HTTP.start(uri.host, uri.port) do |http|
    response = File.open(built_archive_name, "rb") do |archive|
      request = Net::HTTP::Put.new
      request.body = archive
      http.request(request)
    end
    puts(response.code)
    puts(response.body)
  end
end
