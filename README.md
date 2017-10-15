# heroku-groonga-builder

This is a Heroku application that builds Groonga package for Heroku
and builds libraries to make it easy to use Groonga.

## How to use?

1. Sign up Heroku [Heroku sign up page](https://www.heroku.com)
2. Get GitHub access token [your configuration page](https://github.com/settings/tokens)
3. Install [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

Use the following command lines to build Groonga package for Heroku
and upload it to Groonga's release page. You need to replace
``YOUR_GITHUB_TOKEN`` in the command lines with the real your GitHub
access token.

    % git clone https://github.com/groonga/heroku-groonga-builder.git
    % cd heroku-groonga-builder
    % heroku apps:create
    % git push heroku master
    % heroku run:detached rake GITHUB_TOKEN=YOUR_GITHUB_TOKEN

Use the following command line to see the progress.

    % heroku logs --tail

## Libraries

* [Groonga](http://groonga.org/)
  * License: [LGPLv2.1](http://opensource.org/licenses/lgpl-2.1.php)
* [MessagePack](http://msgpack.org/)
  * License: [Apache License v2.0](http://www.apache.org/licenses/LICENSE-2.0)
* [MeCab](https://code.google.com/p/mecab/)
  * License:
    * [GPL v2](http://opensource.org/licenses/gpl-2.0.php)
    * [LGPL v2.1](http://opensource.org/licenses/lgpl-2.1.php)
    * [BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause)
* [MeCab NAIST-jdic](http://sourceforge.jp/projects/naist-jdic/)
  * License: [BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause)
* [LZ4](https://code.google.com/p/lz4/)
  * License: [BSD 2-Clause](http://opensource.org/licenses/BSD-2-Clause)
