#!/usr/bin/env zsh

unalias it{2,} &>/dev/null
alias   it{2,}=iterm

# —— Main Function —————————————————————————————————————————————————————————— #

function iterm() {
  local IFS=$' \t\n\0'
  local -r BEL=$'\a' ESC=$'\e' leader=$'\e]1337;'

  local function="$1"; shift
  local esc_phrase=

  case "$function" {
    ( tab     ) it2::tab   "$@"                       ;;
    ( title   ) it2::title "$@"                       ;;
    ( mark    ) esc_phrase=SetMark                    ;;
    ( focus   ) esc_phrase=StealFocus                 ;;
    ( clear   ) esc_phrase=ClearScrollback            ;;
    ( notif   ) echo -nE "$ESC]9;$*$BEL"              ;;
    ( profile ) echo -nE "${leader}SetProfile=$*$BEL" ;;
  }

  local -i 10 ret_code=$?
  if (( $#esc_phrase == 0 || ret_code != 0 )) { return ret_code; }

  echo -n "$leader$esc_phrase$BEL"
}

# —— Done (mostly) —————————————————————————————————————————————————————————— #

function it2::title() { echo -n "${ESC}]0;$*$BEL"; }

function it2::tab() {
  if [[ "$1" == 'reset' ]] { echo -n $'\e]6;1;bg;*;default\a'; return; }

  local -r digs='[0-9]{1,3}'
  local -r numb=" *$digs *"
  local -r degs=" *$digs(°|degs?)? *"
  local -r perc=" *$digs(\.$digs%?)? *"

  local i col
  local -a rgb hsl

  local -r input="$*"

  setopt local_options extended_glob

  #¬ `#807ded` `#87E` `807DED` `87e`
  if [[ "$input" == (|'#')([0-9a-fA-F](#c3))(#c1,2) ]] {
    col="${input#\#}"

    if (( $#col == 3 )) { rgb=( $col[1]$col[1] $col[2]$col[2] $col[3]$col[3] )
    } else              { rgb=( $col[1,2]      $col[3,4]      $col[5,6]      )
    }
    rgb=(  $(( 16#$rgb[1] ))  $(( 16#$rgb[2] ))  $(( 16#$rgb[3] ))  )
    echo "rgb = $rgb"

  #¬ `rgb(128, 125, 237)`   `rgb(  128,125 237)`   `(  128   125   237   )`
  #¬ `128 125 237`   `128,125,237`
  } elif [[ "$input" =~ "^ *((rgb)?\()?${~numb},?${~numb},?${~numb}\)? *$" ]] {

    # remove the leading `rgb` and `(`, and remove the trailing `)`
    # then replace all non-digits with spaces
    col="${${${${input#rgb}#\(}%\)}//[^0-9]/ }"
    # split at every space, then remove empty elements (`:#`)
    rgb=( "${(@)${(@s: :)col}:#}" )

    for i ("${(@)rgb}") if (( i > 255 )) { it2::error rgb; return 1; }
    echo "rgb = $rgb"

  } elif [[ "$input" =~ "^ *((hsl)?\()?${~degs},?${~perc},?${~perc}\)? *$" ]] {

    # remove the leading `hsl` and `(`, and remove the trailing `)`
    # then replace all non-digits (or decimals) with spaces
    col="${${${${input#hsl}#\(}%\)}//[^0-9.]/ }"
    # split at every space, then remove empty elements (`:#`)
    hsl=( "${(@)${(@s: :)col}:#}" )

    echo "hsl = $hsl"
  }

  echo -E "\\e]6;1;bg;red;brightness;$rgb[1]\\a"
  echo -E "\\e]6;1;bg;green;brightness;$rgb[2]\\a"
  echo -E "\\e]6;1;bg;blue;brightness;$rgb[3]\\a"
}

# —— TODO ——————————————————————————————————————————————————————————————————— #

function it2::annot() {  #r)FIXME
  local -r message="$1"
  local -ri 10 length x_coord y_coord
  local -ri 2 is_hidden=0

  local _esc_phrase='Add'; if (( is_hidden )) _esc_phrase+='Hidden'
  _esc_phrase+='Annotation'

  echo -nE "$leader$_esc_phrase=$message$BEL"
  # echo -nE "$leader$_esc_phrase=$length|$message$BEL"
  # echo -nE "$leader$_esc_phrase=$message|$length|$x_coord|$y_coord$BEL"
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
  echo -nE "$ESC]8;;$link$BEL$text$ESC]8;;$BEL"
}

# ——————————————————————————————————————————————————————————————————————————— #


it2::error() {
  # rgb
  echo "error $1" >&2
}

# ——————————————————————————————————————————————————————————————————————————— #

# spell:ignore annot perc
