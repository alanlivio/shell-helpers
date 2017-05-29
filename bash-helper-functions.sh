#!/bin/bash

###############################################################################
# Bash helper functions (github.com/alanlivio/bash-helper-functions)
# update by: wget https://raw.githubusercontent.com/alanlivio/bash-helper-functions/master/bash-helper-functions.sh
###############################################################################

###############################################################################
# variables
###############################################################################

case "$(uname -s)" in
  Darwin) IS_MAC=1 ;;
  Linux) IS_LINUX=1 ;;
  CYGWIN* | MINGW32* | MSYS*) IS_WINDOWS=1 ;;
esac

###############################################################################
# log functions 
###############################################################################

function hfunc-log-print() {
  echo -e "$1" | fold -w100 -s | sed '2~1s/^/  /'
}

function hfunc-log-error() {
  hfunc-log-print "\033[00;31m---> $* \033[00m"
}

function hfunc-log-msg() {
  hfunc-log-print "\033[00;33m---> $* \033[00m"
}

function hfunc-log-done() {
  hfunc-log-print "\033[00;32m---> done\033[00m"
}

function hfunc-log-ok() {
  hfunc-log-print "\033[00;32m---> ok\033[00m"
}

function hfunc-log-try() {
  "$@"
  if test $? -ne 0; then hfunc-log-error "$1" && exit 1; fi
}

###############################################################################
# test functions
###############################################################################

function hfunc-test-exist-command() {
  if ! type "$1" &>/dev/null; then
    hfunc-log-error "$1 not found."
    return 1
  else
    return 0
  fi
}

###############################################################################
# audio functions
###############################################################################

function hfunc-audio-create-empty() {
  # gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location=file.mp3
  : ${1?"Usage: ${FUNCNAME[0]} [audio_output]"}

  gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location="$1"
}

function hfunc-audio-compress() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}

  lame -b 32 "$1".mp3 compressed"$1".mp3
}

###############################################################################
# video functions
###############################################################################

function hfunc-video-create-by-image() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}

  ffmpeg -loop_input -i "$1".png -t 5 "$1".mp4
}

function hfunc-video-cut() {
  # e.g. ffmpeg -i video-cuted.mp4 -vcodec copy -acodec copy -ss 00:16:03 -t 00:09:34 -f mp4 "video.mp4"
  : ${3?"Usage: ${FUNCNAME[0]} [video] [begin_time] [end_time]"}

  ffmpeg -i $1 -vcodec copy -acodec copy -ss $2 -t $3 -f mp4 cuted-$1
}

function hfunc-video-gst-side-by-side-test() {
  gst-launch-1.0 compositor name=comp sink_1::xpos=640 ! videoconvert ! ximagesink videotestsrc pattern=snow ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" ! timeoverlay ! queue2 ! comp. videotestsrc pattern=smpte ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! timeoverlay ! queue2 ! comp.
}

function hfunc-video-gst-side-by-side-args() {
  : ${2?"Usage: ${FUNCNAME[0]} [video1] [video2]"}

  gst-launch-1.0 compositor name=comp sink_1::xpos=640 ! ximagesink filesrc location=$1 ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" ! decodebin ! videoconvert ! comp. filesrc location=$2 ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! decodebin ! videoconvert ! comp.
}

###############################################################################
# pygmentize functions
###############################################################################

function hfunc-pygmentize-folder-xml-files-by-extensions-to-jpeg() {
  : ${1?"Usage: ${FUNCNAME[0]} [folder]"}

  find . -maxdepth 1 -name "*.$1" | while read -r i; do
    pygmentize -f jpeg -l xml -o $i.jpg $i
  done
}

function hfunc-pygmentize-folder-xml-files-by-extensions-to-rtf() {
  : ${1?"Usage: ${FUNCNAME[0]} [folder]"}

  find . -maxdepth 1 -name "*.$1" | while read -r i; do
    pygmentize -f jpeg -l xml -o $i.jpg $i
    pygmentize -P fontsize=16 -P fontface=consolas -l -o $i.rtf $i
  done
}

function hfunc-pygmentize-folder-xml-files-by-extensions-to-html() {
  : ${1?"Usage: ${FUNCNAME[0]} ARGUMENT"}
  hfunc-test-exist-command pygmentize

  find . -maxdepth 1 -name "*.$1" | while read -r i; do
    pygmentize -O full,style=default -f html -l xml -o $i.html $i
  done
}

###############################################################################
# gcc functions
###############################################################################

function hfunc-gcc-headers() {
  echo | gcc -Wp,-v -x c++ - -fsyntax-only
}

