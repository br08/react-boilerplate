#!/usr/bin/env bash

INVALID="Invalid option!"

replace_spc() { #replaces spaces for underscores
  str=$1
  echo "$str" | sed -r 's/[ ]+/_/g'
}

replace_uds() { # replaces underscores for spaces
  str=$1
  echo "$str" | sed -r 's/[_]+/ /g'
}

use_yarn() {
  pak_install="yarn add"
}

use_npm() {
  pak_install="npm i"
}

warn() {
  echo $1
  exit 0
}

printf "
Which package manager would you like to use? (default \"n\")

y) yarn
n) npm

> "
read pakman

if [ -n "${pakman}" ]
then
  case $pakman in
    y) use_yarn ;;
    n) use_npm ;;
    *) warn "$INVALID" ;;
  esac
else
  echo "Using npm as the default option."
  use_npm
fi

echo ""

# Essential packages
webpack=$(replace_spc "webpack webpack-cli webpack-dev-server html-webpack-plugin")
babel=$(replace_spc "@babel/core @babel/plugin-transform-runtime @babel/preset-env @babel/preset-react babel-loader")
react=$(replace_spc "react react-dom")

dev_dep=($webpack $babel)
dep=($react)

echo "Installing dependencies..."
for pak in "${dep[@]}"
do
  eval "${pak_install} $(replace_uds $pak)"
  echo ""
done

echo "Installing dev dependencies..."
for pak in "${dev_dep[@]}"
do
  eval "${pak_install} -D $(replace_uds $pak)"
  echo ""
done

printf "Finished installing the packages!

You won't need this installation script anymore.
Do you wish it to be deleted?

y) yes
n) no

> "
read delete

if [ -n "${delete}" ]
then
  if [ "${delete}" == "y" ]
  then
    rm install.sh
  fi
fi
