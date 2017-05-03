#!/bin/bash

###############################################################################
# Bash helper functions (github.com/alanlivio/bash_helper_functions)
# update by: wget raw.githubusercontent.com/alanlivio/bash_helper_functions/master/bash_helper_functions.sh
###############################################################################

###############################################################################
# log functions 
###############################################################################

function aux-print() { echo -e "$1" | fold -w100 -s | sed '2~1s/^/  /'; }
function log-error() { aux-print "\033[00;31m---> $* \033[00m"; }
function log-msg()   { aux-print "\033[00;33m---> $* \033[00m"; }
function log-done()  { aux-print "\033[00;32m---> done\033[00m"; }
function log-ok()    { aux-print "\033[00;32m---> ok033[00m"; }
function TRY()       { "$@"; if test $? -ne 0; then log-error "$1" && exit 1; fi;}

case "$(uname -s)" in
   Darwin)IS_MAC=1;;
   Linux)IS_LINUX=1;;
   CYGWIN*|MINGW32*|MSYS*) IS_WINDOWS=1
esac

###############################################################################
# audio functions
###############################################################################

function mybash-audio-create-empty() {
  # gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location=file.mp3
  : ${1?an argument is required}
  gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location="$1"
}

function mybash-audio-compress() {  
  : ${1?an argument is required}
  lame -b 32  "$1".mp3 compressed"$1".mp3
}

###############################################################################
# video functions
###############################################################################

function mybash-video-create-by-image() {
  : ${1?an argument is required}
  ffmpeg -loop_input -i "$1".png -t 5 "$1".mp4
}

function mybash-video-cut() {
  : ${1? an argument is required}
  : ${2? an second argument is required}
  : ${3? an third argument is required}
  # ffmpeg -i video-cuted.mp4 -vcodec copy -acodec copy -ss 00:16:03 -t 00:09:34 -f mp4 "video.mp4"
  ffmpeg -i $1  -vcodec copy -acodec copy -ss $2  -t $3  -f mp4 cuted-$1
}

function mybash-video-gst-side-by-side-test() {
  gst-launch-1.0 compositor name=comp  sink_1::xpos=640 !   videoconvert ! ximagesink   videotestsrc pattern=snow  !   "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" !   timeoverlay ! queue2 ! comp.   videotestsrc pattern=smpte !   "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" !   timeoverlay ! queue2 ! comp.
}

function mybash-video-gst-side-by-side-args() {
  : ${2?two arguments are required}
  gst-launch-1.0 compositor name=comp  sink_1::xpos=640 ! ximagesink  filesrc location=$1 !   "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" !   decodebin ! videoconvert ! comp. filesrc location=$2  !   "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! decodebin ! videoconvert ! comp.
}

###############################################################################
# pygmentize functions
###############################################################################

function mybash-pygmentize-files-by-extensions-to-image() {
  : ${1?an argument is required}
  find . -maxdepth 1 -name "*.$1" | while read -r i
  do
    pygmentize -f jpeg -l xml -o $i.jpg $i
  done
}

function mybash-pygmentize-files-by-extensions-to-rtf() {
  : ${1?an argument is required}
   find . -maxdepth 1 -name "*.$1" | while read -r i
  do
    pygmentize -f jpeg -l xml -o $i.jpg $i
    pygmentize -P fontsize=16 -P fontface=consolas -l -o $i.rtf $i
  done
}

function mybash-pygmentize-files-by-extensions-to-html() {
  : ${1?an argument is required}
   find . -maxdepth 1 -name "*.$1" | while read -r i
  do
    pygmentize -O full,style=default -f html -l xml -o $i.html $i
  done
}

###############################################################################
# gdb functions
###############################################################################

function mybash-gdb-run-bt() {
  : ${1?an argument is required}
  gdb -batch -ex=r -ex=bt --args "$1"
}

function mybash-gdb-run-bt-all-threads() {
  : ${1?an argument is required}
  gdb -batch -ex=r -ex="thread apply all bt" --args "$1"
}

###############################################################################
# git functions
###############################################################################

function mybash-git-create-gitignore() {
  : ${1?an argument is required}
  curl -L -s "https://www.gitignore.io/api/$1"
}

function mybash-git-create-gitignore-essentials() {
  mybash-git-create-gitignore code,eclipse,executable,git,intellij,linux,notepadpp,osx,sublimetext,vim,windows,xcode
}

function mybash-git-create-gitignore-javascript() {
  mybash-git-create-gitignore node,bower,grunt
}

function mybash-git-create-gitignore-cpp() {
  mybash-git-create-gitignore c,c++,qt,autotools,make,ninja,cmake
}

