#!/usr/bin/env bash
set -ex
# 自己先保证brew的本地仓库足够新，然后使用下面的环境变量加快安装速度
export HOMEBREW_NO_AUTO_UPDATE=1

 # TODO: test existence, only install if not exist
{
# 加了一些冗余的source .bash_profile的步骤，希望不会造成负面影响

# 基本工具
# brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install vim
brew install rmtrash

## Xcode: Mac Store
##  iTerm2


brew cask install iterm2
brew cask install google-chrome
brew cask install dropbox
brew cask install charles
## Bash
brew install bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
brew install jq
brew install kubernetes-cli
brew install xmlstarlet
brew install ripgrep
brew install fzf
brew install postman
brew install psequel
brew install travis
brew install bash-completion && \
  echo '[[ -r /usr/local/etc/profile.d/bash_completion.sh ]] && . /usr/local/etc/profile.d/bash_completion.sh' \
  >> ~/.bash_profile
# TODO: check brew installed node/npm version, if exists and is old, update to lts, do that manually

brew cask install shadowsocksx-ng-r
. ~/.bash_profile

brew cask install docker
docker run -d -p:8100:8080 --name plantuml --restart always plantuml/plantuml-server:jetty
# 其他可选镜像
# minimum2scp/squid

# node 环境
## nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.bash_profile

## node
nvm install --lts
npm i -g yarn
npm i -g npx
npm i -g typescript
npm i -g trymodule

# ruby环境
git clone https://github.com/andorchen/rbenv-china-mirror.git ~/.rbenv/plugins/rbenv-china-mirror || true
brew install rbenv ruby-build
. ~/.bash_profile
rbenv install 2.4.2
. ~/.bash_profile
rbenv global 2.4.2
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
gem install bundler
bundle config mirror.http://rubygems.org https://gems.ruby-china.com
gem install cocoapods
gem install fir-cli
gem install xcpretty

# react-native
brew install watchman

# iOS 环境
if brew info carthage >/dev/null 2>&1 ; then
  brew upgrade carthage
else
  brew install carthage
fi
brew install ios-webkit-debug-proxy
# grubbox主题
# https://github.com/morhetz/gruvbox-contrib/tree/master/xcode
# xvim
git clone 'https://github.com/XVimProject/XVim2' && cd XVim2 && make

# android
# 可以使用brew安装java sdk
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk8
. ~/.bash_profile

brew cask install android-sdk || exit 0

# if you dont already have the following code in your bashrc file, uncomment them then
#cat >>~/.bash_profile <<"EOF"
#REQUESTED_JAVA_VERSION='1.8'
#if POSSIBLE_JAVA_HOME="$(/usr/libexec/java_home -v $REQUESTED_JAVA_VERSION 2>/dev/null)"; then
#  # Do this if you want to export JAVA_HOME
#  export JAVA_HOME="$POSSIBLE_JAVA_HOME"
#  export PATH="${JAVA_HOME}/bin:${PATH}"
#fi
#
#export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
#if [ -d "${ANDROID_SDK_ROOT}" ] ; then
#  export ANDROID_HOME="$ANDROID_SDK_ROOT"
#  export PATH=$PATH:${ANDROID_SDK_ROOT}/emulator
#  export PATH=$PATH:${ANDROID_SDK_ROOT}/tools
#  export PATH=$PATH:${ANDROID_SDK_ROOT}/tools/bin
#  export PATH=$PATH:${ANDROID_SDK_ROOT}/platform-tools
#else
#  unset ANDROID_SDK_ROOT
#fi
#EOF

. ~/.bash_profile

brew install gradle

# 除了上面的sdk-tool，再安装另外两种tool
sdkmanager --install "build-tools;26.0.3" platform-tools

. ~/.bash_profile

brew install --HEAD universal-ctags/universal-ctags/universal-ctags

# python开发环境
vpy3() {
  local python_exe=python3
  if [ ! -d "$HOME/.virtualenv" ] ;then
    mkdir "$HOME/.virtualenv"
  fi
  if [ ! -d "$HOME/.virtualenv/$python_exe" ] ;then
    virtualenv -p $python_exe "$HOME/.virtualenv/$python_exe"
  fi
  source "$HOME/.virtualenv/$python_exe/bin/activate"
}
pip install virtualenv
vpy3
pip install -r <(
echo 'setuptools'
echo '# twine可以用来发布python package到pypi'
echo 'twine'
echo '# 最新版本pylint的和py3.6或一些第三方库不兼容'
echo 'pylint == 1.6.0'
)
deactivate

} >>setup_dev.logs
