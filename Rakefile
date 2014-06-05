require "octokit"

task :default => :build

@top_dir = Dir.pwd

def top_dir
  @top_dir
end

def relative_install_prefix
  File.join("vendor", "groonga")
end

def absolete_install_prefix
  File.join(top_dir, relative_install_prefix)
end

def github_token
  ENV["GITHUB_TOKEN"]
end

def groonga_version
  ENV["GROONGA_VERSION"] || "4.0.2"
end

def groonga_base_name
  "groonga-#{groonga_version}"
end

def groonga_tag_name
  "v#{groonga_version}"
end

def github_groonga_repository
  "groonga/groonga"
end

def create_client
  Octokit::Client.new(:access_token => github_token)
end

def find_release
  client = create_client
  releases = client.releases(github_groonga_repository)
  releases.find do |release|
    release.tag_name == groonga_tag_name
  end
end

def release_exist?
  not find_release.nil?
end

def ensure_create_release
  return if release_exist?

  client = create_client
  client.create_release(github_groonga_repository, groonga_tag_name)
end

def build_groonga
  archive_name = "#{groonga_base_name}.tar.gz"
  sh("curl", "-O", "http://packages.groonga.org/source/groonga/#{archive_name}")
  sh("tar", "xf", archive_name)

  Dir.chdir(base_name) do
    configure_args = []
    if ENV["DEBUG"] == "yes"
      configure_args << "--enable-debug"
    end
    sh("./configure",
       "--prefix=#{absolete_install_prefix}",
       "--disable-static",
       "--disable-document",
       *configure_args)
    sh("make", "-j4")
    sh("make", "install")
  end
end

def archive
  built_archive_name = "heroku-#{groonga_base_name}.tar.xz"
  sh("tar", "cJf", built_archive_name, relative_install_prefix)

  build_archive_name
end

def upload_archive(archive_name)
  release = find_release

  client = create_client
  client.upload_asset(release.url, archive_name)
end

task :build do
  if github_token.nil?
    raise "must set GITHUB_TOKEN environment variable"
  end

  ensure_create_release
  build_groonga
  archive_name = archive
  release_archive(archive_name)
end
