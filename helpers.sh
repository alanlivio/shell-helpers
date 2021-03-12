#!/bin/bash

# ---------------------------------------
# detect OS
# ---------------------------------------

case "$(uname -s)" in
Darwin) IS_MAC=1 ;;
Linux) IS_LINUX=1 ;;
CYGWIN* | MINGW* | MSYS*)
  IS_WINDOWS=1
  IS_WINDOWS_MINGW=1
  ;;
esac
if test $IS_LINUX; then
  case "$(uname -r)" in
  *icrosoft*) # (M/m)icrosoft
    IS_LINUX=""
    IS_WINDOWS=1
    IS_WINDOWS_WSL=1
    ;;
  esac
fi

alias hf_log_func='hf_log_msg "${FUNCNAME[0]}"'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$SCRIPT_DIR/helpers.sh"
DOTFILES_VSCODE="$SCRIPT_DIR/dotfiles/vscode"

# ---------------------------------------
# load helpers-cfg
# ---------------------------------------
# if not "$HOME/.helpers-cfg.sh" load sample
if test -f "$HOME/.helpers-cfg.sh"; then
  HELPERS_CFG="$HOME/.helpers-cfg.sh"
else
  HELPERS_CFG="$SCRIPT_DIR/dotfiles/.helpers-cfg.sh"
fi
if test -f $HELPERS_CFG; then
  source $HELPERS_CFG
fi

# ---------------------------------------
# HELPERS_OPT
# ---------------------------------------
# if $HELPERS_CFG not defined use from same dir
if test -z "$HELPERS_OPT"; then
  HELPERS_OPT="$HOME/opt"
  mkdir -p $HELPERS_OPT
fi

# ---------------------------------------
# test functions
# ---------------------------------------

alias hf_test_noargs_then_return='if test $# -eq 0; then return; fi'
alias hf_test_arg1_then_return='if test -z "$1"; then return; fi'
function hf_test_command() {
  if ! type "$1" &>/dev/null; then
    return 1
  else
    return 0
  fi
}

# ---------------------------------------
# init functions
# ---------------------------------------

function hf_init_gnome() {
  hf_log_func
  # sudo nopasswd
  hf_user_permissions_sudo
  # shell configure
  hf_gnome_dark
  hf_gnome_sanity
  hf_gnome_disable_unused_apps_in_search
  hf_gnome_disable_super_workspace_change
  # cleanup
  hf_clean_unused_dirs
  # vim/git/essentials
  PKGS="vim git diffutils curl wget bash deborphan apt-file net-tools zip "
  # python
  PKGS+="python3 python3-pip "
  hf_apt_install_packages $PKGS
  # set python3 as default
  hf_python_set_python3_default
  # install vscode
  hf_install_vscode
  hf_vscode_install_config_files
}

if test -n "$IS_WINDOWS"; then
  function hf_init_wsl() {
    # sudo nopasswd
    hf_user_permissions_sudo
    # vim/git/essentials
    PKGS="vim git diffutils curl wget bash deborphan apt-file net-tools zip "
    # python
    PKGS+="python3 python3-pip "
    hf_apt_install_packages $PKGS
    # set python3 as default
    hf_python_set_python3_default
  }

  function hf_init_msys() {
    hf_user_permissions_sudo
    # update runtime and bash
    PKGS="pacman pacman-mirrors msys2-runtime bash "
    # essentials
    PKGS+="vim git diffutils curl wget zip "
    # python
    PKGS+="mingw64/mingw-w64-x86_64-python mingw64/mingw-w64-x86_64-python-pip "
    hf_msys_install $PKGS
    # python3 is already default in msys
  }

  function hf_init_windows() {
    # windows
    hf_ps_call_admin "hf_init_windows "
  }

fi

if test -n "$IS_MAC"; then
  function hf_init_mac() {
    hf_log_func
    hf_user_permissions_sudo
    hf_mac_install_brew
    hf_brew_upgrade
    # essentials
    PKGS="vim git diffutils curl wget bash jq"
    # python
    PKGS+="python python-pip "
    hf_brew_install $PKGS
    # set python3 as default
    alias python='/usr/local/Cellar/python@3.8/3.8.5/bin/python3'
    alias pip='/usr/local/Cellar/python@3.8/3.8.5/libexec/bin/pip'
    # install vscode
    sudo brew install --cask visual-studio-code
  }
fi

# ---------------------------------------
# update_clean
# ---------------------------------------
# The following funcs requeres variables with PKGS_ prefix.
# Such variables can be configured in .bashrc or helpers-cfg.sh.

function hf_update_clean_gnome() {
  # snap
  hf_snap_install_packages $PKGS_SNAP
  hf_snap_install_packages_classic $PKGS_SNAP_CLASSIC
  hf_snap_upgrade
  hf_apt_upgrade
  # apt
  hf_apt_install_packages $PKGS_APT
  hf_apt_remove_packages $PKGS_REMOVE_APT
  hf_apt_autoremove
  hf_apt_remove_orphan_packages $PKGS_APT_ORPHAN_EXPECTIONS
  # python
  hf_python_install_packages $PKGS_PYTHON
  # vscode
  hf_vscode_install_packages $PKGS_VSCODE
  # cleanup
  hf_clean_unused_dirs
}

if test -n "$IS_WINDOWS"; then
  function hf_update_clean_wsl() {
    # apt
    hf_apt_upgrade
    hf_apt_install_packages $PKGS_APT
    hf_apt_autoremove
    hf_apt_remove_packages $PKGS_REMOVE_APT
    hf_apt_remove_orphan_packages $PKGS_APT_ORPHAN_EXPECTIONS
    # python
    hf_python_install_packages $PKGS_PYTHON
    # vscode
    hf_vscode_install_packages $PKGS_VSCODE
    # cleanup
    hf_clean_unused_dirs
  }

  function hf_update_clean_msys() {
    # msys
    hf_msys_upgrade
    hf_msys_install $PKGS_MSYS
    # cleanup
    hf_clean_unused_dirs
  }

  function hf_update_clean_windows() {
    # windows
    hf_ps_call_admin "hf_winupdate_update"
    hf_ps_call_admin "hf_choco_install $PKGS_CHOCO"
    hf_ps_call_admin "hf_choco_upgrade"
    hf_ps_call_admin "hf_choco_clean"
    hf_ps_call hf_clean_unused_shortcuts
    hf_ps_call hf_explorer_hide_dotfiles
    # cleanup
    hf_clean_unused_dirs
  }
fi

if test -n "$IS_MAC"; then
  function hf_update_clean_mac() {
    # brew
    hf_brew_install $PKGS_BREW
    hf_brew_upgrade
    # python
    hf_python_install_packages $PKGS_PYTHON
    # vscode
    hf_vscode_install_packages $PKGS_VSCODE
  }
fi

function hf_update_clean() {
  # Ubuntu
  if test -n "$IS_LINUX"; then
    hf_update_clean_gnome
  # Ubuntu WSL
  elif test -n "$IS_WINDOWS_WSL"; then
    hf_update_clean_wsl
  # mingw
  elif test -n "$IS_WINDOWS_MINGW"; then
    hf_update_clean_msys
  # mac
  elif test -n "$IS_MAC"; then
    hf_update_clean_mac
  fi
}
# ---------------------------------------
# alias path
# ---------------------------------------

if test -n "$IS_WINDOWS_WSL"; then
  # fix writting permissions
  if [[ "$(umask)" = "0000" ]]; then
    umask 0022
  fi
  alias unixpath='wslpath'
  alias winpath='wslpath -w'
elif test -n "$IS_WINDOWS_MINGW"; then
  alias unixpath='cygpath'
  alias winpath='cygpath -w'
  alias sudo=''
  # fix mingw tmp
  unset temp
  unset tmp
fi

# ---------------------------------------
# alias ls/grep/start/wsl
# ---------------------------------------

if test -n "$IS_LINUX"; then
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias start='xdg-open'
elif test -n "$IS_WINDOWS"; then
  # hide windows user files when ls home
  alias ls='ls --color=auto --hide=ntuser* --hide=NTUSER* --hide=AppData --hide=IntelGraphicsProfiles*'
  alias grep='grep --color=auto'
  alias start="cmd.exe /c start"
  alias chrome="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
  alias gsudo='$(unixpath "c:\\ProgramData\\chocolatey\\lib\gsudo\\bin\\gsudo.exe")'
  alias choco='$(unixpath "c:\\ProgramData\\chocolatey\\bin\\choco.exe")'
fi

# ---------------------------------------
# alias code
# ---------------------------------------

if test -n "$IS_WINDOWS_WSL"; then
  # this is used for hf_vscode_install_packages
  function codewin() {
    cmd.exe /c 'C:\Program Files\Microsoft VS Code\bin\code' $@
  }
  function codewin_folder() {
    cmd.exe /c 'C:\Program Files\Microsoft VS Code\bin\code' $(winpath $1)
  }
elif test -n "$IS_WINDOWS_MINGW"; then
  alias code="/mnt/c/Program\ Files/Microsoft\ VS\ Code/Code.exe"
elif test -n "$IS_MAC"; then
  alias code='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
fi

# ---------------------------------------
# helper.ps1
# ---------------------------------------

if test -n "$IS_WINDOWS"; then
  SCRIPT_PS_WPATH=$(unixpath -w "$SCRIPT_DIR/helpers.ps1")
  function hf_ps_call() {
    powershell.exe -command "& { . $SCRIPT_PS_WPATH; $* }"
  }
  function hf_ps_call_admin() {
    gsudo powershell.exe -command "& { . $SCRIPT_PS_WPATH;  $* }"
  }
fi

# ---------------------------------------
# wsl x_pulseaudio
# ---------------------------------------

