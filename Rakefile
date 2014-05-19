require "pathname"

task :default => :build

groonga_version = "4.0.1"

task :build do
  base_name = "groonga-#{groonga_version}"
  archive_name = "#{base_name}.tar.gz"
  sh("curl", "-O", "http://packages.groonga.org/source/groonga/#{archive_name}")
  sh("tar", "xf", archive_name)

  install_dir = File.join(Dir.pwd, "vendor", "groonga")
  Dir.chdir(base_name) do
    sh("./configure",
       "--prefix=#{install_dir}",
       "--disable-document")
    sh("make", "-j")
    sh("make", "install")
  end

  sh("tar", "cJf", "heroku-#{base_name}.tar.xz", "vendor/groonga")
end
