#!/usr/bin/env bash

replace_spc() { #replaces spaces for underscores
  str=$1
  echo "$str" | sed -r 's/[ ]+/_/g'
}

replace_uds() { # replaces underscores for spaces
  str=$1
  echo "$str" | sed -r 's/[_]+/ /g'
}

use_yarn() {
  pac_install="yarn add"
}

use_npm() {
  pac_install="npm i"
}

invalid_option() {
  echo "Invalid option!"
  exit 0
}

printf "
Which package manager would you like to use? (default \"n\")

y) yarn
n) npm

> "
read pacman

if [ -n "${pacman}" ]
then
  case $pacman in
    y) use_yarn ;;
    n) use_npm ;;
    *) invalid_option ;;
  esac
else
  echo "Using npm as the default option."
  use_npm
fi

# Essential packages
webpack=$(replace_spc "webpack webpack-cli webpack-dev-server")
babel=$(replace_spc "babel-loader @babel/core @babel/cli @babel/runtime @babel/plugin-transform-runtime @babel/preset-env @babel/preset-react")
eslint=$(replace_spc "@babel/eslint-parser eslint path")
react=$(replace_spc "react react-dom")

dev_dep=($webpack $babel $eslint)
dep=($react)

echo "Installing dev dependencies..."
for pac in "${dev_dep[@]}"
do
  eval "${pac_install} -D $(replace_uds $pac)"
done

echo "Installing prod dependencies..."
for pac in "${dep[@]}"
do
  eval "${pac_install} $(replace_uds $pac)"
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