if test -n "$IS_WINDOWS_WSL"; then
  # x,pulseaudio server

  function hf_wsl_x_pulseaudio_enable() {
    hf_ps_call_admin "hf_choco_install pulseaudio vcxsrv"

    # https://wiki.ubuntu.com/WSL#Running_Graphical_Applications
    sudo apt-get install pulseaudio
    echo -e "load-module module-native-protocol-tcp auth-anonymous=1" | gsudo sudo tee -a $(unixpath C:\\ProgramData\\chocolatey\\lib\\pulseaudio\\tools\\etc\\pulse\\default.pa)
    echo -e "exit-idle-time = -1" | gsudo sudo tee -a $(unixpath C:\\ProgramData\\chocolatey\\lib\\pulseaudio\\tools\\etc\\pulse\\daemon.conf)

    # configure .profile
    if ! grep -q "PULSE_SERVER" $HOME/.profile; then
      echo -e "\nexport DISPLAY=\"$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0\"" | tee -a $HOME/.profile
      echo "export PULSE_SERVER=\"$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0\"" | tee -a $HOME/.profile
      echo "export LIBGL_ALWAYS_INDIRECT=1" | tee -a $HOME/.profile
    fi
  }

  function hf_wsl_x_pulseaudio_start() {
    hf_wsl_x_pulseaudio_kill
    $(unixpath C:\\ProgramData\\chocolatey\\bin\\pulseaudio.exe) &
    "$(unixpath 'C:\Program Files\VcXsrv\vcxsrv.exe')" :0 -multiwindow -clipboard -wgl -ac -silent-dup-error &
  }

  function hf_wsl_x_pulseaudio_stop() {
    cmd.exe /c "taskkill /IM pulseaudio.exe /F"
    cmd.exe /c "taskkill /IM vcxsrv.exe /F"
  }
fi

# ---------------------------------------
# wsl ssh
# ---------------------------------------

if test -n "$IS_WINDOWS_WSL"; then
  function hf_wsl_ssh_config() {
    sudo apt install -y openssh-server
    # https://github.com/JetBrains/clion-wsl/blob/master/ubuntu_setup_env.sh
    SSHD_LISTEN_ADDRESS=127.0.0.1
    SSHD_PORT=2222
    SSHD_FILE=/etc/ssh/sshd_config
    SUDOERS_FILE=/etc/sudoers
    sudo apt install -y openssh-server
    sudo cp $SSHD_FILE ${SSHD_FILE}.$(date '+%Y-%m-%d_%H-%M-%S').back
    sudo sed -i '/^Port/ d' $SSHD_FILE
    sudo sed -i '/^ListenAddress/ d' $SSHD_FILE
    sudo sed -i '/^UsePrivilegeSeparation/ d' $SSHD_FILE
    sudo sed -i '/^PasswordAuthentication/ d' $SSHD_FILE
    echo "# configured by CLion" | sudo tee -a $SSHD_FILE
    echo "ListenAddress ${SSHD_LISTEN_ADDRESS}" | sudo tee -a $SSHD_FILE
    echo "Port ${SSHD_PORT}" | sudo tee -a $SSHD_FILE
    echo "PasswordAuthentication yes" | sudo tee -a $SSHD_FILE
    echo "%sudo ALL=(ALL) NOPASSWD: /usr/sbin/service ssh --full-restart" | sudo tee -a $SUDOERS_FILE
    sudo service ssh --full-restart
  }

  function hf_wsl_ssh_start() {
    sshd_status=$(service ssh status)
    if [[ $sshd_status = *"is not running"* ]]; then
      sudo service ssh --full-restart
    fi
  }
fi

# ---------------------------------------
# log
# ---------------------------------------

function hf_log_wrap() {
  echo -e "$1" | fold -w100 -s
}

function hf_log_error() {
  hf_log_wrap "\033[00;31m-- $* \033[00m"
}

function hf_log_msg() {
  hf_log_wrap "\033[00;33m-- $* \033[00m"
}

function hf_log_msg_2nd() {
  hf_log_wrap "\033[00;33m-- > $* \033[00m"
}

function hf_log_done() {
  hf_log_wrap "\033[00;32m-- done\033[00m"
}

function hf_log_ok() {
  hf_log_wrap "\033[00;32m-- ok\033[00m"
}

function hf_log_try() {
  "$@"
  if test $? -ne 0; then hf_log_error "$1" && exit 1; fi
}

# ---------------------------------------
# file
# ---------------------------------------

function hf_file_md5_compare() {
  : ${2?"Usage: ${FUNCNAME[0]} [file1] [file2]"}
  if [ $(md5sum $1 | awk '{print $1;exit}') == $(md5sum $2 | awk '{print $1;exit}') ]; then echo "same"; else echo "different"; fi
}

function hf_file_test_or_touch() {
  : ${1?"Usage: ${FUNCNAME[0]} [file]"}
  if ! test -f "$1"; then touch "$1"; fi
}

# ---------------------------------------
# profile
# ---------------------------------------

function hf_profile_install() {
  hf_log_func
  echo -e "\nsource $SCRIPT_NAME" >>$HOME/.bashrc
}

function hf_profile_reload() {
  hf_log_func
  if test -n "$IS_WINDOWS"; then
    # for WSL
    source $HOME/.profile
  else
    source $HOME/.bashrc
  fi
}

# ---------------------------------------
# msys
# ---------------------------------------

if test -n "$IS_WINDOWS_MINGW"; then

  function hf_msys_search() {
    hf_log_func
    sudo pacman -Ss --noconfirm "$@"
  }

  function hf_msys_list_installed() {
    hf_log_func
    sudo pacman -Qqe
  }

  function hf_msys_install() {
    hf_log_func
    sudo pacman -Su --needed --noconfirm "$@"
  }

  function hf_msys_install_force() {
    hf_log_func
    sudo pacman -Syu --noconfirm "$@"
  }

  function hf_msys_uninstall() {
    hf_log_func
    sudo pacman -R --noconfirm "$@"
  }

  function hf_msys_upgrade() {
    hf_log_func
    sudo pacman --needed -S bash pacman pacman-mirrors msys2-runtime
    sudo pacman -Su --noconfirm
  }

  function hf_msys_fix_lock() {
    hf_log_func
    sudo rm /var/lib/pacman/db.lck
  }

  function hf_msys_fix_home() {
    echo -e "none / cygdrive binary,posix=0,noacl,user 0 0" | tee /etc/fstab
    echo -e "C:/Users /home ntfs binary,noacl,auto 1 1" | tee -a /etc/fstab
    echo -e "C:/Users /Users ntfs binary,noacl,auto 1 1" | tee -a /etc/fstab
    echo -e "C:/tools /tools ntfs binary,noacl,auto 1 1" | tee -a /etc/fstab
    # use /mnt/c/ like in WSL
    echo -e "/c /mnt/c none bind" | tee -a /etc/fstab
  }

fi

# ---------------------------------------
# macos-only functions
# ---------------------------------------

if test -n "$IS_MAC"; then
  function hf_mac_install_brew() {
    hf_log_func
    sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  }

  function hf_brew_install() {
    sudo brew install "$@"
  }

  function hf_brew_upgrade() {
    sudo brew update
    sudo brew upgrade
  }
fi

# ---------------------------------------
# ubuntu-on-mac
# ---------------------------------------

function hf_mac_ubuntu_keyboard_fixes() {
  hf_log_func

  # enable fn keys
  echo -e 2 | sudo tee -a /sys/module/hid_apple/parameters/fnmode

  # configure layout
  # alternative: setxkbmap -layout us -variant intl
  gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us+intl')]"

  grep -q cedilla /etc/environment
  if test $? != 0; then
    # fix cedilla
    echo -e "GTK_IM_MODULE=cedilla" | sudo tee -a /etc/environment
    echo -e "QT_IM_MODULE=cedilla" | sudo tee -a /etc/environment
    # enable fnmode
    echo -e "options hid_apple fnmode=2" | sudo tee -a /etc/modprobe.d/hid_apple.conf
    sudo update-initramfs -u
  fi
}

function hf_mac_ubuntu_enable_wifi() {
  hf_log_func
  dpkg --status bcmwl-kernel-source &>/dev/null
  if test $? != 0; then
    sudo apt install -y bcmwl-kernel-source
    sudo modprobe -r b43 ssb wl brcmfmac brcmsmac bcma
    sudo modprobe wl
  fi
}

# ---------------------------------------
# audio
# ---------------------------------------

function hf_audio_create_empty() {
  : ${1?"Usage: ${FUNCNAME[0]} [audio_output]"}
  hf_log_func
  gst-launch-1.0 audiotestsrc wave=4 ! audioconvert ! lamemp3enc ! id3v2mux ! filesink location="$1"
}

function hf_audio_compress() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_log_func
  lame -b 32 "$1".mp3 compressed"$1".mp3
}

# ---------------------------------------
# video
# ---------------------------------------

function hf_video_add_srt_track() {
  : ${3?"Usage: ${FUNCNAME[0]} <video> <srt> <output>"}
  hf_log_func
  ffmpeg -i $1 -i $2 -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 $3
}

function hf_video_add_srt_in_picutre() {
  : ${3?"Usage: ${FUNCNAME[0]} <video> <srt> <output>"}
  hf_log_func
  ffmpeg -i $1 -filter:v subtitles=$2 $3
}

function hf_video_create_by_image() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_log_func
  ffmpeg -loop_input -i "$1".png -t 5 "$1".mp4
}

function hf_video_cut_mp4() {
  : ${3?"Usage: ${FUNCNAME[0]} <video> <begin_time_in_format_00:00:00> <end_time_in_format_00:00:00>"}
  hf_log_func
  ffmpeg -i $1 -vcodec copy -acodec copy -ss $2 -t $3 -f mp4 cuted-$1
}

# ---------------------------------------
# gst
# ---------------------------------------

function hf_gst_side_by_side_test() {
  hf_log_func
  gst-launch-1.0 compositor name=comp sink_1::xpos=640 ! videoconvert ! ximagesink videotestsrc pattern=snow ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" ! timeoverlay ! queue2 ! comp. videotestsrc pattern=smpte ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! timeoverlay ! queue2 ! comp.
}

function hf_gst_side_by_side_args() {
  : ${2?"Usage: ${FUNCNAME[0]} <video1 <video2>"}
  hf_log_func
  gst-launch-1.0 compositor name=comp sink_1::xpos=640 ! ximagesink filesrc location=$1 ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)30/1" ! decodebin ! videoconvert ! comp. filesrc location=$2 ! "video/x-raw,format=AYUV,width=640,height=480,framerate=(fraction)10/1" ! decodebin ! videoconvert ! comp.
}

