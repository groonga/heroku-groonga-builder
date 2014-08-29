require "octokit"

task :default => :build

class GroongaBuilder
  include Rake::DSL

  def initialize
    @top_dir = Dir.pwd
    @github_token = ENV["GITHUB_TOKEN"]
    if @github_token.nil?
      raise "must set GITHUB_TOKEN environment variable"
    end
  end

  def run
    ensure_release
    build_msgpack
    build_groonga
    archive_name = archive
    upload_archive(archive_name)
  end

  private
  def relative_install_prefix
    File.join("vendor", "groonga")
  end

  def absolete_install_prefix
    File.join(@top_dir, relative_install_prefix)
  end

  def msgpack_prefix
    File.join(@top_dir, "vendor", "msgpack")
  end

  def groonga_version
    ENV["GROONGA_VERSION"] || "4.0.5"
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

  def client
    @client ||= Octokit::Client.new(:access_token => @github_token)
  end

  def find_release
    releases = client.releases(github_groonga_repository)
    releases.find do |release|
      release.tag_name == groonga_tag_name
    end
  end

  def release_exist?
    not find_release.nil?
  end

  def ensure_release
    return if release_exist?

    client.create_release(github_groonga_repository, groonga_tag_name)
  end

  def build_msgpack
    msgpack_version = "0.5.9"
    msgpack_archive_name = "msgpack-#{msgpack_version}"
    sh("curl",
       "--silent",
       "--remote-name",
       "--location",
       "--fail",
       "https://github.com/msgpack/msgpack-c/releases/download/cpp-#{msgpack_version}/#{msgpack_archive_name}.tar.gz")
    sh("tar", "xf", "#{msgpack_archive_name}.tar.gz")

    Dir.chdir(msgpack_archive_name) do
      sh("./configure",
         "--prefix=#{msgpack_prefix}")
      sh("make", "-j4")
      sh("make", "install")
    end
  end

  def build_groonga
    archive_name = "#{groonga_base_name}.tar.gz"
    sh("curl",
       "--silent",
       "--remote-name",
       "--location",
       "--fail",
       "http://packages.groonga.org/source/groonga/#{archive_name}")
    sh("tar", "xf", archive_name)

    Dir.chdir(groonga_base_name) do
      configure_args = []
      if ENV["DEBUG"] == "yes"
        configure_args << "--enable-debug"
      end
      sh("./configure",
         "--prefix=#{absolete_install_prefix}",
         "--disable-static",
         "--disable-document",
         "--with-message-pack=#{msgpack_prefix}",
         *configure_args)
      sh("make", "-j4")
      sh("make", "install")
    end
  end

  def archive
    archive_name = "heroku-#{groonga_base_name}.tar.xz"
    sh("tar", "cJf", archive_name, relative_install_prefix)
    archive_name
  end

  def upload_archive(archive_name)
    release = find_release
    options = {
      :content_type => "application/x-xz",
    }
    client.upload_asset(release.url, archive_name, options)
  end
end

task :build do
  builder = GroongaBuilder.new
  builder.run
end
