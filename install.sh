#!/usr/bin/env bash

# Constants
INVALID_OPTION="Invalid option!"
DEFAULT_DIR=$(basename "$(pwd)")
DEFAULT_VERSION="0.1"
DEFAULT_LICENSE="MIT"

ROOT="https://raw.githubusercontent.com/br08/react-boilerplate/main"
SCRIPTS="$ROOT/scripts"
TEMPLATES_PATH="$ROOT/templates"

# Global variables
tsconfig="tsconfig.json"
webpack_config="webpack.config.js"
dir="javascript"
ext="js"
index="index.js"
app="App.js"

config_files=()
src=()

pkg_name=""
version=""
license=""
description=""
author=""

# Functions

replace_spc() { #replaces spaces for underscores
  str=$1
  echo "$str" | sed -r 's/[ ]+/_/g'
}

replace_uds() { # replaces underscores for spaces
  str=$1
  echo "$str" | sed -r 's/[_]+/ /g'
}

use_yarn() {
  pakman="yarn"
  install_cmd="yarn add"
}

use_npm() {
  pakman="npm"
  install_cmd="npm i"
}

warn() {
  echo $1
  exit 0
}

choose_package_manager() {
  prompt="
Which package manager would you like to use? (default \"n\")

y) yarn
n) npm

> "
  read -p "$prompt" pakman

  if [ -n "$pakman" ]
  then
    case $pakman in
      y) use_yarn ;;
      n) use_npm ;;
      *) warn "$INVALID_OPTION" ;;
    esac
  else
    echo "Using npm as the default option."
    use_npm
  fi
}

prompt_pkg_name() {
  prompt="package name ($DEFAULT_DIR): "
  read -p "$prompt" pkg_name

  if [ -z "$pkg_name" ]; then
    pkg_name="$DEFAULT_DIR"
  fi

  if [ -n "$pkg_name" ] && [ "$pkg_name" != "$DEFAULT_DIR" ]
  then
    eval "mkdir $pkg_name"
    eval "cd $pkg_name"
  fi
}

prompt_version() {
  prompt="version ($DEFAULT_VERSION): "
  read -p "$prompt" version

  if [ -z "$version" ]; then
    version="$DEFAULT_VERSION"
  fi
}

prompt_description() {
  prompt="description: "
  read -p "$prompt" description
}

prompt_author() {
  prompt="author: "
  read -p "$prompt" author
}

prompt_license() {
  prompt="license ($DEFAULT_LICENSE): "
  read -p "$prompt" license

  if [ -z "$version" ]; then
    license="$DEFAULT_LICENSE"
  fi
}

setup_for_javascript() {
  dev_dep+=($babel)
}

setup_for_typescript() {
  dev_dep+=($typescript)
  dir="typescript"
  ext="tsx"
  config_files+=($TEMPLATES_PATH/$dir/$tsconfig)
}

prompt_typescript() {
  prompt="
Do you wish to use TypeScript? (default \"n\")

y) yes
n) no

> "
  read -p "$prompt" with_typescript
  
  if [ -n "$with_typescript" ]
  then
    case $with_typescript in
      y) setup_for_typescript ;;
      n) setup_for_javascript ;;
      *) warn "$INVALID_OPTION" ;;
    esac
  else
    use_npm
  fi
}

set_templates() {
  config_files+=($TEMPLATES_PATH/$dir/$webpack_config $TEMPLATES_PATH/index.html)
  src+=($TEMPLATES_PATH/$dir/index.$ext $TEMPLATES_PATH/$dir/App.$ext)
}

set_packages() {
  webpack=$(replace_spc "webpack webpack-cli webpack-dev-server html-webpack-plugin")
  babel=$(replace_spc "@babel/core @babel/plugin-transform-runtime @babel/preset-env @babel/preset-react babel-loader")
  react=$(replace_spc "react react-dom")
  typescript=$(replace_spc "typescript @types/react @types/react-dom ts-loader")

  dev_dep=($webpack)
  dep=($react)
}

setup() {
  set_packages

  prompt_typescript
  prompt_pkg_name
  prompt_version
  prompt_description
  prompt_author
  prompt_license

  set_templates

  echo ""
  eval "$pakman init -ysf" > /dev/null 2> /dev/null # supress messages from both npm and yarn
  echo ""

  if [ -r "package.json" ]
  then
    curl -fsSLO $SCRIPTS/setup.js
    node setup.js --name="$pkg_name" --version="$version" --description="$description" --author="$author" --license="$license" --main="index.$ext"
    rm setup.js
  fi

  echo "Installing dependencies..."
  echo ""
  for pak in "${dep[@]}"
  do
    eval "${install_cmd} $(replace_uds $pak)"
    echo ""
  done

  echo "Installing dev dependencies..."
  echo ""
  for pak in "${dev_dep[@]}"
  do
    eval "${install_cmd} -D $(replace_uds $pak)"
    echo ""
  done

  echo "Finished installing the dependencies!"
  echo ""

  echo "Dowloading templates..."
  for file in "${config_files[@]}"
  do
    curl -fsSLO "${file}"
  done
  mkdir src
  cd src
  for file in "${src[@]}"
  do
    curl -fsSLO "${file}"
  done
  echo "Done!"
}

main() {
  choose_package_manager
  echo ""
  setup
}

# main
main
