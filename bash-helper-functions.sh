#!/bin/bash

# ---------------------------------------
# Bash helper functions.
# site: github.com/alanlivio/bash-helper-functions
# ---------------------------------------

# ---------------------------------------
# variables
# ---------------------------------------

case "$(uname -s)" in
Darwin) IS_MAC=1 ;;
Linux) IS_LINUX=1 ;;
CYGWIN* | MINGW* | MSYS*) IS_WINDOWS=1 ;;
esac

if test $IS_LINUX; then
  case "$(uname -r)" in
  *43-Microsoft)
    IS_LINUX=0
    IS_WINDOWS=1
    ;;
  *) IS_LINUX=1 ;;
  esac
fi

SCRIPT_NAME=bash-helper-functions.sh
SCRIPT_URL=raw.githubusercontent.com/alanlivio/bash-helper-functions/master/$SCRIPT_NAME

# ---------------------------------------
# script functions
# ---------------------------------------

function bhf-script-update() {
  if test -f $SCRIPT_NAME; then
      rm $SCRIPT_NAME;
  fi;
  wget $SCRIPT_URL $SCRIPT_NAME
}

# ---------------------------------------
# log functions
# ---------------------------------------

function bhf-log-print() {
  echo -e "$1" | fold -w100 -s | sed '2~1s/^/  /'
}

function bhf-log-error() {
  bhf-log-print "\033[00;31m-- $* \033[00m"
}

function bhf-log-msg() {
  bhf-log-print "\033[00;33m-- $* \033[00m"
}

function bhf-log-msg-2nd() {
  bhf-log-print "\033[00;33m--   $* \033[00m"
}

function bhf-log-done() {
  bhf-log-print "\033[00;32m-- done\033[00m"
}

function bhf-log-ok() {
  bhf-log-print "\033[00;32m-- ok\033[00m"
}

function bhf-log-try() {
  "$@"
  if test $? -ne 0; then bhf-log-error "$1" && exit 1; fi
}

# ---------------------------------------
# test functions
# ---------------------------------------

function bhf-test-exist-command() {
  if ! type "$1" &>/dev/null; then
    bhf-log-error "$1 not found."
    return 1
  else
    return 0
  fi
}

# ---------------------------------------
# audio functions
# ---------------------------------------

function bhf-audio-create-empty() {
  # gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location=file.mp3
  : ${1?"Usage: ${FUNCNAME[0]} [audio_output]"}

  gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location="$1"
}

function bhf-audio-compress() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}

  lame -b 32 "$1".mp3 compressed"$1".mp3
}

# ---------------------------------------
# video functions
# ---------------------------------------

function bhf-video-create-by-image() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}

  ffmpeg -loop_input -i "$1".png -t 5 "$1".mp4
}

function bhf-video-cut() {
  # e.g. ffmpeg -i video-cuted.mp4 -vcodec copy -acodec copy -ss 00:16:03 -t 00:09:34 -f mp4 "video.mp4"
  : ${3?"Usage: ${FUNCNAME[0]} [video] [begin_time] [end_time]"}

  ffmpeg -i $1 -vcodec copy -acodec copy -ss $2 -t $3 -f mp4 cuted-$1
}

# ---------------------------------------
# gst functions
# ---------------------------------------

function bhf-gst-side-by-side-test() {
  gst-launch-1.0 compositor name=comp sink_1::xpos=640 ! videoconvert ! ximagesink videotestsrc pattern=snow ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" ! timeoverlay ! queue2 ! comp. videotestsrc pattern=smpte ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! timeoverlay ! queue2 ! comp.
}

function bhf-gst-side-by-side-args() {
  : ${2?"Usage: ${FUNCNAME[0]} [video1] [video2]"}

  gst-launch-1.0 compositor name=comp sink_1::xpos=640 ! ximagesink filesrc location=$1 ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" ! decodebin ! videoconvert ! comp. filesrc location=$2 ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! decodebin ! videoconvert ! comp.
}

