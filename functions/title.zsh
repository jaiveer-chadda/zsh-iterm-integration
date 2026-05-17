#!/usr/bin/env zsh

unalias it{2,} &>/dev/null
alias   it{2,}=iterm

# —— Main Function —————————————————————————————————————————————————————————— #

function iterm() {
  local IFS=$' \t\n\0'
  local -r BEL=$'\a' ESC=$'\e' OSC=$'\e]' leader=$'\e]1337;'

  local function="$1"; shift
  local esc_phrase=

  case "$function" in
    ( tab     ) it2::tab   "$@"                       ;;
    ( title   ) it2::title "$@"                       ;;
    ( mark    ) esc_phrase=SetMark                    ;;
    ( focus   ) esc_phrase=StealFocus                 ;;
    ( clear   ) esc_phrase=ClearScrollback            ;;
    ( notif   ) echo -nE $'\e]9;'"$*$BEL"             ;;
    ( profile ) echo -nE "${leader}SetProfile=$*$BEL" ;;
  esac

  local -i 10 ret_code=$?
  if (( $#esc_phrase == 0 || ret_code != 0 )) { return ret_code; }

  echo -n "$leader$esc_phrase$BEL"
}

# —— Done (mostly) —————————————————————————————————————————————————————————— #

function it2::title() { echo -n "${ESC}]0;$*$BEL"; }

function it2::tab() {
  local -r mode="$1"; shift

  case "$mode" {
    ( bg ) it2::tab::background "$@" ;;
    ( *  ) echo opt ;;
  }
}

function it2::tab::background() {
  if [[ "$1" == 'reset' ]] { echo -n $'\e]6;1;bg;*;default\a'; return; }

  local -ri 10 r=${1:?} g=${2:?} b=${3:?}

  echo -n "$ESC]6;1;bg;red;brightness;$r$BEL"
  echo -n "$ESC]6;1;bg;green;brightness;$g$BEL"
  echo -n "$ESC]6;1;bg;blue;brightness;$b$BEL"
}

# —— TODO ——————————————————————————————————————————————————————————————————— #

function it2::annot() {  #r)FIXME
  local -r message="$1"
  local -ri 10 length x_coord y_coord
  local -ri 2 is_hidden=0

  local esc_phrase='Add'; if (( is_hidden )) esc_phrase+='Hidden'
  esc_phrase+='Annotation'

  echo -nE "$leader$esc_phrase=$message$BEL"
  # echo -nE "$leader$esc_phrase=$length|$message$BEL"
  # echo -nE "$leader$esc_phrase=$message|$length|$x_coord|$y_coord$BEL"
}

function it2::highlight_cursor() {  #r)FIXME
  # \e ] 1337 ; HighlightCursorLine = ( yes | no ) \a
  echo -nE "${leader}HighlightCursorLine=$1$BEL"
}

function it2::attention() {  #r)FIXME
  # `yes`       : bounce the dock icon indefinitely
  # `once`      : bounce the dock icon a single time
  # `no`        : cancel a previous request
  # `fireworks` : make fireworks explode at the cursor's location

  # \e ] 1337 ; RequestAttention = ( yes | once | no | fireworks ) \a
  echo -nE "${leader}RequestAttention=$1$BEL"
}

function it2::highlight_cursor() {  #r)FIXME
  # \e ] 1337 ; ReportCellSize \a

  # The terminal responds with:

  # \e ] 1337 ; ReportCellSize = [height] ; [width] \a
  # Or, in newer versions:
  # \e ] 1337 ; ReportCellSize = [height] ; [width] ; [scale] \a
  
  # [scale] gives the number of px (physical units) to pt (logical units)
  #   1.0 means non-retina, 2.0 means retina
  # [height] and [width] are floats giving the size in pt of a single char cell

  echo -nE "${leader}ReportCellSize=$1$BEL"
}

function it2::copy() {  #r)FIXME
  # \e ] 1337 ; Copy =: [base64] \a
  echo -nE "${leader}Copy=:$@$BEL"
}

function it2::link() {  #r)FIXME
  # \e ] 8 ; ; https://example.com/ \a Link to example website \e ] 8 ; ; \a
  local -r link="$1" text="$2"
  echo -nE "$ESC]8;;$link/$BEL$text$ESC]8;;$BEL"
}

# ——————————————————————————————————————————————————————————————————————————— #

# spell:ignore annot
