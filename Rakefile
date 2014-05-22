task :default => :build

task :go do
  go_version = "1.2.2"
  go_archive_name = "go#{go_version}.linux-amd64.tar.gz"
  sh("curl", "-O", "https://storage.googleapis.com/golang/#{go_archive_name}")
  sh("tar", "xf", go_archive_name)

  go_root = File.join(Dir.pwd, "go")
  ENV["GOROOT"] = go_root
  go_path = File.join(Dir.pwd, "work", "go")
  mkdir_p(go_path)
  ENV["GOPATH"] = go_path

  paths = [
    go_path,
    go_root,
    ENV["PATH"],
  ]
  ENV["PATH"] = paths.join(File::PATH_SEPARATOR)
end

task :github_release => :go do
  sh("go", "get", "github.com/aktau/github-release")
end

task :build => :github_release do
  if ENV["GITHUB_TOKEN"].nil?
    raise "must set GITHUB_TOKEN environment variable"
  end

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

  sh("github-release",
     "upload",
     "--user", "groonga",
     "--repo", "groonga",
     "--tag", "v#{groonga_version}",
     "--name", built_archive_name,
     "--file", built_archive_name)
end
