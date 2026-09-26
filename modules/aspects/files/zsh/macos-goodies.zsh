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

# Control the Music app.
# Sources: https://alvinalexander.com/apple/itunes-applescript-examples-scripts-mac-reference/
music() {
  local APP_NAME=Music
  local opt=$1
  local playlist=$2

  [ $# -gt 0 ] && shift

  case "$opt" in
  launch | play | pause | stop | rewind | resume | quit) ;;
  mute)
    opt="set mute to true"
    ;;
  unmute)
    opt="set mute to false"
    ;;
  next | previous)
    opt="$opt track"
    ;;
  vol | volume)
    local new_volume volume=$(osascript -e "tell application \"$APP_NAME\" to get sound volume")
    if [ $# -eq 0 ]; then
      echo "Current volume is ${volume}."
      return 0
    fi
    case $1 in
    up) new_volume=$((volume + 10 < 100 ? volume + 10 : 100)) ;;
    down) new_volume=$((volume - 10 > 0 ? volume - 10 : 0)) ;;
    [0-9][0-9]) new_volume=$1 ;;
    *)
      echo "'$1' is not valid. Expected <0-100>, up or down."
      return 1
      ;;
    esac
    opt="set sound volume to ${new_volume}"
    ;;
  playlist)
    # Inspired by: https://gist.github.com/nakajijapan/ac8b45371064ae98ea7f
    # If no playlist is provided, let the user choose from all available
    # playlists via fzf if available else print out the found playlists
    if [[ -z "$playlist" ]]; then
      playlist=$(osascript -e 'tell application "Music" to get name of every playlist' | sed 's/, /\n/g' | sort)
      if command -v fzf &>/dev/null; then
        playlist=$(echo "$playlist" | fzf --prompt="Choose a playlist: " --height=20)
      else
        echo "Available playlists:"
        echo "$playlist"
        echo
        echo "Usage: $(basename $0) playlist [playlist name]"
        return 1
      fi
    fi

    [[ -z "$playlist" ]] && exit 0

    osascript 2>/dev/null <<EOF
        tell application "$APP_NAME"
          set new_playlist to "$playlist" as string
          play playlist new_playlist
        end tell
EOF
    if [[ $? -eq 0 ]]; then
      opt="play"
    else
      opt="stop"
    fi
    ;;
  playing | status)
    local currenttrack currentartist state=$(osascript -e "tell application \"$APP_NAME\" to player state as string")
    if [[ "$state" = "playing" ]]; then
      currenttrack=$(osascript -e "tell application \"$APP_NAME\" to name of current track as string")
      currentartist=$(osascript -e "tell application \"$APP_NAME\" to artist of current track as string")
      echo -E "Listening to ${fg[yellow]}${currenttrack}${reset_color} by ${fg[yellow]}${currentartist}${reset_color}"
    else
      echo "$APP_NAME is $state"
    fi
    return 0
    ;;
  shuf | shuff | shuffle)
    local state=$1

    if [[ -n "$state" && ! "$state" =~ (on|off|toggle) ]]; then
      echo "Usage: $(basename $0) shuffle [on|off|toggle]. Invalid option: ${state}"
      return 1
    fi

    case "$state" in
    on | off)
      [[ $state = "on" ]] && state="true" || state="false"
      osascript >/dev/null 2>&1 <<EOF
            tell application "Music"
              set shuffle enabled to $state
            end tell
EOF
      ;;
    toggle)
      osascript >/dev/null 2>&1 <<EOF
            tell application "Music"
              if shuffle enabled is true then
                set shuffle enabled to false
              else
                set shuffle enabled to true
              end if
            end tell
EOF
      ;;
    esac

    # Print current shuffle state in either case
    shufstate=$(osascript -e "tell application \"$APP_NAME\" to get shuffle enabled")
    [[ $shufstate = "true" ]] && shufstate="on" || shufstate="off"
    echo "Shuffle is now $shufstate"
    return 0
    ;;

  "" | help | -h | --help)
    _music_usage
    return 0
    ;;
  *)
    echo "Unknown option: $opt"
    return 1
    ;;
  esac

  osascript -e "tell application \"$APP_NAME\" to $opt"
}

_music_usage() {
  echo -n "Usage: music CMD [ARGS]
Controls Music app by invoking commands, see list below.

Available commands:
  launch|play|pause|stop|rewind|resume|quit
  mute|unmute                      Mute or unmute Music
  next|previous                    Play next or previous track
  shuf|shuffle    [on|off|toggle]  Set shuffled playback state. No argument displays current shuffle state.
  vol|volume      [0-100|up|down]  Set the volume. 0 to 100 sets the volume. 'up' / 'down' by 10 points. No argument displays current volume.
  playing|status                   Show what song is currently playing in Music.
  playlist        [playlist name]  Play specific playlist. No argument displays fzf-based playlist chooser if fzf is available.

Options:
  -h|--help      Show this message and exit
" >&2
}

# Completion for the music function.
_music() {
  local -a commands

  _arguments -C \
    "(-h --help)"{-h,--help}"[Get help for music]" \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "launch:Launch the Music app"
      "play:Play Music"
      "pause:Pause Music"
      "stop:Stop Music"
      "rewind:Rewind Music"
      "resume:Resume Music"
      "quit:Quit Music"
      "mute:Mute the Music app"
      "unmute:Unmute the Music app"
      "next:Skip to the next song"
      "previous:Skip to the previous song"
      {vol,volume}":Get or set the volume"
      "playlist:Play a specific playlist"
      {playing,status}":Show what song is currently playing"
      {shuf,shuff,shuffle}":Set shuffle mode"
      "help|Get help for music"
    )
    _describe "command" commands
    ;;
  esac

  case "$words[1]" in
  shuf | shuff | shuffle)
    _music_shuffle
    ;;
  vol | volume)
    _music_volume
    ;;
  playlist)
    _music_playlist
    ;;
  esac
}

_music_shuffle() {
  local -a commands

  _arguments -C \
    "(-h --help)"{-h,--help}"[Get help with shuffle]" \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "on:Turn on shuffle mode."
      "off:Turn off shuffle mode."
      "toggle:Toggle shuffle mode (does not support the MiniPlayer)."
    )
    _describe "command" commands
    ;;
  esac
}

_music_playlist() {
  local -a commands

  _arguments -C \
    "(-h --help)"{-h,--help}"[Get help with shuffle]" \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(${(s[, ])$(osascript -e 'tell application "Music" to get name of every playlist')})
    _describe "command" commands
    ;;
  esac
}

_music_volume() {
  local -a commands

  _arguments -C \
    "(-h --help)"{-h,--help}"[Get help with shuffle]" \
    "1: :->cmnds" \
    "*::arg:->args"

  case $state in
  cmnds)
    commands=(
      "up:Increase volume by 10 points."
      "down:Decrease volume by 10 points."
      "[0-100]:Set volume to the given percent number."
      ":No argument displays current volume."
    )
    _describe "command" commands
    ;;
  esac
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
