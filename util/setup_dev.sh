#!/usr/bin/env bash
set -ex
export HOMEBREW_NO_AUTO_UPDATE=1
 # TODO: test existence, only install if not exist
{
# 加了一些冗余的source .bash_profile的步骤，希望不会造成负面影响

# 基本工具
## Xcode: Mac Store
##  iTerm2
brew cask install iterm2
brew cask install google-chrome
brew cask install dropbox
## Bash
brew install bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
brew install jq
brew install kubernetes-cli
brew install xmlstarlet
brew install ripgrep
brew install fzf
# failed!!!
brew install bash-completion && echo "[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion" >> ~/.bash_profile
# TODO: check brew installed node/npm version, if exists and is old, update to lts, do that manually

brew cask install shadowsocksx-ng-r
. ~/.bash_profile

# node 环境
## nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.bash_profile

## node
nvm install --lts
npm i -g yarn
npm i -g npx

# ruby环境
git clone https://github.com/andorchen/rbenv-china-mirror.git ~/.rbenv/plugins/rbenv-china-mirror || true
brew install rbenv ruby-build
. ~/.bash_profile
rbenv install 2.4.2
. ~/.bash_profile
rbenv global 2.4.2
gem install bundler
bundle config mirror.http://rubygems.org https://gems.ruby-china.com
gem install cocoapods
gem install fir-cli

# react-native
brew install watchman

# iOS 环境
if brew info >/dev/null 2>&1 ; then
  brew upgrade carthage
else
  brew install carthage
fi

# android
# 可以使用brew安装java sdk
brew tap AdoptOpenJDK/openjdk
brew cask install adoptopenjdk8
. ~/.bash_profile

brew tap caskroom/cask && brew cask install android-sdk

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
} >>setup_dev.logs