# ---------------------------------------
# deb
# ---------------------------------------

function hf_deb_install() {
  : ${1?"Usage: ${FUNCNAME[0]} <pkg_name>"}
  sudo dpkg -i $1
}

function hf_deb_install_force_depends() {
  : ${1?"Usage: ${FUNCNAME[0]} <pkg_name>"}
  sudo dpkg -i --force-depends $1
}

function hf_deb_info() {
  : ${1?"Usage: ${FUNCNAME[0]} <pkg_name>"}
  dpkg-deb --info $1
}

function hf_deb_contents() {
  : ${1?"Usage: ${FUNCNAME[0]} <pkg_name>"}
  dpkg-deb --show $1
}

# ---------------------------------------
# pkg-config
# ---------------------------------------

function hf_pkg_config_find() {
  : ${1?"Usage: ${FUNCNAME[0]} <pkg_name>"}
  pkg-config --list-all | grep --color=auto $1
}

function hf_pkg_config_show() {
  : ${1?"Usage: ${FUNCNAME[0]} <pkg_name>"}
  PKG=$(pkg-config --list-all | grep -w $1 | awk '{print $1;exit}')
  echo 'version:    '"$(pkg-config --modversion $PKG)"
  echo 'provides:   '"$(pkg-config --print-provides $PKG)"
  echo 'requireds:  '"$(pkg-config --print-requires $PKG | awk '{print}' ORS=' ')"
}

# ---------------------------------------
# pygmentize
# ---------------------------------------

function hf_pygmentize_folder_xml_files_by_extensions_to_jpeg() {
  : ${1?"Usage: ${FUNCNAME[0]} <folder>"}
  find . -maxdepth 1 -name "*.xml" | while read -r i; do
    pygmentize -f jpeg -l xml -o $i.jpg $i
  done
}

function hf_pygmentize_folder_xml_files_by_extensions_to_rtf() {
  : ${1?"Usage: ${FUNCNAME[0]} <folder>"}

  find . -maxdepth 1 -name "*.xml" | while read -r i; do
    pygmentize -f jpeg -l xml -o $i.jpg $i
    pygmentize -P fontsize=16 -P fontface=consolas -l xml -o $i.rtf $i
  done
}

function hf_pygmentize_folder_xml_files_by_extensions_to_html() {
  : ${1?"Usage: ${FUNCNAME[0]} ARGUMENT"}
  hf_test_command pygmentize || return
  find . -maxdepth 1 -name "*.xml" | while read -r i; do
    pygmentize -O full,style=default -f html -l xml -o $i.html $i
  done
}

# ---------------------------------------
# gdb
# ---------------------------------------

function hf_gdb_run_bt() {
  : ${1?"Usage: ${FUNCNAME[0]} <program>"}
  gdb -ex="set confirm off" -ex="set pagination off" -ex=r -ex=bt --args "$@"
}

function hf_gdb_run_bt_all_threads() {
  : ${1?"Usage: ${FUNCNAME[0]} <program>"}
  gdb -ex="set confirm off" -ex="set pagination off" -ex=r -ex=bt -ex="thread apply all bt" --args "$@"
}

# ---------------------------------------
# git
# ---------------------------------------

function hf_git_overleaf_push_commit_all() {
  git commit -am "Update from local git"
  git push
}

function hf_git_file_options_untrack() {
  git config core.fileMode false
}

function hf_git_assume_unchanged() {
  git update-index --assume-unchanged $1
}

function hf_git_assume_unchanged_disable() {
  git update-index --no-assume-unchanged $1
}

function hf_git_services_test() {
  ssh -T git@gitlab.com
  ssh -T git@github.com
}

function hf_git_revert_last_commit() {
  git revert HEAD
}

function hf_git_reset_hard() {
  git reset --hard
}

function hf_git_stash_list() {
  git stash save --include-untracked
}

function hf_git_branch_merge_without_merge_commit() {
  : ${1?"Usage: ${FUNCNAME[0]} <branch-name>"}
  git merge --ff-only $1
}

function hf_git_branch_push() {
  : ${1?"Usage: ${FUNCNAME[0]} <branch-name>"}
  git push -u origin $1
}

function hf_git_branch_create_from_origin() {
  : ${1?"Usage: ${FUNCNAME[0]} <branch-name>"}
  git checkout -b $1
  git push -u origin $1
}

function hf_git_branch_create_from_origin_all_reset_hard() {
  local CURRENT=$(git branch --show-current)
  git fetch -p origin
  git branch -r | grep -v '\->' | while read -r remote; do
    git reset --hard
    git clean -ndf
    hf_log_msg "updating ${remote#origin/}"
    git checkout "${remote#origin/}"
    if test $? != 0; then
      hf_log_error "cannot goes to ${remote#origin/} because there are local changes"
      exit
    fi
    git pull --all
    if test $? != 0; then
      hf_log_error "cannot pull ${remote#origin/} because there are local changes"
      exit
    fi
  done
  hf_log_msg "returning to branch $CURRENT"
  git checkout $CURRENT
}

function hf_git_branch_show_remotes() {
  git remote show origin
}

function hf_git_branch_delete_local_and_origin() {
  : ${1?"Usage: ${FUNCNAME[0]} <branch-name>"}
  git branch -d $1
  git push origin --delete $1
}

function hf_git_branch_clean_removed_remotes() {
  # clean removed remotes
  git fetch --prune
  # clean banchs with removed upstreams
  git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -d
}

function hf_git_branch_upstrem_set() {
  : ${1?"Usage: ${FUNCNAME[0]} <remote-branch>"}
  git branch --set-upstream-to $1
}

function hf_git_add_partial() {
  git stash
  git difftool -y stash
}

function hf_git_add_partial_continue() {
  git difftool -y stash
}

function hf_git_github_check_ssh() {
  ssh -T git@github.com
}

function hf_git_github_fix() {
  echo -e "Host github.com\\n  Hostname ssh.github.com\\n  Port 443" | sudo tee $HOME/.ssh/config
}

function hf_git_github_init() {
  : ${1?"Usage: ${FUNCNAME[0]} <github-name>"}
  NAME=$(basename "$1" ".${1##*.}")
  echo "init github repo $NAME "

  echo "#" $NAME >README.md
  git init
  git add README.md
  git commit -m "first commit"
  git remote add origin $1
  git push -u origin master
}

function hf_git_rebase_reset_author() {
  : ${1?"Usage: ${FUNCNAME[0]} <HEAD^n-commits-backwards>"}
  git rebase -i HEAD^$1 -x "git commit --amend --reset-author"
}

function hf_git_rebase_remove_from_tree() {
  git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch $1' --prune-empty --tag-name-filter cat -- --all
}

function hf_git_ammend_all() {
  git commit -a --amend --no-edit
}

function hf_git_push_ammend_all() {
  git commit -a --amend --no-edit
  git push --force
}

function hf_git_push_commit_all() {
  : ${1?"Usage: ${FUNCNAME[0]} <commit_message>"}
  echo $1
  git commit -am "$1"
  git push
}

function hf_git_check_if_need_pull() {
  [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref "@{u}" \
    | sed 's/\// /g') | cut -f1) ] && printf FALSE || printf TRUE
}

function hf_git_gitignore_create() {
  : ${1?"Usage: ${FUNCNAME[0]} <contexts,..>"}
  curl -L -s "https://www.gitignore.io/api/$1"
}

function hf_git_gitignore_create_javascript() {
  hf_git_gitignore_create node,bower,grunt
}

function hf_git_gitignore_create_cpp() {
  hf_git_gitignore_create c,c++,qt,autotools,make,ninja,cmake
}

function hf_git_list_large_files() {
  git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -3
}

function hf_git_formated_patch_last() {
  git format-patch HEAD^1
}

function hf_git_formated_patch_apply() {
  git am <"$@"
}

function hf_git_folder_tree() {
  hf_log_func
  DEV_FOLDER=$1
  REPOS=$2

  if test ! -d $DEV_FOLDER; then
    hf_log_msg "creating $DEV_FOLDER"
    mkdir $DEV_FOLDER
  fi
  CWD=$(pwd)
  cd $DEV_FOLDER

  for i in "${!REPOS[@]}"; do
    if [ "$i" == "0" ]; then continue; fi
    hf_log_msg "repositories for $DEV_FOLDER/$i folder"
    if ! test -d $DEV_FOLDER/$i; then
      hf_log_msg_2nd "creating $DEV_FOLDER/$i folder"
      mkdir $DEV_FOLDER/$i
    fi
    cd $DEV_FOLDER/$i
    for j in ${REPOS[$i]}; do
      hf_log_msg_2nd "configuring $(basename $j)"
      if ! test -d "$(basename -s .git $j)"; then
        hf_log_msg_2nd "clone $j"
        git clone $j
      else
        hf_log_msg_2nd "pull $j"
        cd "$(basename -s .git $j)"
        git pull
        cd ..
      fi
    done
  done

  cd $CWD
}

function hf_git_log_history_file() {
  git log --follow -p --all --first-parent --remotes --reflog --author-date-order -- $1
}

function hf_git_diff_one_commit() {
  git diff HEAD^1
}

function hf_git_diff_files_one_commit() {
  git diff --stat HEAD^1
}

function hf_git_diff_files() {
  : ${1?"Usage: ${FUNCNAME[0]} <commit>"}
  git diff --stat $1
}

function hf_git_subfolders_push() {
  CWD=$(pwd)
  FOLDER=$(pwd $0)
  cd $FOLDER
  for i in $(find . -type d -iname .git | sed 's/\.git//g'); do
    cd "$FOLDER/$i"
    if test -d .git; then
      hf_log_msg "push on $i"
      git push
    fi
    cd ..
  done
  cd $CWD
}

function hf_git_subfolders_pull() {
  CWD=$(pwd)
  FOLDER=$(pwd $0)
  cd $FOLDER
  for i in $(find . -type d -iname .git | sed 's/\.git//g'); do
    cd "$FOLDER/$i"
    if test -d .git; then
      hf_log_msg "pull on $i"
      git pull
    fi
    cd ..
  done
  cd $CWD
}

