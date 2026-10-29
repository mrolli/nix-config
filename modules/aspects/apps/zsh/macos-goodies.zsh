# macOS-only helper functions, ported from the mrolli/zsh-macos-goodies
# zinit plugin. Darwin-only; must only be sourced on Darwin hosts.
#
# shellcheck disable=SC1087,SC2034,SC2059,SC2086,SC2148,SC2154,SC2155,SC2162,SC2181,SC2195,SC2206,SC2296
# (shellcheck has no zsh dialect; the codes above are all false positives on
# zsh-only syntax such as $words[1], ${(s[, ])...}, and prompt theme vars.)
# shellcheck disable=SC2148

# Lock the screen (was the "afk" alias in zsh.nix; now a function so it can
# live alongside the rest of the macOS goodies).
afk() {
  osascript <<EOD
  tell application "System Events"
    key code 12 using {control down, command down}
  end tell
EOD
}

# For the confirmation moments in life
_prompt_confirm() {
  while true; do
    quest=$(printf "\r[ ${fg[yellow]}??${reset_color} ] ${1:-Continue?} [y/n]: ")
    read "reply?$quest"
    case $reply in
    [yY])
      echo
      return 0
      ;;
    [nN])
      echo
      return 1
      ;;
    *) printf " ${fg[red]} %s \n${reset_color}" "invalid input" ;;
    esac
  done
}

# Update Homebrew, upgrade formulae/casks, clean up, run doctor, and
# optionally upgrade App Store apps via mas.
brewup() {
  brew update
  brew upgrade

  echo "${fg[blue]}==>${reset_color} Running brew cleanup"
  brew cleanup

  echo "${fg[blue]}==>${reset_color} Running brew doctor"
  brew doctor

  echo ""
  if [ "${1}" = "-f" ] || _prompt_confirm "Shall I upgrade AppStore apps?"; then
    if command -v mas &>/dev/null; then
      echo "[ ${fg[blue]}..${reset_color} ] Running mas upgrade"
      mas upgrade
    else
      echo "[${fg[red]}fail${reset_color}] mas not found. Install with brew install mas"
    fi
  fi
}

# Empty the trash and clear some caches/logs that otherwise accumulate.
emptytrash() {
  # Empty the trash on the main HDD.
  sudo rm -rfv ~/.Trash/*

  # Also, clear Apple's System Logs to improve shell startup speed.
  sudo rm -rfv /private/var/log/asl/*.asl

  # Finally, clear download history from quarantine. https://mths.be/bum
  sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'
}

# Flush the DNS cache.
flushdns() {
  dscacheutil -flushcache && sudo killall -HUP mDNSResponder
}

# Recursively remove .DS_Store files from the given directory (or cwd).
rmdsstore() {
  find "${@:-.}" -type f -name .DS_Store -ls -delete
}

# Speed up Time Machine backups by disabling the low-priority I/O throttle.
# https://www.defaults-write.com/speed-up-time-machine-backups/
speedup_timemachine() {
  sudo sysctl debug.lowpri_throttle_enabled=0
}

# Restore the default (throttled) Time Machine backup speed.
speeddown_timemachine() {
  sudo sysctl debug.lowpri_throttle_enabled=1
}

# Create a bootable macOS installer USB stick.
create_macos_bootstick() {
  if [ $# -ne 2 ]; then
    echo "Usage example: create_macos_bootstick Sierra /Volumes/Untitled"
    return 1
  fi

  sudo "/Applications/Install macOS $1.app/Contents/Resources/createinstallmedia" \
    --volume "${2}" --applicationpath "/Applications/Install macOS $1.app/" --nointeraction
}

# Write a bootable ISO image to a USB stick.
usbcreator() {
  if [ $# -ne 2 ]; then
    echo "Usage: usbcreator bootable.iso /dev/rdisk1"
    return 1
  fi

  local src_img=$1
  local dst_img=/tmp/target.img
  local stick=$2

  hdiutil convert -format UDRW -o "$dst_img" "$src_img"
  mv "$dst_img.dmg" "$dst_img"
  diskutil unmountDisk "$stick"
  sudo dd if="$dst_img" of="$stick" bs=1m
  rm -f "$dst_img"
}