###############################################################################
# gdb functions
###############################################################################

function hfunc-gdb-run-bt() {
  : ${1?"Usage: ${FUNCNAME[0]} [program]"}

  gdb -batch -ex=r -ex=bt --args "$1"
}

function hfunc-gdb-run-bt-all-threads() {
  : ${1?"Usage: ${FUNCNAME[0]} [program]"}

  gdb -batch -ex=r -ex="thread apply all bt" --args "$1"
}

###############################################################################
# git functions
###############################################################################

function hfunc-git-create-gitignore() {
  : ${1?"Usage: ${FUNCNAME[0]} [contexts,..]"}

  curl -L -s "https://www.gitignore.io/api/$1"
}

function hfunc-git-create-gitignore-essentials() {
  hfunc-git-create-gitignore code,eclipse,executable,git,intellij,linux,notepadpp,osx,sublimetext,vim,windows,xcode
}

function hfunc-git-create-gitignore-javascript() {
  hfunc-git-create-gitignore node,bower,grunt
}

function hfunc-git-create-gitignore-cpp() {
  hfunc-git-create-gitignore c,c++,qt,autotools,make,ninja,cmake
}

function hfunc-git-uninstall-reset-clean() {
  find -iname .git | while read -r i; do
    cd "$(dirname $i)" || exit
    make uninstall
    git reset --hard
    git clean -df
    cd -
  done
}

function hfunc-git-commit-formated() {
  echo -e "\n" >/tmp/commit.txt
  for i in $(git status -s | cut -c4-); do
    echo -e "* $i: Likewise." >>/tmp/commit.txt
  done
  git commit -t /tmp/commit.txt
}

function hfunc-git-list-large-files() {
  git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -3
}

###############################################################################
# editors functions
###############################################################################

function hfunc-qtcreator-project-from-git() {
  project_name="${PWD##*/}"
  touch "$project_name.config"
  echo -e "[General]\n" >"$project_name.creator"
  echo -e "src\n" >"$project_name.includes"
  git ls-files >"$project_name.files"
}

function hfunc-eclipse-list-installed() {
  /opt/eclipse/eclipse \
    -consolelog -noSplash \
    -application org.eclipse.equinox.p2.director \
    -listInstalledRoots
}

###############################################################################
# android functions
###############################################################################

function hfunc-android-start-activity() {
  #adb shell am start -a android.intent.action.MAIN -n com.android.browser/.BrowserActivity
  #adb shell am start -a android.intent.action.MAIN -n org.libsdl.app/org.libsdl.app.SDLActivity
  : ${1?"Usage: ${FUNCNAME[0]} [activity]"}

  adb shell am start -a android.intent.action.MAIN -n "$1"
}

function hfunc-android-restart-adb() {
  sudo adb kill-server && sudo adb start-server
}

function hfunc-android-get-ip() {
  adb shell netcfg
  adb shell ifconfig wlan0
}

function hfunc-android-enable-stdout-stderr-output() {
  adb shell stop
  adb shell setprop log.redirect-stdio true
  adb shell start
}

function hfunc-android-get-printscreen() {
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
}

function hfunc-android-installed-package() {
  : ${1?"Usage: ${FUNCNAME[0]} [package]"}

  adb shell pm list packages | grep $1
}

function hfunc-android-uninstall-package() {
  # adb uninstall org.libsdl.app
  : ${1?"Usage: ${FUNCNAME[0]} [package]"}

  adb uninstall $1
}
function hfunc-android-install-package() {
  : ${1?"Usage: ${FUNCNAME[0]} [package]"}

  adb install $1
}

###############################################################################
# folder functions
###############################################################################

function hfunc-folder-size() {
  du -ahd 1 | sort -h
}

function hfunc-folder-delete-latex-files() {
  find -print0 -iname "*-converted-to.pdf" -or -iname "*.aux" -or -iname "*.log" -or -iname "*.nav" -or -iname "*.out" -or -iname "*.snm" "*.synctex.gz" -or -iname "*.toc" | xargs rm
}

function hfunc-folder-delete-cmake-files() {
  rm -rf CMakeFiles/ CMakeCache.txt cmake-install.cmake Makefile CPack* CPack* CTest* "*.cbp"
}

function hfunc-folder-delete-binary-files() {
  find -print0 -iname "*.a" -or -iname "*.o" -or -iname "*.so" -or -iname "*.Plo" -or -iname "*.la" -or -iname "*.log" -or -iname "*.tmp" | xargs rm
}