function hf_git_subfolders_reset_clean() {
  CWD=$(pwd)
  FOLDER=$(pwd $1)
  cd $FOLDER
  for i in $(find . -type d -iname .git | sed 's/\.git//g'); do
    cd "$FOLDER/$i"
    if test -d .git; then
      hf_log_msg "reset and clean on $i"
      git reset --hard
      git clean -df
    fi
    cd ..
  done
  cd $CWD
}

# ---------------------------------------
# eclipse
# ---------------------------------------

function hf_eclipse_list_installed() {
  eclipse -consolelog -noSplash -application org.eclipse.equinox.p2.director -listInstalledRoots
}

# ---------------------------------------
# grub
# ---------------------------------------

function hf_grub_verbose_boot() {
  sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/g" /etc/default/grub
  sudo update-grub2
}

function hf_grub_splash_boot() {
  sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash\"/g" /etc/default/grub
  sudo update-grub2
}

# ---------------------------------------
# android
# ---------------------------------------

function hf_android_start_activity() {
  #adb shell am start -a android.intent.action.MAIN -n com.android.browser/.BrowserActivity
  #adb shell am start -a android.intent.action.MAIN -n org.libsdl.app/org.libsdl.app.SDLActivity
  : ${1?"Usage: ${FUNCNAME[0]} <activity>"}

  adb shell am start -a android.intent.action.MAIN -n "$1"
}

function hf_android_restart_adb() {
  sudo adb kill-server && sudo adb start-server
}

function hf_android_get_ip() {
  adb shell netcfg
  adb shell ifconfig wlan0
}

function hf_android_enable_stdout_stderr_output() {
  adb shell stop
  adb shell setprop log.redirect-stdio true
  adb shell start
}

function hf_android_get_printscreen() {
  adb shell /system/bin/screencap -p /sdcard/screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
  adb pull /sdcard/screenshot.png screenshot.png
}

function hf_android_installed_package() {
  : ${1?"Usage: ${FUNCNAME[0]} <package>"}
  adb shell pm list packages | grep $1
}

function hf_android_uninstall_package() {
  : ${1?"Usage: ${FUNCNAME[0]} <package_in_format_XXX.YYY.ZZZ>"}
  adb uninstall $1
}
function hf_android_install_package() {
  : ${1?"Usage: ${FUNCNAME[0]} <package>"}
  adb install $1
}

# ---------------------------------------
# flutter
# ---------------------------------------

function hf_flutter_pkgs_get() {
  flutter pub get
}

function hf_flutter_pkgs_upgrade() {
  flutter packages pub upgrade
}

function hf_flutter_doctor() {
  flutter doctor -v
}

function hf_flutter_run() {
  flutter run
}

function hf_flutter_clean() {
  flutter clean
}

function hf_flutter_scanfoold() {
  flutter create --sample=material.Scaffold.2 mysample
}

# ---------------------------------------
# http
# ---------------------------------------

function hf_http_host_folder() {
  sudo python3 -m http.server 80
}

function hf_folder_remove_empty_folder() {
  find . -type d -empty -exec rm -i -R {} \;
}

function hf_folder_remove() {
  if test -d $1; then rm -rf $1; fi
}

function hf_folder_info() {
  EXTENSIONS=$(for f in *.*; do printf "%s\n" "${f##*.}"; done | sort -u)
  echo "size="$(du -sh | awk '{print $1;exit}')
  echo "dirs="$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)
  echo -n "files="$(find . -mindepth 1 -maxdepth 1 -type f | wc -l)"("
  for i in $EXTENSIONS; do
    echo -n ".$i="$(find . -mindepth 1 -maxdepth 1 -type f -iname \*\.$i | wc -l)","
  done
  echo ")"
}

function hf_folder_files_sizes() {
  du -ahd 1 | sort -h
}

# ---------------------------------------
# latex
# ---------------------------------------