# ---------------------------------------
# pkg-config functions
# ---------------------------------------

bhf-pkg-config-find() {
  : ${1?"Usage: ${FUNCNAME[0]} [pkg_name]"}
  pkg-config --list-all | grep --color=auto $1
}

function bhf-pkg-config-show() {
  : ${1?"Usage: ${FUNCNAME[0]} [pkg_name]"}
  PKG=$(pkg-config --list-all | grep -w $1 | awk '{print $1;exit}')
  echo 'version:    '"$(pkg-config --modversion $PKG)"
  echo 'provides:   '"$(pkg-config --print-provides $PKG)"
  echo 'requireds:  '"$(pkg-config --print-requires $PKG | awk '{print}' ORS=' ')"
}

# ---------------------------------------
# pygmentize functions
# ---------------------------------------

function bhf-pygmentize-folder-xml-files-by-extensions-to-jpeg() {
  : ${1?"Usage: ${FUNCNAME[0]} [folder]"}

  find . -maxdepth 1 -name "*.xml" | while read -r i; do
    pygmentize -f jpeg -l xml -o $i.jpg $i
  done
}

function bhf-pygmentize-folder-xml-files-by-extensions-to-rtf() {
  : ${1?"Usage: ${FUNCNAME[0]} [folder]"}

  find . -maxdepth 1 -name "*.xml" | while read -r i; do
    pygmentize -f jpeg -l xml -o $i.jpg $i
    pygmentize -P fontsize=16 -P fontface=consolas -l xml -o $i.rtf $i
  done
}

function bhf-pygmentize-folder-xml-files-by-extensions-to-html() {
  : ${1?"Usage: ${FUNCNAME[0]} ARGUMENT"}
  bhf-test-exist-command pygmentize

  find . -maxdepth 1 -name "*.xml" | while read -r i; do
    pygmentize -O full,style=default -f html -l xml -o $i.html $i
  done
}

# ---------------------------------------
# gcc functions
# ---------------------------------------

function bhf-gcc-headers() {
  echo | gcc -Wp,-v -x c++ - -fsyntax-only
}

# ---------------------------------------
# gdb functions
# ---------------------------------------

function bhf-gdb-run-bt() {
  : ${1?"Usage: ${FUNCNAME[0]} [program]"}

  gdb -ex="set confirm off" -ex="set pagination off" -ex=r -ex=bt --args "$@"
}

function bhf-gdb-run-bt-all-threads() {
  : ${1?"Usage: ${FUNCNAME[0]} [program]"}

  gdb -ex="set confirm off" -ex="set pagination off" -ex=r -ex=bt -ex="thread apply all bt" --args "$@"
}

# ---------------------------------------
# git functions
# ---------------------------------------

function bhf-git-ammend-push-force() {
  git commit -a --amend --no-edit
  git push --force
}

function bhf-git-create-gitignore() {
  : ${1?"Usage: ${FUNCNAME[0]} [contexts,..]"}

  curl -L -s "https://www.gitignore.io/api/$1"
}

function bhf-git-create-gitignore-essentials() {
  bhf-git-create-gitignore code,eclipse,executable,git,intellij,linux,notepadpp,osx,sublimetext,vim,windows,xcode
}

function bhf-git-create-gitignore-javascript() {
  bhf-git-create-gitignore node,bower,grunt
}

function bhf-git-create-gitignore-cpp() {
  bhf-git-create-gitignore c,c++,qt,autotools,make,ninja,cmake
}

function bhf-git-uninstall-reset-clean() {
  find -name .git | while read -r i; do
    cd "$(dirname $i)" || exit
    make uninstall
    git reset --hard
    git clean -df
    cd -
  done
}

function bhf-git-commit-formated() {
  echo -e "\n" >/tmp/commit.txt
  for i in $(git status -s | cut -c4-); do
    echo -e "* $i: Likewise." >>/tmp/commit.txt
  done
  git commit -t /tmp/commit.txt
}

