#!/usr/bin/env zsh

function hsl_to_rgb() {
  local -F 10 h=$(( $1 / 360.0 )) s=$(( $2 / 100.0 )) l=$(( $3 / 100.0 ))
  local -F 10 r g b

  if (( s == 0 )) {
    r=$l g=$l b=$l  # achromatic
  } else {

    local -F 10 q=$(( l < 0.5 ? ( l * ( s + 1 ) ) : ( l + s - ( l * s ) ) ))
    local -F 10 p=$(( 2.0 * l - q ))

    r=$( hue_to_rgb $p $q $(( h + 1.0 / 3 )) )
    g=$( hue_to_rgb $p $q $h                 )
    b=$( hue_to_rgb $p $q $(( h - 1.0 / 3 )) )
  }

  printf $'%.0f %.0f %.0f\n' $(( r * 255 )) $(( g * 255 )) $(( b * 255 ))
}

function hue_to_rgb() {
  local -F 10 P=$1 Q=$2 T=$3

  if (( T < 0 )) (( T++ ))
  if (( T > 1 )) (( T-- ))

  if (( T < 1.0 / 6 )) echo $(( P + (Q-P) * 6.0 * T             )) && return
  if (( T < 1.0 / 2 )) echo $Q                                     && return
  if (( T < 2.0 / 3 )) echo $(( P + (Q-P) * ( 2.0 / 3 - T ) * 6 )) && return

  echo $P
}

# ——————————————————————————————————————————————————————————————————————————— #

#b)translated from the javascript by mjackson
#g)  https://gist.github.com/mjackson/5311256

# /**
#  * Converts an HSL color value to RGB. Conversion formula
#  * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
#  * Assumes h, s, and l are contained in the set [0, 1] and
#  * returns r, g, and b in the set [0, 255].
#  *
#  * @param   Number  h       The hue
#  * @param   Number  s       The saturation
#  * @param   Number  l       The lightness
#  * @return  Array           The RGB representation
#  */
# function hslToRgb(h, s, l) {
#   var r, g, b;
#
#   if (s == 0) {
#     r = g = b = l; // achromatic
#   } else {
#     function hue2rgb(p, q, t) {
#       if (t < 0) t += 1;
#       if (t > 1) t -= 1;
#       if (t < 1/6) return p + (q - p) * 6 * t;
#       if (t < 1/2) return q;
#       if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
#       return p;
#     }
#
#     var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
#     var p = 2 * l - q;
#
#     r = hue2rgb(p, q, h + 1/3);
#     g = hue2rgb(p, q, h);
#     b = hue2rgb(p, q, h - 1/3);
#   }
#
#   return [ r * 255, g * 255, b * 255 ];
# }

# spell:ignore mjackson