function hf_latex_clean() {
  rm -rf ./*.aux ./*.dvi ./*.log ./*.lox ./*.out ./*.lol ./*.pdf ./*.synctex.gz ./_minted-* ./*.bbl ./*.blg ./*.lot ./*.lof ./*.toc ./*.lol ./*.fdb_latexmk ./*.fls ./*.bcf
}

function hf_latex_apt_essentials() {
  local PKGS_TO_INSTALL+="texlive-base texlive-latex-recommended texlive-latex-extra texlive-bibtex-extra texlive-extra-utils texlive-fonts-extra texlive-xetex texlive-lang-english"
  hf_apt_install_packages $PKGS_TO_INSTALL
}

function hf_latex_gitignore() {
  hf_git_gitignore_create latex >.gitignore
  echo "main.pdf" >>.gitignore
  echo "_main*.pdf" >>.gitignore
}

function hf_latex_build_pdflatex() {
  # : ${1?"Usage: ${FUNCNAME[0]} <main-tex-file>"}
  pdflatex --shell-escape -synctex=1 -interaction=nonstopmode -file-line-error $1 \
    && find . -maxdepth 1 -name "*.aux" -exec echo -e "\n-- bibtex" {} \; -exec bibtex {} \; \
    && pdflatex --shell-escape -synctex=1 -interaction=nonstopmode -file-line-error $1
}

# ---------------------------------------
# cpp
# ---------------------------------------

function hf_cpp_clean() {
  # autootools
  find . -name "Makefile" -o -name ".libs" -o -name "*.a" -o -name "*.o" -name "*.lo" -o -name "*.so" -o -name "*.Plo" -o -name "*.la" -o -name "autom4te.cache" -o -name "aclocal.m4" -o -name "libtool" -o -name "config.log" -o -name "configure" -o -name "config.status" | xargs -r rm -r
  # cmake
  find . -name "CMakeCache.txt" -o -name "CMakeFiles" -o -name "cmake-build-debug" -o -name "Testing" -o -name "cmake-install.cmake" -o -name "CPack*" -o -name "CTest*" -o -name "*.cbp" -o -name "_build" | xargs -r rm -r
}

# ---------------------------------------
# meson
# ---------------------------------------

function hf_meson_configure() {
  # if in project root create build folder
  DIR="_build-Debug-$WSL_DISTRO_NAME$OS"
  if test -f meson.build; then
    mkdir $DIR
    cd $DIR
  fi
  meson .. --buildtype=debug
}

function hf_meson_build() {
  meson compile
}

function hf_meson_install() {
  meson install
}

# ---------------------------------------
# cmake
# ---------------------------------------

function hf_cmake_configure() {
  # if in project root create build folder
  DIR="_build-Debug-$WSL_DISTRO_NAME$OS"
  if test -f CMakeLists.txt; then
    mkdir $DIR
    cd $DIR
  fi
  cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug
}

function hf_cmake_build() {
  cmake --build . --target all
}

function hf_cmake_check() {
  cmake --build . --target check
}

function hf_cmake_install() {
  PREFIX="/usr/"
  if ! test -z $1; then PREFIX=$1; fi
  sudo cmake --install . --prefix $PREFIX
}

function hf_cmake_uninstall() {
  MANIFEST=./install_manifest.txt
  if test -f $MANIFEST; then
    cat $MANIFEST | while read -r i; do
      if test -f $i; then sudo rm -f $i; fi
    done
  fi
}

# ---------------------------------------
# image
# ---------------------------------------

function hf_image_size_get() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  identify -format "%wx%h" "$1"
}

function hf_image_resize() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  convert "$1" -resize "$2"\> "rezised-$1"
}

function hf_image_reconize_text_en() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_test_command tesseract || return
  tesseract -l eng "$1" "$1.txt"
}

function hf_image_reconize_text_pt() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_test_command tesseract || return
  tesseract -l por "$1" "$1.txt"
}

function hf_image_reconize_stdout() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_test_command tesseract || return
  tesseract "$1" stdout
}

function hf_imagem_compress() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_test_command pngquant || return
  pngquant "$1" --force --quality=70-80 -o "compressed-$1"
}

function hf_imagem_compress_hard() {
  : ${1?"Usage: ${FUNCNAME[0]} <image>"}
  hf_test_command jpegoptim || return

  jpegoptim -d . $1.jpeg
}

# ---------------------------------------
# pdf
# ---------------------------------------

function hf_pdf_concat() {
  : ${2?"Usage: ${FUNCNAME[0]} <pdf_1> <pdf_2>"}
  pdftk $1 $2 cat output ${1%.*}-concatenated.pdf
}

function hf_pdf_find_duplicates() {
  find . -iname "*.pdf" -not -empty -type f -printf "%s\n" | sort -rn | uniq -d | xargs -I{} -n1 find . -type f -size {}c -print0 | xargs -r -0 md5sum | sort | uniq -w32 --all-repeated=separate
}

function hf_pdf_remove_annotations() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  hf_test_command rewritepdf || return
  rewritepdf "$1" "-no-annotations-$1"
}

function hf_pdf_search_pattern() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  hf_test_command pdfgrep || return
  pdfgrep -rin "$1" | while read -r i; do basename "${i%%:*}"; done | sort -u
}

function hf_pdf_remove_password() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  hf_test_command qpdf || return

  qpdf --decrypt "$1" "unlocked-$1"
}

function hf_pdf_remove_watermark() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  hf_test_command pdftk || return
  sed -e "s/THISISTHEWATERMARK/ /g" <"$1" >nowatermark.pdf
  pdftk nowatermark.pdf output repaired.pdf
  mv repaired.pdf nowatermark.pdf
}

function hf_pdf_compress() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=${1%.*}-compressed.pdf $1
}

function hf_pdf_compress_hard1() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/printer -sOutputFile=${1%.*}-compressed.pdf $1
}

function hf_pdf_compress_hard2() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  ghostscript -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/ebook -sOutputFile=${1%.*}-compressed.pdf $1
}

function hf_pdf_count_words() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  pdftotext $1 - | wc -w
}

function hf_pdf_to_images() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  pdftoppm -png $1 ${1%.*}
}

# ---------------------------------------
# convert
# ---------------------------------------

function hf_convert_to_markdown() {
  : ${1?"Usage: ${FUNCNAME[0]} <file_name>"}
  hf_test_command pandoc || return
  pandoc -s $1 -t markdown -o ${1%.*}.md
}

function hf_convert_to_pdf() {
  : ${1?"Usage: ${FUNCNAME[0]} <pdf>"}
  hf_test_command pandoc || return
  soffice --headless --convert-to pdf ${1%.*}.pdf
}

# ---------------------------------------
# rename
# ---------------------------------------

function hf_rename_to_lowercase_with_underscore() {
  : ${1?"Usage: ${FUNCNAME[0]} <file_name>"}
  hf_test_command rename || return || return
  echo "rename to lowercase with underscore"
  rename 'y/A-Z/a-z/' "$@"
  echo "replace '.', ' ', and '-' by '_''"
  rename 's/-+/_/g;s/\.+/_/g;s/ +/_/g' "$@"
}

function hf_rename_to_lowercase_with_dash() {
  : ${1?"Usage: ${FUNCNAME[0]} <file_name>"}
  hf_test_command rename || return || return
  echo "rename to lowercase with dash"
  rename 'y/A-Z/a-z/' "$@"
  echo "replace '.', ' ', and '-' by '_''"
  rename 's/_+/-/g;s/\.+/-/g;s/ +/-/g' "$@"
}

# ---------------------------------------
# partitions
# ---------------------------------------

function hf_partitions_list() {
  df -h
}

# ---------------------------------------
# network
# ---------------------------------------

function hf_network_wait_for_conectivity() {
  watch -g -n 1 ping -c 1 google.com
}

function hf_network_ports() {
  netstat -a -n -o
}

function hf_network_ports_list() {
  lsof -i
}

function hf_network_ports_list_one() {
  : ${1?"Usage: ${FUNCNAME[0]} <port>"}
  sudo lsof -i:$1
}

function hf_network_ports_kill_using() {
  : ${1?"Usage: ${FUNCNAME[0]} <port>"}
  pid=$(sudo lsof -t -i:$1)
  if test -n "$pid"; then
    sudo kill -9 "$pid"
  fi
}

function hf_network_domain_info() {
  whois $1
}

function hf_network_ip() {
  echo "$(hostname -I | cut -d' ' -f1)"
}

function hf_network_arp_scan() {
  hf_test_command arp-scan || return
  sudo arp-scan --localnet
}

function hf_network_arp_scan_for_interface() {
  : ${1?"Usage: ${FUNCNAME[0]} <network_interface>"}
  hf_test_command arp-scan || return
  sudo arp-scan --localnet --interface=$1
}

# ---------------------------------------
# virtualbox
# ---------------------------------------

function hf_virtualbox_compact() {
  : ${1?"Usage: ${FUNCNAME[0]} <vdi_file>"}
  VBoxManage modifyhd "$1" compact
}

function hf_virtualbox_resize_to_2gb() {
  : ${1?"Usage: ${FUNCNAME[0]} <vdi_file>"}
  VBoxManage modifyhd "$1" --resize 200000
}

# ---------------------------------------
# user
# ---------------------------------------

function hf_user_create_new() {
  : ${1?"Usage: ${FUNCNAME[0]} <user_name>"}
  sudo adduser "$1"
}

function hf_user_logout() {
  : ${1?"Usage: ${FUNCNAME[0]} <user_name>"}
  sudo skill -KILL -u $1
}

function hf_user_enable_sudo() {
  : ${1?"Usage: ${FUNCNAME[0]} <user_name>"}
  sudo usermod -aG sudo "$1"
}

function hf_user_permissions_sudo() {
  if ! test -d /etc/sudoers.d/; then mkdir /etc/sudoers.d/; fi
  SET_USER=$USER && sudo sh -c "echo $SET_USER 'ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sudoers-user"
}

function hf_user_passwd_disable_len_restriction() {
  sudo sed 's/sha512/minlen=1 sha512/g' /etc/pam.d/common-password
}

function hf_user_permissions_opt() {
  hf_log_func
  sudo chown -R root:root /opt
  sudo chmod -R 775 /opt/
  grep root /etc/group | grep $USER >/dev/null
  if test $? = 1; then sudo adduser $USER root >/dev/null; fi
  newgrp root
}

function hf_user_permissions_ssh() {
  sudo chmod 700 $HOME/.ssh/
  if test -f $HOME/.ssh/id_rsa; then
    sudo chmod 600 $HOME/.ssh/id_rsa
    sudo chmod 640 $HOME/.ssh/id_rsa.pubssh-rsa
  fi
}

function hf_user_send_ssh_keys() {
  : ${1?"Usage: ${FUNCNAME[0]} <user_name>"}
  ssh "$1" 'cat - >> $HOME/.ssh/authorized_keys' <$HOME/.ssh/id_rsa.pubssh-rsa
}

# ---------------------------------------
# snap
# ---------------------------------------

function hf_snap_install_packages() {
  hf_log_func
  hf_test_noargs_then_return

  INSTALLED_LIST="$(snap list | awk 'NR>1 {print $1}')"
  PKGS_TO_INSTALL=""
  for i in "$@"; do
    echo "$INSTALLED_LIST" | grep "^$i" &>/dev/null
    if test $? != 0; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"; fi
  if test -n "$PKGS_TO_INSTALL"; then
    for i in $PKGS_TO_INSTALL; do
      sudo snap install "$i"
    done
  fi
}

function hf_snap_install_packages_classic() {
  hf_log_func
  hf_test_noargs_then_return

  INSTALLED_LIST="$(snap list | awk 'NR>1 {print $1}')"
  PKGS_TO_INSTALL=""
  for i in "$@"; do
    echo "$INSTALLED_LIST" | grep "^$i" &>/dev/null
    if test $? != 0; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"; fi
  if test -n "$PKGS_TO_INSTALL"; then
    for i in $PKGS_TO_INSTALL; do
      sudo snap install --classic "$i"
    done
  fi
}

function hf_snap_install_packages_edge() {
  hf_log_func
  hf_test_noargs_then_return

  INSTALLED_LIST="$(snap list | awk 'NR>1 {print $1}')"
  PKGS_TO_INSTALL=""
  for i in "$@"; do
    echo "$INSTALLED_LIST" | grep "^$i" &>/dev/null
    if test $? != 0; then
      PKGS_TO_INSTALL="$PKGS_TO_INSTALL $i"
    fi
  done
  if test ! -z "$PKGS_TO_INSTALL"; then echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"; fi
  if test -n "$PKGS_TO_INSTALL"; then
    for i in $PKGS_TO_INSTALL; do
      sudo snap install --edge "$i"
    done
  fi
}

function hf_snap_upgrade() {
  hf_log_func
  sudo snap refresh 2>/dev/null
}

function hf_snap_hide_home_folder() {
  echo snap >>$HOME/.hidden
}

# ---------------------------------------
# diff
# ---------------------------------------

function hf_diff() {
  : ${2?"Usage: ${FUNCNAME[0]} <old_file> <new_file>"}
  diff "$1" "$2"
}

function hf_diff_apply() {
  : ${2?"Usage: ${FUNCNAME[0]} <old_file> <new_file>"}
  patch apply "$1" "$2"
}

# ---------------------------------------
# vscode
# ---------------------------------------

function hf_vscode_install_config_files() {
  if test -d $DOTFILES_VSCODE; then
    cp $DOTFILES_VSCODE/settings.json $HOME/.config/Code/User
    cp $DOTFILES_VSCODE/keybindings.json $HOME/.config/Code/User
  fi
}

function hf_vscode_diff() {
  : ${1?"Usage: ${FUNCNAME[0]} <old_file> <new_file>"}
  diff "$1" "$2" &>/dev/null
  if test $? -eq 1; then
    code --wait --diff "$1" "$2"
  fi
}

function hf_vscode_install_packages() {
  hf_log_func
  hf_test_noargs_then_return
  hf_test_command code || return
  CODETMP=$(if test -n "$IS_WINDOWS_WSL"; then echo "codewin"; else echo "code"; fi)
  PKGS_TO_INSTALL=""
  INSTALLED_LIST_TMP_FILE="/tmp/code-list-extensions"
  $CODETMP --list-extensions >$INSTALLED_LIST_TMP_FILE
  for i in "$@"; do
    grep -i "^$i" &>/dev/null <$INSTALLED_LIST_TMP_FILE
    if test $? != 0; then
      PKGS_TO_INSTALL="$i $PKGS_TO_INSTALL"
    fi
  done
  if ! test -z $PKGS_TO_INSTALL; then
    echo "PKGS_TO_INSTALL=$PKGS_TO_INSTALL"
    for i in $PKGS_TO_INSTALL; do
      $CODETMP --install-extension $i
    done
  fi
}

# ---------------------------------------
# ubuntu
# ---------------------------------------

function hf_ubuntu_upgrade() {
  sudo sed -i 's/Prompt=lts/Prompt=normal/g' /etc/update-manager/release-upgrades
  sudo apt update && sudo apt dist-upgrade
  do-release-upgrade
}

function hf_ubuntu_bluetooth_reinstall() {
  sudo apt reinstall pulseaudio pulseaudio-utils pavucontrol pulseaudio-module-bluetooth rtbth-dkms
}

# ---------------------------------------
# service
# ---------------------------------------

function hf_service_status_all() {
  sudo service --status-all
}

function hf_service_rcd_enable() {
  : ${1?"Usage: ${FUNCNAME[0]} <script_name>"}$1
  sudo update-rc.d $1 enable
}

function hf_service_rcd_disable() {
  : ${1?"Usage: ${FUNCNAME[0]} <script_name>"}$1
  sudo service $1 stop
  sudo update-rc.d -f $1 disable
}

function hf_service_add_script() {
  : ${1?"Usage: ${FUNCNAME[0]} <script_name>"}
  echo "creating /etc/init.d/$1"
  sudo touch /etc/init.d/$1
  sudo chmod 755 /etc/init.d/$1
  sudo update-rc.d $1 defaults
}

function hf_service_create_startup_script() {
  : ${1?"Usage: ${FUNCNAME[0]} <script_name>"}
  echo "creating /etc/init.d/$1"
  echo -e "[Unit]\\nDescription={service name}\\nAfter={service to start after, eg. xdk-daemon.service}\\n\\n[Service]\\nExecStart={/path/to/yourscript.sh}\\nRestart=always\\nRestartSec=10s\\nEnvironment=NODE_ENV=production\\n\\n[Install]\\nWantedBy=multi-user.target" | sudo tee /lib/systemd/system/$1
  systemctl daemon-reload
  systemctl enable yourservice.service
}

# ---------------------------------------
# mount
# ---------------------------------------

function hf_mount_list() {
  sudo lsblk -f
}

# ---------------------------------------
# gnome
# ---------------------------------------

function hf_gnome_execute_desktop_file() {
  awk '/^Exec=/ {sub("^Exec=", ""); gsub(" ?%[cDdFfikmNnUuv]", ""); exit system($0)}' $1
}

function hf_gnome_reset_keybindings() {
  hf_log_func
  gsettings reset-recursively org.gnome.mutter.keybindings
  gsettings reset-recursively org.gnome.mutter.wayland.keybindings
  gsettings reset-recursively org.gnome.desktop.wm.keybindings
  gsettings reset-recursively org.gnome.shell.keybindings
  gsettings reset-recursively org.gnome.settings-daemon.plugins.media-keys
}

function hf_gnome_dark() {
  gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-Black'
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-dark'
}

function hf_gnome_sanity() {
  hf_log_func
  # gnome search
  gsettings set org.gnome.desktop.search-providers sort-order "[]"
  gsettings set org.gnome.desktop.search-providers disable-external false
  gsettings set org.gnome.desktop.search-providers disabled "['org.gnome.Calculator.desktop', 'org.gnome.Calendar.desktop', 'org.gnome.clocks.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Software.desktop']"
  # animation
  gsettings set org.gnome.desktop.interface enable-animations false
  # background
  gsettings set org.gnome.desktop.background color-shading-type "solid"
  gsettings set org.gnome.desktop.background picture-uri ''
  gsettings set org.gnome.desktop.background primary-color "#000000"
  gsettings set org.gnome.desktop.background secondary-color "#000000"
  gsettings set org.gnome.desktop.background show-desktop-icons false
  # cloack
  gsettings set org.gnome.desktop.interface clock-show-date true
  # notifications
  gsettings set org.gnome.desktop.notifications show-banners false
  gsettings set org.gnome.desktop.notifications show-in-lock-screen false
  # recent files
  gsettings set org.gnome.desktop.privacy remember-recent-files false
  # screensaver
  gsettings set org.gnome.desktop.screensaver color-shading-type "solid"
  gsettings set org.gnome.desktop.screensaver lock-enabled false
  gsettings set org.gnome.desktop.screensaver picture-uri ''
  gsettings set org.gnome.desktop.screensaver primary-color "#000000"
  gsettings set org.gnome.desktop.screensaver secondary-color "#000000"
  # sound
  gsettings set org.gnome.desktop.sound event-sounds false
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 1
  # gedit
  gsettings set org.gnome.gedit.preferences.editor bracket-matching true
  gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
  gsettings set org.gnome.gedit.preferences.editor display-right-margin true
  gsettings set org.gnome.gedit.preferences.editor scheme 'classic'
  gsettings set org.gnome.gedit.preferences.editor wrap-last-split-mode 'word'
  gsettings set org.gnome.gedit.preferences.editor wrap-mode 'word'
  # workspaces
  gsettings set org.gnome.mutter dynamic-workspaces false
  # nautilus
  gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
  gsettings set org.gnome.nautilus.list-view use-tree-view true
  gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
  gsettings set org.gnome.nautilus.window-state maximized false
  gsettings set org.gnome.nautilus.window-state sidebar-width 180
  # dock
  gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 24
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
  gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
  gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
  gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
}

function hf_gnome_disable_unused_apps_in_search() {
  hf_log_func
  APPS_TO_HIDE=$(find /usr/share/applications/ -iname '*im6*' -iname '*java*' -o -iname '*JB*' -o -iname '*policy*' -o -iname '*icedtea*' -o -iname '*uxterm*' -o -iname '*display-im6*' -o -iname '*unity*' -o -iname '*webbrowser-app*' -o -iname '*amazon*' -o -iname '*icedtea*' -o -iname '*xdiagnose*' -o -iname yelp.desktop -o -iname '*brasero*')
  for i in $APPS_TO_HIDE; do
    sudo sh -c " echo 'NoDisplay=true' >> $i"
  done
}

function hf_gnome_disable_super_workspace_change() {
  hf_log_func
  # remove super+arrow virtual terminal change
  sudo sh -c 'dumpkeys |grep -v cr_Console |loadkeys'
}

function hf_gnome_disable_tiling() {
  # disable tiling
  gsettings set org.gnome.mutter edge-tiling false
}

function hf_gnome_reset_tracker() {
  sudo tracker reset --hard
  sudo tracker daemon -s
}

function hf_gnome_reset_shotwell() {
  rm -r $HOME/.cache/shotwell $HOME/.local/share/shotwell
}

function hf_gnome_update_desktop_database() {
  sudo update-desktop-database -v /usr/share/applications $HOME/.local/share/applications $HOME/.gnome/apps/
}

function hf_gnome_update_icons() {
  sudo update-icon-caches -v /usr/share/icons/ $HOME/.local/share/icons/
}

function hf_gnome_show_version() {
  gnome-shell --version
  mutter --version | head -n 1
  gnome-terminal --version
  gnome-text-editor --version
}

function hf_gnome_gdm_restart() {
  sudo /etc/init.d/gdm3 restart
}

function hf_gnome_settings_reset() {
  : ${1?"Usage: ${FUNCNAME[0]} <scheme>"}
  gsettings reset-recursively $1
}

function hf_gnome_settings_save_to_file() {
  : ${2?"Usage: ${FUNCNAME[0]} <dconf-dir> <file_name>"}
  dconf dump $1 >$2
}

function hf_gnome_settings_load_from_file() {
  : ${1?"Usage: ${FUNCNAME[0]} <dconf-dir> <file_name>"}
  dconf load $1 <$2
}

function hf_gnome_settings_diff_actual_and_file() {
  : ${2?"Usage: ${FUNCNAME[0]} <dconf-dir> <file_name>"}
  TMP_FILE=/tmp/gnome_settings_diff
  hf_gnome_settings_save_to_file $1 $TMP_FILE
  diff $TMP_FILE $2
}

# ---------------------------------------
# vlc
# ---------------------------------------

function hf_vlc_youtube_playlist_extension() {
  wget --continue https://dl.opendesktop.org/api/files/download/id/1473753829/149909-playlist_youtube.lua -P /tmp/
  if test $? != 0; then hf_log_error "wget failed." && return 1; fi
  sudo install /tmp/149909-playlist_youtube.lua /usr/lib/vlc/lua/playlist/
}

# ---------------------------------------
# date
# ---------------------------------------

function hf_date() {
  date +%F
}

# ---------------------------------------
# openssl
# ---------------------------------------

function hf_opessl_showcerts_https() {
  : ${1?"Usage: ${FUNCNAME[0]} <URL>"}
  openssl s_client -showcerts -connect "$1":https
}

# ---------------------------------------
# system
# ---------------------------------------

function hf_system_product_name() {
  sudo dmidecode -s system-product-name
}

function hf_system_distro() {
  lsb_release -a
}

function hf_system_host() {
  hostnamectl
}

function hf_system_product_is_macbook() {
  if [[ $(sudo dmidecode -s system-product-name) == MacBookPro* ]]; then
    printf TRUE
  else
    printf FALSE
  fi
}

function hf_system_list_gpu() {
  lspci -nn | grep -E 'VGA|Display'
}

# ---------------------------------------
# npm
# ---------------------------------------

function hf_npm_install_packages() {
  hf_log_func
  hf_test_noargs_then_return

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
      sudo npm install -g $PKGS_TO_INSTALL
      sudo npm update
    fi
    if test "$(pwd)" == "/tmp"; then cd - >/dev/null; fi
  fi
}

# ---------------------------------------
# ruby
# ---------------------------------------

function hf_ruby_install_packages() {
  hf_log_func
  hf_test_noargs_then_return

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
    if test "$(pwd)" == "/tmp"; then cd - >/dev/null; fi
  fi
}

# ---------------------------------------
# python
# ---------------------------------------

function hf_python_clean() {
  find . -name .ipynb_checkpoints -o -name __pycache__ | xargs -r rm -r
}

function hf_python_set_python3_default() {
  sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
  sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
}

function hf_python_version() {
  python -V 2>&1 | grep -Po '(?<=Python ).{1}'
}

function hf_python_list_installed() {
  pip list
}

function hf_python_install_packages() {
  hf_log_func
  hf_test_noargs_then_return
  hf_test_command pip || return

  PKGS_TO_INSTALL=""
  PKGS_INSTALLED=$(pip list --format=columns | cut -d' ' -f1 | grep -v Package | sed '1d' | tr '\n' ' ')
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
    sudo pip install --no-cache-dir --disable-pip-version-check $PKGS_TO_INSTALL
  fi
  sudo pip install -U "$@" &>/dev/null
}

function hf_python_remove_python35() {
  sudo rm -r /usr/local/bin/python3.5
  sudo rm -r /usr/local/lib/python3.5/
}

function hf_python_remove_home_pkgs() {
  hf_folder_remove $HOME/local/bin/
  hf_folder_remove $HOME/.local/lib/python3.5/
  hf_folder_remove $HOME/.local/lib/python3.7/
}

# ---------------------------------------
# venv
# ---------------------------------------

function hf_venv_create() {
  deactivate
  if test -d ./venv/bin/; then rm -r ./venv; fi
  python3 -m venv venv
  if test requirements.txt; then pip install -r requirements.txt; fi
}

function hf_venv_load() {
  deactivate
  source venv/bin/activate
  if test requirements.txt; then pip install -r requirements.txt; fi
}

# ---------------------------------------
# jupyter
# ---------------------------------------

function hf_jupyter_notebook() {
  jupyter notebook
}

function hf_jupyter_configure_git_diff() {
  sudo python install nbdime
  nbdime config-git --enable --global
  sed -i "s/git-nbdiffdriver diff$/git-nbdiffdriver diff -s/g" $HOME/.gitconfig
}

function hf_jupyter_dark_theme() {
  pip install jupyterthemes
  jt -t monokai
}

# ---------------------------------------
# eclipse
# ---------------------------------------

function hf_eclipse_install_packages() {
  hf_log_func
  hf_test_noargs_then_return

  # usage: hf_eclipse_install_packages org.eclipse.ldt.feature.group, org.eclipse.dltk.sh.feature.group
  eclipse -consolelog -noSplash -profile SDKProfile-repository download.eclipse.org/releases/neon, https://dl.google.com/eclipse/plugin/4.6, pydev.org/updates -application org.eclipse.equinox.p2.director -installIU "$@"
}

function hf_eclipse_uninstall_packages() {
  # usage: hf_eclipse_install_packages org.eclipse.egit.feature.group, \
  #   org.eclipse.mylyn.ide_feature.feature.group, \
  #   org.eclipse.mylyn_feature.feature.group, \
  #   org.eclipse.help.feature.group, \
  #   org.eclipse.tm.terminal.feature.feature.group, \
  #   org.eclipse.wst.server_adapters.feature.feature.group
  eclipse -consolelog -noSplash -application org.eclipse.equinox.p2.director -uninstallIU "$@"
  eclipse -consolelog -noSplash -application org.eclipse.equinox.p2.garbagecollector.application
}

# ---------------------------------------
# install_linux
# ---------------------------------------

function hf_install_linux_node() {
  hf_log_funch
  curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
  sudo apt install -y nodejs
}

function hf_install_linux_luarocks() {
  hf_log_func
  if ! type luarocks &>/dev/null; then
    wget https://luarocks.org/releases/luarocks-3.3.0.tar.gz
    tar zxpf luarocks-3.3.0.tar.gz
    cd luarocks-3.3.0
    ./configure && make && sudo make install
  fi
}

function hf_install_linux_python35() {
  hf_log_func
  if ! type python3.5 &>/dev/null; then
    sudo apt install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl
    CWD=$(pwd)
    cd /tmp
    hf_compression_extract_from_url https://www.python.org/ftp/python/3.5.7/Python-3.5.7.tgz /tmp
    cd /tmp/Python-3.5.7
    sudo ./configure --enable-optimizations
    make
    sudo make altinstall
    cd $CWD
  fi
}

function hf_install_linux_android_flutter() {
  hf_log_func
  OPT_DST="$HELPERS_OPT/linux"

  # android cmd and sdk
  ANDROID_SDK_DIR="$OPT_DST/android"
  ANDROID_CMD_DIR="$ANDROID_SDK_DIR/cmdline-tools"
  ANDROID_CMD_URL="https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip"
  if ! test -d $ANDROID_CMD_DIR; then
    mkdir -p $ANDROID_CMD_DIR
    hf_compression_extract_from_url $ANDROID_CMD_URL $ANDROID_SDK_DIR
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi
    hf_env_path_add $ANDROID_CMD_DIR/bin/
  fi
  if ! test -d $ANDROID_SDK_DIR/platforms; then
    $ANDROID_CMD_DIR/bin/sdkmanager --sdk_root="$ANDROID_SDK_DIR" --install 'platform-tools' 'platforms;android-29'
    yes | $ANDROID_CMD_DIR/bin/sdkmanager --sdk_root="$ANDROID_SDK_DIR" --licenses
    hf_env_add ANDROID_HOME $ANDROID_SDK_DIR
    hf_env_add ANDROID_SDK_ROOT $ANDROID_SDK_DIR
    hf_env_path_add $ANDROID_SDK_DIR/platform-tools
  fi

  # flutter
  FLUTTER_SDK_DIR="$OPT_DST/flutter"
  FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.6-stable.tar.xz"
  if ! test -d $FLUTTER_SDK_DIR; then
    hf_compression_extract_from_url $FLUTTER_SDK_URL $OPT_DST
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi
    hf_env_path_add $FLUTTER_SDK_DIR/bin
  fi
}

# ---------------------------------------
# install_windows
# ---------------------------------------

function hf_install_windows_android_flutter() {
  hf_log_func
  OPT_DST="$HELPERS_OPT/win/"

  # android cmd and sdk
  ANDROID_SDK_DIR="$OPT_DST/android"
  ANDROID_CMD_DIR="$ANDROID_SDK_DIR/cmdline-tools"
  ANDROID_CMD_URL="https://dl.google.com/android/repository/commandlinetools-win-6858069_latest.zip"
  if ! test -d $ANDROID_CMD_DIR; then
    hf_compression_extract_from_url $ANDROID_CMD_URL $ANDROID_SDK_DIR
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi
    hf_ps_call_admin "hf_env_path_add $(winpath $ANDROID_CMD_DIR/bin)"
  fi
  if ! test -d $ANDROID_SDK_DIR/platforms; then
    $ANDROID_CMD_DIR/bin/sdkmanager.bat --sdk_root="$ANDROID_SDK_DIR" --install 'platform-tools' 'platforms;android-29'
    yes | $ANDROID_CMD_DIR/bin/sdkmanager.bat --sdk_root="$ANDROID_SDK_DIR" --licenses
    hf_ps_call_admin "hf_env_add ANDROID_HOME $(winpath $ANDROID_SDK_DIR)"
    hf_ps_call_admin "hf_env_add ANDROID_SDK_ROOT $(winpath $ANDROID_SDK_DIR)"
    hf_ps_call_admin "hf_env_path_add $(winpath $ANDROID_SDK_DIR/platform-tools)"
  fi

  # flutter
  FLUTTER_SDK_DIR="$OPT_DST/flutter"
  FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.6-stable.tar.xz"
  if ! test -d $FLUTTER_SDK_DIR; then
    hf_compression_extract_from_url $FLUTTER_SDK_URL $HELPERS_OPT
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi
    hf_ps_call_admin "hf_env_path_add $(winpath $FLUTTER_SDK_DIR/bin)"
  fi
}

# ---------------------------------------
# install_gnome
# ---------------------------------------

if test $IS_LINUX; then

  function hf_install_gnome_bb_warsaw() {
    hf_log_func
    if ! type warsaw &>/dev/null; then
      hf_apt_fetch_install https://cloud.gastecnologia.com.br/bb/downloads/ws/warsaw_setup64.deb
    fi
  }

  function hf_install_gnome_git_lfs() {
    hf_log_func
    if ! type git-lfs &>/dev/null; then
      curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
      sudo apt-get install git-lfs
    fi
  }

  function hf_install_gnome_gitkraken() {
    hf_log_func
    if ! type gitkraken &>/dev/null; then
      sudo apt install gconf2 gconf-service libgtk2.0-0
      hf_apt_fetch_install https://release.axocdn.com/linux/gitkraken-amd64.deb
    fi
  }

  function hf_install_gnome_neo4j() {
    hf_log_func
    if ! type neo4j &>/dev/null; then
      wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add -
      echo 'deb https://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list
      sudo apt update
      sudo apt install neo4j
    fi
  }

  function hf_install_gnome_sqlworkbench() {
    hf_log_func
    dpkg --status mysql-workbench-community &>/dev/null
    if test $? != 0; then
      sudo apt install libzip5
      hf_apt_fetch_install https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community_8.0.17-1ubuntu19.04_amd64.deb
    fi
  }

  function hf_install_gnome_slack_deb() {
    hf_log_func
    dpkg --status slack-desktop &>/dev/null
    if test $? != 0; then
      sudo apt install -y libappindicator1
      hf_apt_fetch_install https://downloads.slack-edge.com/linux_releases/slack-desktop-4.0.2-amd64.deb
    fi
  }

  function hf_install_gnome_simplescreenrercoder_apt() {
    hf_log_func
    if ! type simplescreenrecorder &>/dev/null; then
      sudo rm /etc/apt/sources.list.d/maarten-baert-ubuntu-simplescreenrecorder*
      sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder
      sudo apt update
      sudo apt install -y simplescreenrecorder
    fi
  }

  function hf_install_gnome_vscode() {
    hf_log_func
    if ! type code &>/dev/null; then
      sudo rm /etc/apt/sources.list.d/vscode*
      curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/tmp/microsoft.gpg
      sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
      sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
      sudo apt update
      sudo apt install -y code
    fi
  }

  function hf_install_gnome_insync() {
    hf_log_func
    dpkg --status insync &>/dev/null
    if test $? != 0; then
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ACCAF35C
      echo "deb http://apt.insynchq.com/ubuntu bionic non-free contrib" | sudo tee /etc/apt/sources.list.d/insync.list
      sudo apt update
      sudo apt install -y insync insync-nautilus
    fi
  }

  function hf_install_gnome_foxit() {
    hf_log_func
    if ! type FoxitReader &>/dev/null; then
      URL=https://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz
      hf_compression_extract_from_url $URL /tmp/
      sudo /tmp/FoxitReader.enu.setup.2.4.4.0911\(r057d814\).x64.run
    fi
    if ! test -d $HELPERS_OPT/foxitsoftware; then
      sudo sed -i 's/^Icon=.*/Icon=\/usr\/share\/icons\/hicolor\/64x64\/apps\/FoxitReader.png/g' $HELPERS_OPT/foxitsoftware/foxitreader/FoxitReader.desktop
      sudo desktop-file-install $HELPERS_OPT/foxitsoftware/foxitreader/FoxitReader.desktop
    fi
  }

  function hf_install_gnome_chrome() {
    hf_log_func
    if ! type google-chrome-stable &>/dev/null; then
      hf_apt_fetch_install https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    fi
  }

  function hf_install_gnome_tor() {
    hf_log_func
    if ! test -d $HELPERS_OPT/tor; then
      URL=https://dist.torproject.org/torbrowser/9.5/tor-browser-linux64-9.5_en-US.tar.xz
      hf_compression_extract_from_url $URL $HELPERS_OPT/
    fi
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi
    mv $HELPERS_OPT/tor-browser_en-US $HELPERS_OPT/tor/
    sed -i "s|^Exec=.*|Exec=${HOME}/opt/tor/Browser/start-tor-browser|g" $HELPERS_OPT/tor/start-tor-browser.desktop
    sudo desktop-file-install "$HELPERS_OPT/tor/start-tor-browser.desktop"
  }

  function hf_install_gnome_zotero() {
    hf_log_func
    if ! test -d $HELPERS_OPT/zotero; then
      URL=https://download.zotero.org/client/release/5.0.82/Zotero-5.0.82_linux-x86_64.tar.bz2
      hf_compression_extract_from_url $URL /tmp/
      mv /tmp/Zotero_linux-x86_64 $HELPERS_OPT/zotero
    fi
    {
      echo '[Desktop Entry]'
      echo 'Version=1.0'
      echo 'Name=Zotero'
      echo 'Type=Application'
      echo "Exec=$HELPERS_OPT/zotero/zotero"
      echo "Icon=$HELPERS_OPT/zotero/chrome/icons/default/default48.png"
    } >$HELPERS_OPT/zotero/zotero.desktop
    sudo desktop-file-install $HELPERS_OPT/zotero/zotero.desktop
  }

  function hf_install_gnome_vidcutter() {
    hf_log_func
    dpkg --status vidcutter &>/dev/null
    if test $? != 0; then
      sudo rm /etc/apt/sources.list.d/ozmartian*
      sudo add-apt-repository -y ppa:ozmartian/apps
      sudo apt update
      sudo apt install -y python3-dev vidcutter
    fi
  }

  function hf_install_gnome_peek() {
    hf_log_func
    dpkg --status peek &>/dev/null
    if test $? != 0; then
      sudo rm /etc/apt/sources.list.d/peek-developers*
      sudo add-apt-repository -y ppa:peek-developers/stable
      sudo apt update
      sudo apt install -y peek
    fi
  }
