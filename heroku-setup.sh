#!/bin/sh
{
    HEROKU_CLIENT_URL="https://s3.amazonaws.com/assets.heroku.com/heroku-client/heroku-client.tgz"

  mkdir ~/heroku
  cd ~/heroku

  if [ -z "$(which wget)" ]; then
    curl -s $HEROKU_CLIENT_URL | tar xz
  else
    wget -qO- $HEROKU_CLIENT_URL | tar xz
  fi

  mv heroku-client/* .
  rmdir heroku-client

  export PATH=~/heroku/bin:$PATH

    if [ ":$PATH:" != *":/usr/local/heroku/bin:"* ]; then
    echo "Add the Heroku CLI to your PATH using:"
    echo "$ echo 'PATH=\"~/heroku/bin:\$PATH\"' >> ~/.profile"
    fi

    echo "Installation complete"
}