function bhf-git-list-large-files() {
  git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -3
}

# ---------------------------------------
# editors functions
# ---------------------------------------

function bhf-qtcreator-project-from-git() {
  project_name="${PWD##*/}"
  touch "$project_name.config"
  echo -e "[General]\n" >"$project_name.creator"
  echo -e "src\n" >"$project_name.includes"
  git ls-files >"$project_name.files"
}

function bhf-eclipse-list-installed() {
  /opt/eclipse/eclipse \
    -consolelog -noSplash \
    -application org.eclipse.equinox.p2.director \
    -listInstalledRoots
}

# ---------------------------------------
# grub functions
# ---------------------------------------

function bhf-grub-verbose-boot() {
  sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/g" /etc/default/grub
  sudo update-grub2
}

function bhf-grub-splash-boot() {
  sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/g" /etc/default/grub
  sudo update-grub2
}

# ---------------------------------------
# android functions
# ---------------------------------------

function bhf-android-start-activity() {
  #adb shell am start -a android.intent.action.MAIN -n com.android.browser/.BrowserActivity
  #adb shell am start -a android.intent.action.MAIN -n org.libsdl.app/org.libsdl.app.SDLActivity
  : ${1?"Usage: ${FUNCNAME[0]} [activity]"}

  adb shell am start -a android.intent.action.MAIN -n "$1"
}

function bhf-android-restart-adb() {
  sudo adb kill-server && sudo adb start-server
}

function bhf-android-get-ip() {
  adb shell netcfg
  adb shell ifconfig wlan0
}

function bhf-android-enable-stdout-stderr-output() {
  adb shell stop
  adb shell setprop log.redirect-stdio true
  adb shell start
}

function bhf-android-get-printscreen() {
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
}

function bhf-android-installed-package() {
  : ${1?"Usage: ${FUNCNAME[0]} [package]"}

  adb shell pm list packages | grep $1
}

function bhf-android-uninstall-package() {
  # adb uninstall org.libsdl.app
  : ${1?"Usage: ${FUNCNAME[0]} [package]"}

  adb uninstall $1
}
function bhf-android-install-package() {
  : ${1?"Usage: ${FUNCNAME[0]} [package]"}

  adb install $1
}

# ---------------------------------------
# folder functions
# ---------------------------------------

function bhf-folder-info() {
  EXTENSIONS=$(for f in *.*; do printf "%s\n" "${f##*.}"; done | sort -u)
  echo "size="$(du -sh | awk '{print $1;exit}')
  echo "dirs="$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)
  echo -n "files="$(find . -mindepth 1 -maxdepth 1 -type f | wc -l)"("
  for i in $EXTENSIONS; do
    echo -n ".$i="$(find . -mindepth 1 -maxdepth 1 -type f -iname \*\.$i | wc -l)","
  done
  echo ")"
}

function bhf-folder-files-sizes() {
  du -ahd 1 | sort -h
}

# ---------------------------------------
# latex functions
# ---------------------------------------

function bhf-latex-clean() {
  find . -print0 -type f -name "*-converted-to.pdf" -o -name "*.aux" -o -name "*.log" -o -name "*.nav" -o -name "*.out" -o -name "*.bbl" -o -name "*.blg" -o -name "*.lot" -o -name "*.lof" -o -name "*.lol" -o -name "*.tof" -o -name "*.snm" -o -name "*.synctex.gz" -o -name "*.toc" | xargs rm -rf
}

# ---------------------------------------
# cpp functions
# ---------------------------------------

function bhf-cpp-find-code-files() {
  find . -print0 -name "*.h" -o -name "*.cc" -o -name "*.cpp" -o -name "*.c"
}

function bhf-cpp-find-autotools-files() {
  find . -print0 -name "*.am" -o -name "*.ac"
}

function bhf-cpp-delete-binary-files() {
  find . -print0 -type -f -name "*.a" -o -name "*.o" -o -name "*.so" -o -name "*.Plo" -o -name "*.la" -o -name "*.log" -o -name "*.tmp" | xargs rm -rf
}