function mybash-git-find-folders-reset-clean-uninstall {
  find -iname .git | while read -r i
  do
    cd "$(dirname $i)" || exit
    make clean
    make uninstall
    git reset --hard
    git clean -df
    cd -
  done
}

function mybash-git-commit-formated() {
  echo -e "\n" > /tmp/commit.txt
  for i in $(git status -s|cut -c4-); do
    echo -e "* $i: Likewise.">>  /tmp/commit.txt
  done
  git commit -t /tmp/commit.txt
}

function mybash-git-list-large-files() {
  git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -3
}

###############################################################################
# editors functions
###############################################################################

function mybash-qtcreator-project-from-git() {
  project_name="${PWD##*/}"
  touch "$project_name.config"
  echo -e "[General]\n" > "$project_name.creator"
  echo -e "src\n" > "$project_name.includes"
  git ls-files > "$project_name.files"
}

function mybash-atom-copy-tern-project(){
  cp ~/gdrive/env/apps/.tern-project .
}

function mybash-eclipse-list-installed() {
  /opt/eclipse/eclipse \
  -consolelog -noSplash \
  -application org.eclipse.equinox.p2.director \
  -listInstalledRoots
}

###############################################################################
# android functions
###############################################################################

function mybash-android-start-activity () {
  #adb shell am start -a android.intent.action.MAIN -n com.android.browser/.BrowserActivity
  #adb shell am start -a android.intent.action.MAIN -n org.libsdl.app/org.libsdl.app.SDLActivity
  : ${1?an argument is required}
  adb shell am start -a android.intent.action.MAIN -n "$1"
}
function mybash-android-restart-adb (){
  sudo adb kill-server && sudo adb start-server
}

function mybash-android-get-ip(){
  adb shell netcfg
  adb shell ifconfig wlan0
}

function mybash-android-enable-stdout-stderr-output(){
  adb shell stop
  adb shell setprop log.redirect-stdio true
  adb shell start
}

function mybash-android-get-printscreen (){
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
}

function mybash-android-installed-package (){
  : ${1?an argument is required}
  adb shell pm list packages | grep ginga
}

function mybash-android-uninstall-package() {
  # adb uninstall org.libsdl.app
  : ${1?an argument is required}
  adb uninstall $1
}
function mybash-android-install-package() {
  : ${1?an argument is required}
  adb install $1
}

###############################################################################
# folder functions
###############################################################################

function mybash-folder-size() {
  du -ahd 1| sort -h
}

function mybash-folder-delete-latex-files () {
  find -print0 -iname "*-converted-to.pdf" -or -iname "*.aux" -or -iname "*.log" -or -iname "*.nav" -or -iname "*.out" -or -iname "*.snm" "*.synctex.gz" -or -iname "*.toc" | xargs rm
}

function mybash-folder-delete-cmake-files() {
  rm -rf CMakeFiles/ CMakeCache.txt cmake-install.cmake  Makefile CPack* CPack* CTest* "*.cbp"
}

function mybash-folder-delete-binary-files() {
  find -print0 -iname "*.a" -or -iname "*.o" -or -iname "*.so" -or -iname "*.Plo" -or -iname "*.la" -or -iname "*.log" -or -iname "*.tmp"| xargs rm
}

function mybash-folder-find-cpp-files() {
  find . -print0 -iname "*.h" -or -iname "*.cc" -or -iname "*.cpp" -or -iname "*.c"
}

function mybash-folder-find-autotools-files() {
  find . -print0 -iname "*.am" -or -iname "*.ac"
}

###############################################################################
# image functions
###############################################################################

function mybash-image-reconize-text() {
  : ${1?an argument is required}
  tesseract -l eng "$1"  "$1.txt"
}

function mybash-imagem-compress() {
  : ${1?an argument is required}
  pngquant "$1"   --force --quality=70-80 -o "compressed-$1"
}

function mybash-imagem-compress2() {
  : ${1?an argument is required}
  jpegoptim -d . $1.jpeg
}

###############################################################################
# pdf functions
###############################################################################

function mybash-pdf-remove-password() {
  : ${1?an argument is required}
  qpdf --decrypt "$1"  "unlocked-$1"
}

function mybash-pdf-remove-watermark() {
  : ${1?an argument is required}
  sed -e "s/THISISTHEWATERMARK/ /g" < "$1"  > nowatermark.pdf
  pdftk nowatermark.pdf output repaired.pdf
  mv repaired.pdf nowatermark.pdf
}

function mybash-pdf-compress() {
  : ${1?an argument is required}
  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$1-compressed.pdf  $1
}


function mybash-pdf-convert-to() {
  : ${1?an argument is required}
  soffice --headless --convert-to pdf "$1"
}

