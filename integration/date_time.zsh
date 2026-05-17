#!/usr/bin/env zsh

zmodload -F zsh/datetime b:strftime

iterm2::date_time() {
  local -ri 10 delim=$RANDOM

  # `strftime(3)` formats, also used by `date`
  local -r _full_dt_fmt='%a %e %b %R'  # %a=Sun %e=17 %b=May %R=18:52
  local -r _abbr_dt_fmt="%y%j$delim%R" # %y=26 %j=137 [day of the year 1-366]

  local -ra _regions=(
    'Europe/London'
    'Asia/Dubai'
    # # For testing
    # 'America/New_York'
    # 'Pacific/Fiji'
  )

  local local_dt local_full_dt
  strftime -s local_dt      "$_abbr_dt_fmt"
  strftime -s local_full_dt "$_full_dt_fmt"

  local -ri 10 local_date="${local_dt%$delim*}"

  local region region_dt region_time
  local -i 10 region_date
  local -a extra_times

  for region in "${(@)_regions}"; {
    region_dt="$( date -z "$region" "+$_abbr_dt_fmt" )"

    if [[ "$local_dt" != "$region_dt" ]] {
      region_date="${region_dt%$delim*}"
      region_time="${region_dt#*$delim}"

      if (( region_date > local_date )) region_time+=' →'
      if (( region_date < local_date )) region_time="← $region_time"

      extra_times+="$region_time"
    }
  }

  local -r output_times=( "$local_full_dt" "${(@)extra_times}" )
  echo "󱑍 ${(j: / :)output_times}"
}

# Old iTerm Date/Time format: eee dd MMM HH:mm