function bhf-cpp-delete-cmake-files() {
  rm -rf CMakeFiles/ CMakeCache.txt cmake-install.cmake Makefile CPack* CPack* CTest* "*.cbp"
}

# ---------------------------------------
# image functions
# ---------------------------------------

function bhf-image-reconize-text() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}

  tesseract -l eng "$1" "$1.txt"
}

function bhf-imagem-compress() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}
  bhf-test-exist-command pngquant

  pngquant "$1" --force --quality=70-80 -o "compressed-$1"
}

function bhf-imagem-compress2() {
  : ${1?"Usage: ${FUNCNAME[0]} [image]"}
  bhf-test-exist-command jpegoptim

  jpegoptim -d . $1.jpeg
}

# ---------------------------------------
# pdf functions
# ---------------------------------------

function bhf-pdf-remove-password() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}
  bhf-test-exist-command qpdf

  qpdf --decrypt "$1" "unlocked-$1"
}

function bhf-pdf-remove-watermark() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}

  sed -e "s/THISISTHEWATERMARK/ /g" <"$1" >nowatermark.pdf
  pdftk nowatermark.pdf output repaired.pdf
  mv repaired.pdf nowatermark.pdf
}

function bhf-pdf-compress() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}

  gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$1-compressed.pdf $1
}

# ---------------------------------------
# convert functions
# ---------------------------------------

function bhf-convert-to-markdown() {
  : ${1?"Usage: ${FUNCNAME[0]} [file]"}
  pandoc -s $1 -t markdown -o ${1%.*}.md
}

function bhf-convert-to-pdf() {
  : ${1?"Usage: ${FUNCNAME[0]} [pdf]"}
  soffice --headless --convert-to pdf ${1%.*}.pdf
}

# ---------------------------------------
# rename functions
# ---------------------------------------

function bhf-rename-to-lowercase-dash() {
  : ${1?"Usage: ${FUNCNAME[0]} [file]"}
  echo "change to lowercase"
  rename 'y/A-Z/a-z/' "$@" &>/dev/null
  echo "replace '.' and '_' by '-''"
  rename 's/_/-/g;s/\./-/g;s/ /-/g;s/--+/-/g;s/-pdf/.pdf/g' "$@" &>/dev/null
  echo "remove (.*) and [.*]"
  for i in "$@"; do
    mv $i "$(echo $i | sed 's/([^][]*)//g' | sed 's/\[[^][]*\]//g' | sed 's/^-//g' | sed 's/-$//g')" &>/dev/null
  done
}

# ---------------------------------------
# partitions functions
# ---------------------------------------

function bhf-partitions-list() {
  df -h
}

# ---------------------------------------
# network functions
# ---------------------------------------

function bhf-network-open-ports() {
  netstat -tulpn
}

function bhf-network-open-connections() {
  lsof -i
}

function bhf-network-ip() {
  echo "$(hostname -I | cut -d' ' -f1)"
}

function bhf-network-arp-scan() {
  ip=$(bhf-network-ip)
  sudo nmap --host-timeout 1s --script smb-os-discovery.nse -RsP --version-light --system-dns $ip/24 | grep -e 'Nmap scan report' -e 'Host is' -e 'MAC Address:' | sed 's/Nmap scan/----------------------------------------\nNmap scan/'
}

# ---------------------------------------
# virtualbox functions
# ---------------------------------------

function bhf-virtualbox-compact() {
  : ${1?"Usage: ${FUNCNAME[0]} [vdi_file]"}

  VBoxManage modifyhd "$1" compact
}

function bhf-virtualbox-resize-to-2gb() {
  : ${1?"Usage: ${FUNCNAME[0]} [vdi_file"}

  VBoxManage modifyhd "$1" --resize 200000
}

# ---------------------------------------
# user functions
# ---------------------------------------

function bhf-user-reload-bashrc() {
  source ~/.bashrc
}

