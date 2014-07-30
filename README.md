# heroku-groonga-builder

This is a Heroku application that builds Groonga package for Heroku.

## How to use?

1. Sign up Heroku [Heroku sign up page](https://www.heroku.com)
2. Get GitHub access token [your configuration page](https://github.com/settings/applications)
3. Install [Heroku toolbelt](https://toolbelt.heroku.com)

Use the following command lines to build Groonga package for Heroku
and upload it to Groonga's release page. You need to replace
``YOUR_GITHUB_TOKEN`` in the command lines with the real your GitHub
access token.

    % git clone https://github.com/groonga/heroku-groonga-builder.git
    % cd heroku-groonga-builder
    % heroku apps:create
    % git push heroku master
    % heroku run:detached rake GITHUB_TOKEN=YOUR_GITHUB_TOKEN
