#!/usr/bin/env zsh

source "${0:h}/hsl_to_rgb.zsh"

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

  local -a rgb hsl
  local -i 2 try_hsl
  local col formatted_input

  setopt local_options extended_glob

  # ———————————————————————————————————————————————————————————— #

  if [[ "$*" == (|'#')([0-9a-fA-F](#c3))(#c1,2) ]] {
    #¬ `#807ded` `#87E` `807DED` `87e`
    col="${*#\#}"  # remove the leading hash if it exists

    # if it's a 3-digit hex value, duplicate every character to make it 6-digit
    if (( $#col == 3 )) { rgb=( $col[1]$col[1] $col[2]$col[2] $col[3]$col[3] )
    } else              { rgb=( $col[1,2]      $col[3,4]      $col[5,6]   ); }

    # convert each of the digits from hex to decimal
    rgb=(  $(( 16#$rgb[1] ))  $(( 16#$rgb[2] ))  $(( 16#$rgb[3] ))  )
    formatted_input="#$col"

  # ———————————————————————————————————————————————————————————— #

  } elif [[ "$*" =~ "^ *((rgb|RGB)?\()?${~numb},?${~numb},?${~numb}\)? *$" ]] {
    #¬ `rgb(128, 125, 237)`   `rgb(  128,125 237)`   `(  128   125   237   )`
    #¬ `128 125 237`   `128,125,237`

    # remove the leading `rgb` and `(`, and remove the trailing `)`
    # then replace all non-digits with spaces
    col="${${${${*#rgb}#\(}%\)}//[^0-9]/ }"
    # split at every space, then remove empty elements (`:#`)
    rgb=( "${(@)${(@s: :)col}:#}" )
    formatted_input="rgb(${(j:, :)rgb})"

    # if either of the last two digits are over 255, we know that the value
    #  is definitely out of bounds, so print an error and exit immediately
    if (( rgb[2] > 255 || rgb[3] > 255 )) { it2::error rgb-bounds; return 1; }
    # but if the first digit is between 266 and 360, it might actually be
    #  an hsl colour, so reset `$@rgb`, so we can try and test for hsl instead
    if (( 255 < rgb[1] && rgb[1] <= 360 )) rgb=()
  }

  # ———————————————————————————————————————————————————————————— #

  # only check for hsl if `$@rgb` hasn't been set yet
  if (( $#rgb == 0 )) \
    && [[ "$*" =~ "^ *((hsl|HSL)?\()?${~degs},?${~perc},?${~perc}\)? *$" ]] {

    # remove the leading `hsl` and `(`, and remove the trailing `)`
    # then replace all non-digits (or decimals) with spaces
    col="${${${${*#hsl}#\(}%\)}//[^0-9.]/ }"
    # split at every space, then remove empty elements (`:#`)
    hsl=( "${(@)${(@s: :)col}:#}" )

    # if any of the values are out of bounds, throw an error
    if (( hsl[1] > 360 || hsl[2] > 100 || hsl[2] > 100 )) {
      it2::error hsl-bounds
      return 1
    }

    rgb=( "${(@s: :)$( hsl_to_rgb "${(@)hsl}" )}" )
    formatted_input="hsl( $hsl[1]°, $hsl[1]%, $hsl[1]% )"
  } 

  # ———————————————————————————————————————————————————————————— #

  if (( $#rgb == 0 )) { it2::error colour-format; return 1; }

  echo -n "$ESC]6;1;bg;red;brightness;$rgb[1]$BEL"
  echo -n "$ESC]6;1;bg;green;brightness;$rgb[2]$BEL"
  echo -n "$ESC]6;1;bg;blue;brightness;$rgb[3]$BEL"

  if ! [[ -t 1 ]] return 0

  local -r esc_col="${ESC}[48;2;${(j:;:)rgb}m"
  local -r reset=$'\e[m'

  {
    echo -n "Set tab background colour to $esc_col$formatted_input$reset"
    if [[ "$formatted_input" != 'rgb'* ]] \
      echo -n " == ${esc_col}rgb(${(j:, :)rgb})$reset"
    echo
  } >&2
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
  # rgb-bounds
  # hsl-bounds
  # colour-format
  echo "error $1" >&2
}

# ——————————————————————————————————————————————————————————————————————————— #

# spell:ignore annot perc
# spell:ignoreRegExp /(?<=\\[abcefnrtv])\w+\b/g