function hfunc-folder-find-cpp-files() {
  find . -print0 -iname "*.h" -or -iname "*.cc" -or -iname "*.cpp" -or -iname "*.c"
}

function hfunc-folder-find-autotools-files() {
  find . -print0 -iname "*.am" -or -iname "*.ac"
}

###############################################################################
# image functions
###############################################################################

function hfunc-image-reconize-text() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}

  tesseract -l eng "$1" "$1.txt"
}

function hfunc-imagem-compress() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}
  hfunc-test-exist-command pngquant

  pngquant "$1" --force --quality=70-80 -o "compressed-$1"
}

function hfunc-imagem-compress2() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}
  hfunc-test-exist-command jpegoptim

  jpegoptim -d . $1.jpeg
}

###############################################################################
# pdf functions
###############################################################################

function hfunc-pdf-remove-password() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}
  hfunc-test-exist-command qpdf

  qpdf --decrypt "$1" "unlocked-$1"
}

function hfunc-pdf-remove-watermark() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}

  sed -e "s/THISISTHEWATERMARK/ /g" <"$1" >nowatermark.pdf
  pdftk nowatermark.pdf output repaired.pdf
  mv repaired.pdf nowatermark.pdf
}

function hfunc-pdf-compress() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}

  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$1-compressed.pdf $1
}

function hfunc-pdf-convert-to() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}

  soffice --headless --convert-to pdf "$1"
}

###############################################################################
# rename functions
###############################################################################

function hfunc-rename-lowercase-dash() {
  : ${1?"Usage: ${FUNCNAME[0]} [file]"}

  rename 'y/A-Z/a-z/;s/_/-/g;s/\./-/g;s/ /-/g;s/---/-/g;s/-pdf/.pdf/g' "$@" &>/dev/null
}

###############################################################################
# network functions
###############################################################################

function hfunc-network-ip() {
  echo "$(hostname -I | cut -d' ' -f1)"
}

function hfunc-network-arp-scan() {
  ip=$(hfunc-network-ip)
  sudo nmap --host-timeout 1s --script smb-os-discovery.nse -RsP --version-light --system-dns $ip/24 | grep -e 'Nmap scan report' -e 'Host is' -e 'MAC Address:' | sed 's/Nmap scan/----------------------------------------\nNmap scan/'
}

###############################################################################
# virtualbox functions
###############################################################################

function hfunc-virtualbox-compact() {
  : ${1?"Usage: ${FUNCNAME[0]} [vdi_file]"}

  VBoxManage modifyhd "$1" compact
}

function hfunc-virtualbox-resize-to-2gb() {
  : ${1?"Usage: ${FUNCNAME[0]} [vdi_file"}

  VBoxManage modifyhd "$1" --resize 200000
}

###############################################################################
# user functions
###############################################################################

function hfunc-user-reload-bashrc() {
  source ~/.bashrc
}