fi

# ---------------------------------------
# env
# ---------------------------------------

function hf_env_add() {
  if test $# -eq 2 && ! grep -q "export $1=$2" $HOME/.bashrc; then
    echo "export $1=$2" >>$HOME/.bashrc
  fi
}

function hf_env_path_add() {
  if [[ ! "$PATH" =~ (^|:)"$1"(|/)(:|$) ]]; then
    echo "export PATH=\$PATH:$1" >>$HOME/.bashrc
  fi
}

# ---------------------------------------
# apt
# ---------------------------------------

function hf_apt_upgrade() {
  hf_log_func
  sudo apt -y update
  if [ "$(apt list --upgradable 2>/dev/null | wc -l)" -gt 1 ]; then
    sudo apt -y upgrade
  fi
}

function hf_apt_update() {
  hf_log_func
  sudo apt -y update
}

function hf_apt_ppa_remove() {
  hf_log_func
  sudo add-apt-repository --remove $1
}

function hf_apt_ppa_list() {
  hf_log_func
  apt policy
}

function hf_apt_fixes() {
  hf_log_func
  sudo dpkg --configure -a
  sudo apt install -f
  sudo apt dist-upgrade
}

function hf_apt_install_packages() {
  hf_log_func
  hf_test_noargs_then_return

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

function hf_apt_lastest_pkgs_names() {
  local PKGS_NAMES=""
  for i in "$@"; do
    PKGS_NAMES+=$(apt search $i 2>/dev/null | grep -E -o "^$i([0-9.]+)/" | cut -d/ -f1)
    PKGS_NAMES+=" "
  done
  echo $PKGS_NAMES
}

function hf_apt_autoremove() {
  hf_log_func
  if [ "$(apt --dry-run autoremove 2>/dev/null | grep -c -Po 'Remv \K[^ ]+')" -gt 0 ]; then
    sudo apt -y autoremove
  fi
}

function hf_apt_remove_packages() {
  hf_log_func
  hf_test_noargs_then_return
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

function hf_apt_remove_orphan_packages() {
  PKGS_ORPHAN_TO_REMOVE=""
  while [ "$(deborphan | wc -l)" -gt 0 ]; do
    for i in $(deborphan); do
      FOUND_EXCEPTION=false
      for j in "$@"; do
        if test "$i" = "$j"; then
          FOUND_EXCEPTION=true
          return
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

function hf_apt_fetch_install() {
  : ${1?"Usage: ${FUNCNAME[0]} <URL>"}
  apt_NAME=$(basename $1)
  if test ! -f /tmp/$apt_NAME; then
    wget --continue $1 -P /tmp/
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi

  fi
  sudo dpkg -i /tmp/$apt_NAME
}

# ---------------------------------------
# wget
# ---------------------------------------

function hf_wget_get_headers() {
  wget --server-response -O- $1
}

function hf_wget_post_json() {
  wget --server-response -O- $1 --post-data="$2" --header='Content-Type:application/json'
}

function hf_wget_post_file() {
  wget --server-response -O- $1 --post-file="$2" --header='Content-Type:application/json'
}

function hf_wget_continue() {
  wget --continue $1
}

# ---------------------------------------
# compress
# ---------------------------------------

function hf_compression_zip_files() {
  : ${2?"Usage: ${FUNCNAME[0]} <zip-name> <files... >"}
  zipname=$1
  shift
  zip "$zipname" -r "$@"
}

function hf_compression_zip_folder() {
  : ${1?"Usage: ${FUNCNAME[0]} <folder-name>"}
  zip "$(basename $1).zip" -r $1
}

function hf_compression_zip_extract() {
  : ${1?"Usage: ${FUNCNAME[0]} <zip-name>"}
  unzip $1 -d "${1%%.zip}"
}

function hf_compression_zip_list() {
  : ${1?"Usage: ${FUNCNAME[0]} <zip-name>"}
  unzip -l $1
}

function hf_compression_extract() {
  : ${1?"Usage: ${FUNCNAME[0]} <zip-name> [folder-name]"}
  local EXT=${1##*.}
  local DST
  if [ $# -eq 1 ]; then
    DST=.
  else
    DST=$2
  fi

  case $EXT in
  tgz)
    tar -xzf $1 -C $DST
    ;;
  gz) # consider tar.gz
    tar -xf $1 -C $DST
    ;;
  bz2) # consider tar.bz2
    tar -xjf $1 -C $DST
    ;;
  zip)
    unzip $1 -d $DST
    ;;
  xz)
    tar -xJf $1 -C $DST
    ;;
  rar)
    unrar x $1 -C $DST
    ;;
  *)
    hf_log_error "$EXT is not supported compression." && exit
    ;;
  esac
}

