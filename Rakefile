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
    setup_environment_variables
    build_mecab
    build_msgpack
    build_lz4
    build_groonga
    archive_name = archive
    upload_archive(archive_name)
  end

  private
  def relative_install_prefix
    File.join("vendor", "groonga")
  end

  def absolute_install_prefix
    File.join(@top_dir, relative_install_prefix)
  end

  def relative_mecab_prefix
    File.join("vendor", "mecab")
  end

  def absolute_mecab_prefix
    File.join(@top_dir, relative_mecab_prefix)
  end

  def mecab_config
    File.join(absolute_mecab_prefix, "bin", "mecab-config")
  end

  def groonga_version
    ENV["GROONGA_VERSION"] || "5.1.1"
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

  def setup_environment_variables
    ENV["PKG_CONFIG_PATH"] =
      File.join(absolute_install_prefix, "lib", "pkgconfig")
    path = ENV["PATH"].split(File::PATH_SEPARATOR)
    path += [File.join(absolute_install_prefix, "bin")]
    ENV["PATH"] = path.join(File::PATH_SEPARATOR)
  end

  def build_mecab
    mecab_version = "0.996"
    mecab_archive_name = "mecab-#{mecab_version}"
    sh("curl",
       "--silent",
       "--remote-name",
       "--location",
       "--fail",
       "https://mecab.googlecode.com/files/#{mecab_archive_name}.tar.gz")
    sh("tar", "xf", "#{mecab_archive_name}.tar.gz")

    Dir.chdir(mecab_archive_name) do
      sh("./configure",
         "--prefix=#{absolute_mecab_prefix}")
      sh("make")
      sh("make", "check")
      sh("make", "install")
    end

    naist_jdic_version = "0.6.3b-20111013"
    naist_jdic_archive_name = "mecab-naist-jdic-#{naist_jdic_version}"
    sh("curl",
       "--silent",
       "--remote-name",
       "--location",
       "--fail",
       "http://iij.dl.sourceforge.jp/naist-jdic/53500/#{naist_jdic_archive_name}.tar.gz")
    sh("tar", "xf", "#{naist_jdic_archive_name}.tar.gz")

    Dir.chdir(naist_jdic_archive_name) do
      sh("./configure",
         "--prefix=#{absolute_mecab_prefix}",
         "--with-mecab-config=#{mecab_config}",
         "--with-charset=utf8")
      sh("make")
      sh("make", "install-data")
    end
    mecab_rc_path = File.join(absolute_mecab_prefix, "etc", "mecabrc")
    mecab_rc_content = File.open(mecab_rc_path, "r") do |mecab_rc|
      mecab_rc.read
    end
    naist_jdic_dir = File.join(absolute_mecab_prefix, "lib", "mecab", "dic", "naist-jdic")
    File.open(mecab_rc_path, "w") do |mecab_rc|
      mecab_rc.print(mecab_rc_content.gsub(/^dicdir\s*=.+$/,
                                           "dicdir = #{naist_jdic_dir}"))
    end
  end

  def build_msgpack
    msgpack_version = "1.3.0"
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
         "--prefix=#{absolute_install_prefix}")
      sh("make", "-j4")
      sh("make", "install")
    end
  end

  def build_lz4
    lz4_version = "r131"
    lz4_archive_name = "lz4-#{lz4_version}"
    sh("curl",
       "--silent",
       "--remote-name",
       "--remote-header-name",
       "--location",
       "--fail",
       "https://github.com/Cyan4973/lz4/archive/#{lz4_version}.tar.gz")
    sh("tar", "xf", "#{lz4_archive_name}.tar.gz")

    Dir.chdir(lz4_archive_name) do
      sh("make", "install", "PREFIX=#{absolute_install_prefix}")
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
         "--prefix=#{absolute_install_prefix}",
         "--disable-static",
         "--disable-document",
         "--with-message-pack=#{absolute_install_prefix}",
         "--with-mecab-config=#{mecab_config}",
         "--with-lz4",
         *configure_args)
      sh("make", "-j4")
      sh("make", "install")
    end
  end

  def archive
    archive_name = "heroku-#{groonga_base_name}.tar.xz"
    sh("tar", "cJf", archive_name,
       relative_install_prefix,
       relative_mecab_prefix)
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