function hfunc-user-fix-ssh-permissions() {
  sudo chmod 700 ~/.ssh/ \
    && sudo chmod 755 ~/.ssh/* \
    && sudo chmod 600 ~/.ssh/id_rsa \
    && sudo chmod 644 ~/.ssh/id_rsa.pub
}

function hfunc-user-send-ssh-keys() {
  : ${1?"Usage: ${FUNCNAME[0]} [user]"}

  ssh "$1" 'cat - >> ~/.ssh/authorized_keys' <~/.ssh/id_rsa.pub
}

###############################################################################
# vscode functions
###############################################################################

function hfunc-vscode-run-as-root() {
  : ${1?"Usage: ${FUNCNAME[0]} [folder]"}

  sudo code --user-data-dir="~/.vscode" "$1"
}

function hfunc-vscode-install-packages() {
  : ${1?"Usage: ${FUNCNAME[0]} [package_list]"}

  PKGS_TO_INSTALL=""
  INSTALLED_LIST="$(code --list-extensions)"
  for i in "$@"; do
    # echo $i
    echo "$INSTALLED_LIST" | grep "^$i" &>/dev/null
    if test $? != 0; then
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

function hfunc-gnome-reset-keybindings() {
  gsettings reset-recursively org.gnome.mutter.keybindings
  gsettings reset-recursively org.gnome.mutter.wayland.keybindings
  gsettings reset-recursively org.gnome.desktop.wm.keybindings
  gsettings reset-recursively org.gnome.shell.keybindings
  gsettings reset-recursively org.gnome.settings-daemon.plugins.media-keys
}

function hfunc-gnome-update-database() {
  sudo update-desktop-database -v /usr/share/applications ~/.local/share/applications ~/.gnome/apps/
  sudo update-icon-caches -v /usr/share/icons/ ~/.local/share/icons/
}

function hfunc-gnome-background-screensaver-black() {
  gsettings set org.gnome.desktop.background primary-color "#000000"
  gsettings set org.gnome.desktop.background secondary-color "#000000"
  gsettings set org.gnome.desktop.background color-shading-type "solid"
  gsettings set org.gnome.desktop.background picture-uri ''
  gsettings set org.gnome.desktop.screensaver primary-color "#000000"
  gsettings set org.gnome.desktop.screensaver secondary-color "#000000"
  gsettings set org.gnome.desktop.screensaver color-shading-type "solid"
  gsettings set org.gnome.desktop.screensaver picture-uri ''
}

function hfunc-gnome-show-version() {
  gnome-shell --version
  mutter --version | head -n 1
  gnome-terminal --version
  gnome-text-editor --version
}

function hfunc-gnome-gdm-restart() {
  sudo /etc/init.d/gdm3 restart
}

function hfunc-gnome-settings-reset() {
  : ${1?"Usage: ${FUNCNAME[0]} [scheme]"}

  gsettings reset-recursively $1
}

function hfunc-gnome-settings-save-to-file() {
  : ${2?"Usage: ${FUNCNAME[0]} [scheme] [file]"}

  gsettings list-recursively $1 | sed -e 's/@as //g' -e 's/, /,/g' >$2
}

function hfunc-gnome-settings-load-from-file() {
  : ${1?"Usage: ${FUNCNAME[0]} [file]"}

  sed -e 's/@as //g' -e 's/, /,/g' $1 | while read -r i; do
    gsettings set $i
  done
}

function hfunc-gnome-settings-diff-scheme-and-file() {
  : ${2?"Usage: ${FUNCNAME[0]} [scheme] [file]"}

  TMP_FILE=/tmp/gnome-settings-diff
  gsettings list-recursively $1 | sed -e 's/@as //g' -e 's/, /,/g' >$TMP_FILE
  diff $TMP_FILE $2
}

###############################################################################
# vlc functions
###############################################################################

function hfunc-vlc-youtube-playlist-extension() {
  wget https://dl.opendesktop.org/api/files/download/id/1473753829/149909-playlist_youtube.lua -P /tmp/
  sudo install /tmp/149909-playlist_youtube.lua /usr/lib/vlc/lua/playlist/
}

###############################################################################
# system functions
###############################################################################

function hfunc-system-list-gpu() {
  lspci -nn | grep -E 'VGA|Display'
}

###############################################################################
# node functions
###############################################################################

function hfunc-node-install-packages() {
  hfunc-log-msg "install npm packages"
  : ${1?"Usage: ${FUNCNAME[0]} [npm_packages_list]"}

  NPM_PKGS_TO_INSTALL=""
  for i in "$@"; do
    npm list -g $i &>/dev/null
    if test $? != 0; then
      NPM_PKGS_TO_INSTALL="$NPM_PKGS_TO_INSTALL $i"
    fi
  done
  echo "NPM_PKGS_TO_INSTALL=$NPM_PKGS_TO_INSTALL"
  if test -n "$NPM_PKGS_TO_INSTALL"; then
    if test -f pakcage.json; then cd /tmp/; fi
    sudo -H npm install -g $NPM_PKGS_TO_INSTALL
    sudo -H npm update
    if test -f pakcage.json; then cd -; fi
  fi
}

###############################################################################
# python functions
###############################################################################

function hfunc-python-version() {
  python -V 2>&1 | grep -Po '(?<=Python ).{1}'
}

function hfunc-python-install-packages() {
  hfunc-log-msg "install pip packages"
  : ${1?"Usage: ${FUNCNAME[0]} [pip3_packages_list]"}

  sudo -H pip3 install --no-cache-dir --disable-pip-version-check --upgrade pip &>/dev/null
  PIP_PKGS_TO_INSTALL="" 
  for i in "$@"; do
    pip3 show $i &>/dev/null
    if test $? != 0; then
      PIP_PKGS_TO_INSTALL="$PIP_PKGS_TO_INSTALL $i"
    fi
  done
  echo "PIP_PKGS_TO_INSTALL=$PIP_PKGS_TO_INSTALL"
  if test -n "$PIP_PKGS_TO_INSTALL"; then
    sudo -H pip3 install --no-cache-dir --disable-pip-version-check $PIP_PKGS_TO_INSTALL
  fi
  sudo -H pip3 install -U "$@" &>/dev/null
}

###############################################################################
# deb functions
###############################################################################

function hfunc-deb-upgrade() {
  hfunc-log-msg "upgrade deb packages"

  sudo apt-get -y update
  sudo apt-get -y upgrade
}

function hfunc-deb-install-packages() {
  hfunc-log-msg "install deb packages"
  : ${1?"Usage: ${FUNCNAME[0]} [deb_packages_list]"}

  PKGS_TO_INSTALL=""
  for i in "$@"; do
    dpkg --status "$i" &>/dev/null
    if test $? != 0; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
  if test -n "$PKGS_TO_INSTALL"; then
    sudo apt-get install -y $PKGS_TO_INSTALL
  fi
}

function hfunc-deb-clean() {
  hfunc-log-msg "apt-get clean autoclean autoremove"

  sudo apt-get -y remove --purge
  sudo apt-get -y -f install
  sudo apt-get -y clean
  sudo apt-get -y autoclean
  sudo apt-get -y autoremove
}

function hfunc-deb-remove-packages() {
  hfunc-log-msg "remove deb packages"
  : ${1?"Usage: ${FUNCNAME[0]} [deb_packages_list]"}

  PKGS_TO_REMOVE=""
  for i in "$@"; do
    dpkg --status "$i" &>/dev/null
    if test $? -eq 0; then
      PKGS_TO_REMOVE="$PKGS_TO_REMOVE $i"
    fi
  done
  echo "PKGS_TO_REMOVE=$PKGS_TO_REMOVE"
  if test -n "$PKGS_TO_REMOVE"; then
    sudo apt-get remove -y --purge $PKGS_TO_REMOVE
  fi
}

function hfunc-deb-remove-orphan-packages() {
  hfunc-log-msg "remove orphan deb packages"
  : ${1?"Usage: ${FUNCNAME[0]} [deb_packages_list]"}

  PKGS_ORPHAN_TO_REMOVE=""
  for i in $(deborphan); do
    FOUND_EXCEPTION=false
    for j in "$@"; do
      if test "$i" = "$j"; then
        FOUND_EXCEPTION=true
        break
      fi
    done
    if ! $FOUND_EXCEPTION; then
      PKGS_ORPHAN_TO_REMOVE="$PKGS_ORPHAN_TO_REMOVE $i"
    fi
  done
  echo "PKGS_ORPHAN_TO_REMOVE=$PKGS_ORPHAN_TO_REMOVE"
  if test -n "$PKGS_ORPHAN_TO_REMOVE"; then
    sudo apt-get remove -y --purge $PKGS_ORPHAN_TO_REMOVE
  fi
}

function hfunc-deb-fetch-install() {
  : ${1?"Usage: ${FUNCNAME[0]} [url]"}

  DEB_NAME=$(basename $1)
  if test ! -f /tmp/$DEB_NAME; then
    wget $1 -P /tmp/
  fi
  sudo dpkg -i /tmp/$DEB_NAME
}

###############################################################################
# fetch functions
###############################################################################

function hfunc-fetch-extract-to() {
  : ${2?"Usage: ${FUNCNAME[0]} [url] [folder]"}

  FILE_NAME_ORIG=$(basename $1)
  FILE_NAME=$(echo $FILE_NAME_ORIG | sed -e's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
  FILE_EXTENSION=${FILE_NAME##*.}

  if test ! -f /tmp/$FILE_NAME; then
    hfunc-log-msg "fetching $FILE_NAME"
    wget $1 -P /tmp/
  fi
  hfunc-log-msg "extracting $FILE_NAME"
  case $FILE_EXTENSION in
    gz) # consider tar.gz
      tar -xf /tmp/$FILE_NAME -C $2
      ;;
    bz2) # consider tar.bz2
      tar -xjf /tmp/$FILE_NAME -C $2
      ;;
    zip)
      unzip /tmp/$FILE_NAME -d $2/
      ;;
  esac
}

function hfunc-fetch-youtube-playlist() {
  : ${1?"Usage: ${FUNCNAME[0]} [playlist_url]"}

  youtube-dl "$1" --yes-playlist --extract-audio --audio-format "mp3" --audio-quality 0 --ignore-errors --embed-thumbnail --output "%(title)s.%(ext)s" --metadata-from-title "%(artist)s - %(title)s" --add-metadata 
}

###############################################################################
# list functions
###############################################################################

function hfunc-list-sorted-by-size() {
  du -h | sort -h
}

function hfunc-list-recursive-sorted-by-size() {
  du -ah | sort -h
}

###############################################################################
# x11 functions
###############################################################################

function hfunc-x11-properties-of-window() {
  xprop | grep "^WM_"
}
