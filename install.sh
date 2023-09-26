#!/usr/bin/env bash

INVALID_OPTION="Invalid option!"

branch="main"

root="https://raw.githubusercontent.com/br08/react-boilerplate/$branch"
scripts="${root}/scripts"
templates="${root}/templates"
tsconfig="tsconfig.json"
webpack_config="webpack.config.js"
dir="javascript"
index="index.js"
app="App.js"

files=()
src=()

config_javascript() {
  dev_dep+=($babel)
}

config_typescript() {
  dev_dep+=($typescript)
  dir="typescript"
  index="index.tsx"
  app="App.tsx"
  files+=($templates/$dir/$tsconfig)
}

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

prompt="
Which package manager would you like to use? (default \"n\")

y) yarn
n) npm

> "
read -p "$prompt" pakman

if [ -n "${pakman}" ]
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

echo ""

# Essential packages
webpack=$(replace_spc "webpack webpack-cli webpack-dev-server html-webpack-plugin")
babel=$(replace_spc "@babel/core @babel/plugin-transform-runtime @babel/preset-env @babel/preset-react babel-loader")
react=$(replace_spc "react react-dom")
typescript=$(replace_spc "typescript @types/react @types/react-dom ts-loader")

dev_dep=($webpack)
dep=($react)

prompt="
Do you wish to use TypeScript? (default \"n\")

y) yes
n) no

> "
read -p "$prompt" with_typescript

if [ -n "${with_typescript}" ]
then
  case $with_typescript in
    y) config_typescript ;;
    n) config_javascript ;;
    *) warn "$INVALID_OPTION" ;;
  esac
else
  echo "TypeScript will not be installed in this project."
  use_npm
fi

files+=($templates/$dir/$webpack_config $templates/index.html)
src+=($templates/$dir/$index $templates/$dir/$app)

echo ""
eval "${pakman} init"
echo ""

[ -r "package.json" ] && node -e "$(curl -fsSL $scripts/pk-json-scripts.js)"

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

echo "Finished installing the packages!"
echo ""
echo "Dowloading templates..."
for file in "${files[@]}"
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