function hf_compression_extract_from_url() {
  : ${2?"Usage: ${FUNCNAME[0]} <URL> <folder>"}
  FILE_NAME="/tmp/$(basename $1)"

  if test ! -f $FILE_NAME; then
    echo "fetching $FILE_NAME"
    cd /tmp/
    wget --continue $1
    if test $? != 0; then hf_log_error "wget failed." && return 1; fi
    cd -
  fi
  echo "extracting $FILE_NAME to $2"
  hf_compression_extract $FILE_NAME $2
}

# ---------------------------------------
# youtubedl
# ---------------------------------------

YOUTUBEDL_PARAMS="--download-archive .downloaded.txt --no-warnings --no-post-overwrites --ignore-errors"
function hf_youtubedl_from_txt() {
  : ${1?"Usage: ${FUNCNAME[0]} <txt_file>"}
  youtube-dl -a "$1" --download-archive .downloaded.txt $YOUTUBEDL_PARAMS
}

function hf_youtubedl_video480() {
  : ${1?"Usage: ${FUNCNAME[0]} <txt_file>"}
  youtube-dl "$1" -f 'best[height<=480]' $YOUTUBEDL_PARAMS
}

function hf_youtubedl_video480_from_txt() {
  : ${1?"Usage: ${FUNCNAME[0]} <txt_file>"}
  youtube-dl -a "$1" -f 'best[height<=480]' $YOUTUBEDL_PARAMS
}