function bhf-user-permissions-sudo() {
  sudo sh -c 'echo "$USER  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/sudoers-user'
}

function bhf-user-permissions-opt() {
    sudo chown root:root /opt
    sudo adduser $USER root
    newgrp root # update group for user
    sudo chmod -R +775 /opt/
}

function bhf-user-permissions-ssh() {
  sudo chmod 700 ~/.ssh/ \
    && sudo chmod 755 ~/.ssh/* \
    && sudo chmod 600 ~/.ssh/id_rsa \
    && sudo chmod 644 ~/.ssh/id_rsa.pubssh-rsa
}

function bhf-user-send-ssh-keys() {
  : ${1?"Usage: ${FUNCNAME[0]} [user]"}

  ssh "$1" 'cat - >> ~/.ssh/authorized_keys' <~/.ssh/id_rsa.pub
}

# ---------------------------------------
# vscode functions
# ---------------------------------------

function bhf-vscode-run-as-root() {
  : ${1?"Usage: ${FUNCNAME[0]} [folder]"}

  sudo code --user-data-dir="~/.vscode" "$1"
}

function bhf-vscode-install-packages() {
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
  if test ! -z "$PKGS_TO_INSTALL"; then echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"; fi
  if test -n "$PKGS_TO_INSTALL"; then
    for i in $PKGS_TO_INSTALL; do
      code --install-extension $i
    done
  fi
}

function bhf-vscode-uninstall-all-packages() {
  INSTALLED_LIST="$(code --list-extensions)"
  for i in $INSTALLED_LIST; do code --uninstall-extension $i; done
}

# ---------------------------------------
# gnome functions
# ---------------------------------------

function bhf-gnome-reset-keybindings() {
  gsettings reset-recursively org.gnome.mutter.keybindings
  gsettings reset-recursively org.gnome.mutter.wayland.keybindings
  gsettings reset-recursively org.gnome.desktop.wm.keybindings
  gsettings reset-recursively org.gnome.shell.keybindings
  gsettings reset-recursively org.gnome.settings-daemon.plugins.media-keys
}

function bhf-gnome-disble-super-console-key() {
  # remove super+arrow virtual terminal change
  sudo sh -c 'dumpkeys |grep -v cr_Console |loadkeys'
}

function bhf-gnome-disble-super-console-key() {
  # disable tiling
  dconf write /org/gnome/mutter/edge-tiling false
}

function bhf-gnome-reset-tracker() {
  sudo tracker reset --hard
  sudo tracker daemon -s
}

function bhf-gnome-reset-shotwell() {
  rm -rf ~/.cache/shotwell ~/.local/share/shotwell
}

function bhf-gnome-update-desktop-database() {
  sudo update-desktop-database -v /usr/share/applications ~/.local/share/applications ~/.gnome/apps/
}

function bhf-gnome-update-icons() {
  sudo update-icon-caches -v /usr/share/icons/ ~/.local/share/icons/
}

function bhf-gnome-background-screensaver-black() {
  gsettings set org.gnome.desktop.background primary-color "#000000"
  gsettings set org.gnome.desktop.background secondary-color "#000000"
  gsettings set org.gnome.desktop.background color-shading-type "solid"
  gsettings set org.gnome.desktop.background picture-uri ''
  gsettings set org.gnome.desktop.screensaver primary-color "#000000"
  gsettings set org.gnome.desktop.screensaver secondary-color "#000000"
  gsettings set org.gnome.desktop.screensaver color-shading-type "solid"
  gsettings set org.gnome.desktop.screensaver picture-uri ''
}

function bhf-gnome-show-version() {
  gnome-shell --version
  mutter --version | head -n 1
  gnome-terminal --version
  gnome-text-editor --version
}

function bhf-gnome-gdm-restart() {
  sudo /etc/init.d/gdm3 restart
}

function bhf-gnome-settings-reset() {
  : ${1?"Usage: ${FUNCNAME[0]} [scheme]"}

  gsettings reset-recursively $1
}

function bhf-gnome-settings-save-to-file() {
  : ${2?"Usage: ${FUNCNAME[0]} [dconf-dir] [file]"}

  dconf dump $1 >$2
}

function bhf-gnome-settings-load-from-file() {
  : ${1?"Usage: ${FUNCNAME[0]} [dconf-dir] [file]"}

  dconf load $1 <$2
}

function bhf-gnome-settings-diff-actual-and-file() {
  : ${2?"Usage: ${FUNCNAME[0]} [dconf-dir] [file]"}

  TMP_FILE=/tmp/gnome-settings-diff
  bhf-gnome-settings-save-to-file $1 $TMP_FILE
  diff $TMP_FILE $2
}

# ---------------------------------------
# vlc functions
# ---------------------------------------

function bhf-vlc-youtube-playlist-extension() {
  wget --continue https://dl.opendesktop.org/api/files/download/id/1473753829/149909-playlist_youtube.lua -P /tmp/
  sudo install /tmp/149909-playlist_youtube.lua /usr/lib/vlc/lua/playlist/
}

# ---------------------------------------
# system functions
# ---------------------------------------

function bhf-system-list-gpu() {
  lspci -nn | grep -E 'VGA|Display'
}

# ---------------------------------------
# npm functions
# ---------------------------------------

function bhf-npm-install-packages() {
  : ${1?"Usage: ${FUNCNAME[0]} [npm_packages_list]"}

  PKGS_TO_INSTALL=""
  PKGS_INSTALLED=$(npm ls -g --depth 0 2>/dev/null | grep -v UNMET | cut -d' ' -f2 -s | cut -d'@' -f1 | tr '\n' ' ')
  for i in "$@"; do
    FOUND=false
    for j in $PKGS_INSTALLED; do
      if test $i == $j; then
        FOUND=true
        break
      fi
    done
    if ! $FOUND; then PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"; fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then
    echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
    if test -f pakcage.json; then cd /tmp/; fi
    if test $IS_WINDOWS; then
      npm install -g $PKGS_TO_INSTALL
      npm update
    else
      sudo -H npm install -g $PKGS_TO_INSTALL
      sudo -H npm update
    fi
    if test "$(pwd)" == "/tmp"; then cd -; fi
  fi
}

# ---------------------------------------
# ruby functions
# ---------------------------------------

function bhf-ruby-install-packages() {
  : ${1?"Usage: ${FUNCNAME[0]} [npm_packages_list]"}

  PKGS_TO_INSTALL=""
  PKGS_INSTALLED=$(gem list | cut -d' ' -f1 -s | tr '\n' ' ')
  for i in "$@"; do
    FOUND=false
    for j in $PKGS_INSTALLED; do
      if test $i == $j; then
        FOUND=true
        break
      fi
    done
    if ! $FOUND; then PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"; fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then
    echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
    sudo gem install $PKGS_TO_INSTALL
    if test "$(pwd)" == "/tmp"; then cd -; fi
  fi
}

# ---------------------------------------
# python functions
# ---------------------------------------

function bhf-python-version() {
  python -V 2>&1 | grep -Po '(?<=Python ).{1}'
}

function bhf-python-install-packages() {
  : ${1?"Usage: ${FUNCNAME[0]} [pip3_packages_list]"}

  if ! type pip3 &>/dev/null; then
    bhf-log-error "pip3 not found."
    sudo -H pip3 install --no-cache-dir --disable-pip-version-check --upgrade pip &>/dev/null
  fi

  PKGS_TO_INSTALL=""
  PKGS_INSTALLED=$(pip3 list --format=columns | cut -d' ' -f1 | grep -v Package | sed '1d' | tr '\n' ' ')
  for i in "$@"; do
    FOUND=false
    for j in $PKGS_INSTALLED; do
      if test $i == $j; then
        FOUND=true
        break
      fi
    done
    if ! $FOUND; then PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"; fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then
    echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
    sudo -H pip3 install --no-cache-dir --disable-pip-version-check $PKGS_TO_INSTALL
  fi
  sudo -H pip3 install -U "$@" &>/dev/null
}

# ---------------------------------------
# apt functions
# ---------------------------------------

function bhf-apt-upgrade() {
  if [ "$(apt list --upgradable 2>/dev/null | wc -l)" -gt 1 ]; then
    sudo apt -y upgrade
  fi
}

function bhf-apt-install-packages() {
  : ${1?"Usage: ${FUNCNAME[0]} [apt_packages_list]"}

  PKGS_TO_INSTALL=""
  for i in "$@"; do
    dpkg --status "$i" &>/dev/null
    if test $? != 0; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then
    echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
  fi
  if test -n "$PKGS_TO_INSTALL"; then
    sudo apt install -y $PKGS_TO_INSTALL
  fi
}

function bhf-apt-autoremove() {
  if [ "$(apt-get --dry-run autoremove | grep -c -Po 'Remv \K[^ ]+')" -gt 0 ]; then
    sudo apt -y autoremove
  fi
}

function bhf-apt-remove-packages() {
  : ${1?"Usage: ${FUNCNAME[0]} [apt_packages_list]"}

  PKGS_TO_REMOVE=""
  for i in "$@"; do
    dpkg --status "$i" &>/dev/null
    if test $? -eq 0; then
      PKGS_TO_REMOVE="$PKGS_TO_REMOVE $i"
    fi
  done
  if test -n "$PKGS_TO_REMOVE"; then
    echo "PKGS_TO_REMOVE=$PKGS_TO_REMOVE"
    sudo apt remove -y --purge $PKGS_TO_REMOVE
  fi
}

function bhf-apt-remove-orphan-packages() {
  PKGS_ORPHAN_TO_REMOVE=""
  while [ "$(deborphan | wc -l)" -gt 0 ]; do
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
      sudo apt remove -y --purge $PKGS_ORPHAN_TO_REMOVE
    fi
  done
}

function bhf-apt-fetch-install() {
  : ${1?"Usage: ${FUNCNAME[0]} [url]"}

  apt_NAME=$(basename $1)
  if test ! -f /tmp/$apt_NAME; then
    wget --continue $1 -P /tmp/
  fi
  sudo dpkg -i /tmp/$apt_NAME
}

# ---------------------------------------
# fetch functions
# ---------------------------------------

function bhf-fetch-extract-to() {
  : ${2?"Usage: ${FUNCNAME[0]} [url] [folder]"}

  FILE_NAME_ORIG=$(basename $1)
  FILE_NAME=$(echo $FILE_NAME_ORIG | sed -e's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' | xargs echo -e)
  FILE_EXTENSION=${FILE_NAME##*.}

  if test ! -f /tmp/$FILE_NAME; then
    echo "fetching $FILE_NAME"
    wget --continue $1 -P /tmp/
  fi
  echo "extracting $FILE_NAME"
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
  xz)
    tar -xJf /tmp/$FILE_NAME -C $2
    ;;
  *)
    bhf-log-error "$FILE_EXTENSION is not supported compression."
    return
    ;;
  esac
}

function bhf-fetch-youtube-playlist() {
  : ${1?"Usage: ${FUNCNAME[0]} [playlist_url]"}

  youtube-dl "$1" --yes-playlist --extract-audio --audio-format "mp3" --audio-quality 0 --ignore-errors --embed-thumbnail --output "%(title)s.%(ext)s" --metadata-from-title "%(artist)s - %(title)s" --add-metadata
}

# ---------------------------------------
# list functions
# ---------------------------------------

function bhf-list-sorted-by-size() {
  du -h | sort -h
}

function bhf-list-recursive-sorted-by-size() {
  du -ah | sort -h
}

# ---------------------------------------
# x11 functions
# ---------------------------------------

function bhf-x11-properties-of-window() {
  xprop | grep "^WM_"
}
