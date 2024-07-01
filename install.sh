#!/usr/bin/env bash

# Constants
INVALID_OPTION="Invalid option!"
DEFAULT_DIR=$(basename "$(pwd)")
DEFAULT_VERSION="0.1"
DEFAULT_LICENSE="MIT"
ERROR=1
SUCCESS=0

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
install_yarn() {
  # Check if Yarn is installed globally
  if [ ! -x "$(command -v yarn)" ]; then
    not_installed="Yarn was not installed."
    abort="Installation aborted."
    prompt="
Yarn is not installed!
Do you wish to install Yarn right now? (y/n):

> "
    read -p "$prompt" choice
    if [ -n "$choice" ]; then
      case "$choice" in
        [Yy])
          npm install -g yarn
          echo "Yarn has been installed successfully."
          ;;
        *) warn "$not_installed Exiting." "$SUCCESS" ;;
      esac
    else
      warn "$abort Exiting." "$SUCCESS"
    fi
  fi
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
  exit $2
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
      [Yy])
        install_yarn
        use_yarn
        ;;
      [Nn]) use_npm ;;
      *) warn "$INVALID_OPTION" "$ERROR" ;;
    esac
  else
    echo "Using npm as the default option."
    use_npm
  fi
  echo ""
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

setup_javascript() {
  dev_dep+=($babel)
}

setup_typescript() {
  dev_dep+=($typescript)
  dir="typescript"
  ext="tsx"
  config_files+=($TEMPLATES_PATH/$dir/$tsconfig)
}

config_package_json() {
  echo ""
  eval "$pakman init -ysf" > /dev/null 2> /dev/null # supress messages from both npm and yarn
  echo ""
  
  if [ -r "package.json" ]
  then
    curl -fsSLO $SCRIPTS/setup.js
    node setup.js --name="$pkg_name" --version="$version" --description="$description" --author="$author" --license="$license" --main="index.$ext"
    rm setup.js
  fi
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
      [Yy]) setup_typescript ;;
      [Nn]) setup_javascript ;;
      *) warn "$INVALID_OPTION" "$ERROR" ;;
    esac
  else
    use_npm
  fi
}

set_templates() {
  config_files+=($TEMPLATES_PATH/$dir/$webpack_config $TEMPLATES_PATH/index.html)
  src+=($TEMPLATES_PATH/$dir/index.$ext $TEMPLATES_PATH/$dir/App.$ext)
}

read_file_into_array() {
  local filename="$1"
  local array_name="$2"
  local content

  # Fetch the file content
  content=$(curl -s "$RESOURCES/$filename.list")

  # Initialize an empty array
  eval "declare -a $array_name"

  # Read the content line by line and add each line to the array
  while IFS= read -r line; do
    [[ -n "$line" ]] && eval "$array_name+=('$line')"
    echo "Added line $line"
  done <<< "$content"

  eval "$2+=($'$array_name')"

  echo "Array name: $2"
}

read_file_into_string() {
  local filename="$1"
  local content

  # Fetch the file content
  content=$(curl -s "$filename")

  # Remove leading/trailing whitespace and replace newlines with spaces
  local formatted_content
  formatted_content=$(echo "$content" | tr -d '\n' | tr -s ' ')

  # Assign the formatted content to the output variable
  eval "$2='$formatted_content'"
}

set_packages() {
  read_file_into_array webpack

  babel=("@babel/core @babel/plugin-transform-runtime @babel/preset-env @babel/preset-react babel-loader")
  react=("react react-dom")
  typescript=("typescript @types/react @types/react-dom ts-loader")

  dev_dep=($webpack)
  dep=($react)
}

install_dependencies() {
  echo "Installing dependencies..."
  echo ""
  eval "${install_cmd} ${dep[@]}"
  echo ""

  echo "Installing dev dependencies..."
  echo ""
  eval "${install_cmd} -D ${dev_dep[@]}"
  echo ""

  echo "Finished installing dependencies!"
  echo ""
}

download_templates() {
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
  echo ""
  echo "Done!"
}

main() {
  choose_package_manager
  set_packages

  prompt_typescript
  prompt_pkg_name
  prompt_version
  prompt_description
  prompt_author
  prompt_license

  set_templates

  config_package_json
  install_dependencies
  download_templates
}

# main
main