###############################################################################
# rename functions
###############################################################################

function mybash-rename-lowercase-dash() {
  : ${1?an argument is required}
  rename 'y/A-Z/a-z/;s/_/-/g;s/\./-/g;s/ /-/g;s/---/-/g;s/-pdf/.pdf/g' "$@" &> /dev/null
}

###############################################################################
# network functions
###############################################################################

function mybash-network-arp-scan() {
  sudo arp-scan 139.82.95.26/24
}

###############################################################################
# virtualbox functions
###############################################################################

function mybash-virtualbox-compact() {
  : ${1?an argument is required}
  #VBoxManage modifyhd /opt/win7/win7.vdi compact
  VBoxManage modifyhd "$1" compact
}

function mybash-virtualbox-resize() {
  : ${1?an argument is required}
  #VBoxManage modifyhd /opt/win7/win7.vdi --resize 200000
  VBoxManage modifyhd "$1" --resize 200000
}

###############################################################################
# user functions
###############################################################################

function mybash-user-reload-bashrc() {
  source ~/.bashrc
}

function mybash-user-fix-ssh-permissions() {
  sudo chmod  700 ~/.ssh/ &&\
  sudo chmod  755 ~/.ssh/* &&\
  sudo chmod  600 ~/.ssh/id_rsa &&\
  sudo chmod  644 ~/.ssh/id_rsa.pub
}

function mybash-user-send-ssh-keys() {
  : ${1?an argument is required}
  ssh "$1" 'cat - >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
}

###############################################################################
# vscode functions
###############################################################################

function mybash-vscode-run-as-root() {
  : ${1?an argument is required}
  sudo code --user-data-dir="~/.vscode" "$1"
}

function mybash-vscode-install-packages(){
  PKGS_TO_INSTALL=""
  INSTALLED_LIST="$(code --list-extensions)"
  for i in "$@"; do
    # echo $i
    echo "$INSTALLED_LIST" | grep "^$i" &> /dev/null
    if test $? != 0 ; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
  if test -n "$PKGS_TO_INSTALL"; then
    for i in $PKGS_TO_INSTALL; do
      code --install-extension $i
    done
  fi
}

###############################################################################
# gnome functions
###############################################################################

function mybash-gnome-reset-keybindings() {
  # gsettings list-schemas | grep keybindings | sort | xargs -L 1 echo gsettings reset-recursively
  gsettings reset-recursively org.gnome.mutter.keybindings
  gsettings reset-recursively org.gnome.mutter.wayland.keybindings
  gsettings reset-recursively org.gnome.desktop.wm.keybindings
  gsettings reset-recursively org.gnome.shell.keybindings
  gsettings reset-recursively org.gnome.settings-daemon.plugins.media-keys
}

function mybash-gnome-update-default-apps() {
  sudo update-desktop-database /usr/share/gnome/applications  /usr/share/applications /usr/local/share/applications, /var/lib/snapd/desktop/applications
}

function mybash-gnome-background-screensaver-black() {
  gsettings set org.gnome.desktop.background primary-color "#000000"
  gsettings set org.gnome.desktop.background secondary-color "#000000"
  gsettings set org.gnome.desktop.background color-shading-type "solid"
  gsettings set org.gnome.desktop.background picture-uri ''
  gsettings set org.gnome.desktop.screensaver primary-color "#000000"
  gsettings set org.gnome.desktop.screensaver secondary-color "#000000"
  gsettings set org.gnome.desktop.screensaver color-shading-type "solid"
  gsettings set org.gnome.desktop.screensaver picture-uri ''
}       

function mybash-gnome-version() {
  gnome-shell --version
  gnome-terminal --version
  gnome-text-editor  --version
}

function mybash-gnome-restart() {
  sudo /etc/init.d/gdm3 restart
}

###############################################################################
# vlc functions
###############################################################################

function mybash-vlc-youtube-playlist-extension(){
  wget https://dl.opendesktop.org/api/files/download/id/1473753829/149909-playlist_youtube.lua  -P /tmp/
  sudo install /tmp/149909-playlist_youtube.lua /usr/lib/vlc/lua/playlist/
}

###############################################################################
# system functions
###############################################################################

function mybash-system-list-gpu() {
  lspci -nn | grep -E 'VGA|Display'
}

###############################################################################
# node functions
###############################################################################

function mybash-node-install-packages() {
  log-msg "install npm packages"
  if test ! -f /usr/bin/node; then
    sudo ln -s /usr/bin/nodejs /usr/bin/node
  fi
  NPM_PKGS_TO_INSTALL=""
  for i in "$@"; do
    npm list -g $i &> /dev/null
    if test $? != 0 ; then
      NPM_PKGS_TO_INSTALL="$NPM_PKGS_TO_INSTALL $i"
    fi
  done
  echo "NPM_PKGS_TO_INSTALL=$NPM_PKGS_TO_INSTALL"
  if test -n "$NPM_PKGS_TO_INSTALL"; then
    if test -f pakcage.json;then cd /tmp/; fi 
      sudo -H npm install -g $NPM_PKGS_TO_INSTALL
      sudo -H npm update
    if test -f pakcage.json;then cd -; fi
  fi  
}


###############################################################################
# python functions
###############################################################################

function mybash-python-install-packages() {
  log-msg "install pip packages"
  sudo -H pip install --upgrade pip
  PIP_PKGS_TO_INSTALL=""
  for i in "$@"; do
    pip show $i &> /dev/null
    if test $? != 0 ; then
      PIP_PKGS_TO_INSTALL="$PIP_PKGS_TO_INSTALL $i"
    fi
  done
  echo "PIP_PKGS_TO_INSTALL=$PIP_PKGS_TO_INSTALL"
  if test -n "$PIP_PKGS_TO_INSTALL"; then
    sudo -H pip install $PIP_PKGS_TO_INSTALL
  fi
}

###############################################################################
# deb functions
###############################################################################
function mybash-deb-upgrade(){
  log-msg "upgrade deb packages"
  sudo apt-get -y update
  sudo apt-get -y upgrade
}

function mybash-deb-install-packages(){
  log-msg "install deb packages"
  PKGS_TO_INSTALL=""
  for i in "$@"; do
    dpkg --status "$i" &> /dev/null
    if test $? != 0 ; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
  if test -n "$PKGS_TO_INSTALL"; then
    sudo apt-get install -y $PKGS_TO_INSTALL
  fi
}

function mybash-deb-clean(){
  log-msg "apt-get clean autoclean autoremove"
  sudo apt-get -y remove --purge
  sudo apt-get -y -f install
  sudo apt-get -y clean
  sudo apt-get -y autoclean
  sudo apt-get -y autoremove
}

function mybash-deb-remove-packages(){
  log-msg "remove deb packages"

  PKGS_TO_REMOVE=""
  for i in "$@"; do
    dpkg --status "$i" &> /dev/null
    if test $? -eq 0 ; then
      PKGS_TO_REMOVE="$PKGS_TO_REMOVE $i"
    fi
  done
  echo "PKGS_TO_REMOVE=$PKGS_TO_REMOVE"
  if test -n "$PKGS_TO_REMOVE"; then
    sudo apt-get remove -y --purge $PKGS_TO_REMOVE
  fi
}

function mybash-deb-remove-orphan-packages(){
  log-msg "remove orphan deb packages"

  PKGS_ORPHAN_TO_REMOVE=""
  for i in $(deborphan); do
    FOUND_EXCEPTION=false
    for j in "$@"; do
      if test "$i" = "$j" ;then
        FOUND_EXCEPTION=true
        break
      fi;
    done;
    if ! $FOUND_EXCEPTION; then
      PKGS_ORPHAN_TO_REMOVE="$PKGS_ORPHAN_TO_REMOVE $i"
    fi
  done
  echo "PKGS_ORPHAN_TO_REMOVE=$PKGS_ORPHAN_TO_REMOVE"
  if test -n "$PKGS_ORPHAN_TO_REMOVE"; then
    sudo apt-get remove -y --purge $PKGS_ORPHAN_TO_REMOVE
  fi
}

function mybash-deb-wget-install(){
  : ${1?an argument is required}
  DEB_NAME=$(basename $1)
  if test ! -f /tmp/$DEB_NAME; then 
    wget $1 -P /tmp/; 
  fi
  sudo dpkg -i /tmp/$DEB_NAME
}

###############################################################################
# wget functions
###############################################################################
mybash-wget-extract-to(){
  : ${1?an argument is required}
  : ${2? an second argument is required}
  FILE_NAME_ORIG=$(basename $1)
  FILE_NAME=$(echo $FILE_NAME_ORIG | sed -e's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
  FILE_EXTENSION=${FILE_NAME##*.}

  if test ! -f /tmp/$FILE_NAME; then 
    log-msg "fetching $FILE_NAME"
    wget $1 -P /tmp/
  fi
  log-msg "extracting $FILE_NAME"
  case $FILE_EXTENSION in
    gz) # consider tar.gz
      tar -xf /tmp/$FILE_NAME -C $2;;
    bz2) # consider tar.bz2
      tar -xjf /tmp/$FILE_NAME -C $2;;
    zip)
      unzip /tmp/$FILE_NAME -d $2/;;
  esac
}