function hf_youtubedl_audio() {
  : ${1?"Usage: ${FUNCNAME[0]} <txt_file>"}
  youtube-dl "$1" $YOUTUBEDL_PARAMS -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --ignore-errors --embed-thumbnail --output "%(title)s.%(ext)s" --metadata-from-title "%(artist)s - %(title)s" --add-metadata
}

function hf_youtubedl_audio_best_from_txt() {
  : ${1?"Usage: ${FUNCNAME[0]} <txt_file>"}
  youtube-dl -a "$1" $YOUTUBEDL_PARAMS -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --ignore-errors --embed-thumbnail --output "%(title)s.%(ext)s" --metadata-from-title "%(artist)s - %(title)s" --add-metadata
}

# ---------------------------------------
# list
# ---------------------------------------

function hf_list_sorted_by_size() {
  du -h | sort -h
}

function hf_list_recursive_sorted_by_size() {
  du -ah | sort -h
}

# ---------------------------------------
# x11
# ---------------------------------------

function hf_x11_properties_of_window() {
  xprop | grep "^WM_"
}

function hf_x11_properties_of_window() {
  xprop | grep "^WM_"
}

# ---------------------------------------
# cleanup
# ---------------------------------------

HF_CLEAN_DIRS=(
  "Images"
  "Movies"
  "Public"
  "Templates"
  "Videos"
)

if test -n "$IS_LINUX"; then
  HF_CLEAN_DIRS+=(
    "Documents" # sensible data in Windows
    "Pictures"
    ".android"
    ".gimp-*"
    ".gradle"
    ".java"
  )
fi

if test -n "$IS_WINDOWS"; then
  HF_CLEAN_DIRS+=(
    'Application Data'
    'Cookies'
    'Local Settings'
    'Start Menu'
    '3D Objects'
    'Contacts'
    'Cookies'
    'Favorites'
    'Favorites'
    'Intel'
    'IntelGraphicsProfiles'
    'Links'
    'MicrosoftEdgeBackups'
    'My Documents'
    'NetHood'
    'PrintHood'
    'Recent'
    'Saved Games'
    'Searches'
    'SendTo'
  )
fi

function hf_clean_unused_dirs() {
  hf_log_func

  for i in "${HF_CLEAN_DIRS[@]}"; do
    if test -d "$HOME/$i"; then
      if test -n "$IS_MAC"; then
        sudo rm -rf "$HOME/${i:?}" >/dev/null
      else
        rm -rf "$HOME/${i:?}" >/dev/null
      fi
    elif test -f "$HOME/$i"; then
      echo remove $i
      if test -n "$IS_MAC"; then
        sudo rm -f "$HOME/$i" >/dev/null
      else
        rm -f "$HOME/${i:?}" >/dev/null
      fi
    fi
  done
}
